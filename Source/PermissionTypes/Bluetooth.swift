//
//  Bluetooth.swift
//
// Copyright (c) 2015 Damien (http://delba.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import CoreBluetooth

internal let BluetoothManager = CBPeripheralManager(
    delegate: Permission.Bluetooth,
    queue: nil,
    options: [CBPeripheralManagerOptionShowPowerAlertKey: false]
)

extension Permission {
    var statusBluetooth: Permission.Status {
        let state = (BluetoothManager.state, CBPeripheralManager.authorizationStatus())
        
        switch state {
        case (.Unsupported, _), (.PoweredOff, _), (_, .Restricted):
            return .Disabled
        case (.Unauthorized, _), (_, .Denied):
            return .Denied
        case (.PoweredOn, .Authorized):
            return .Authorized
        default:
            return .NotDetermined
        }
    }
    
    func requestBluetooth(callback: Callback) {
        Defaults.requestedBluetooth = true
        
        BluetoothManager.request(self)
    }
}

extension Permission: CBPeripheralManagerDelegate {
    public func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if callback != nil {
            callback(statusBluetooth)
        }
    }
}

extension CBPeripheralManager {
    func request(permission: Permission) {
        startAdvertising(nil)
        stopAdvertising()
    }
}