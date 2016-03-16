//
//  Location.swift
//
// Copyright (c) 2016 Damien (http://delba.io)
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

import CoreLocation

internal extension Permission {
    var locationManager: CLLocationManager {
        let manager = CLLocationManager()
        manager.delegate = LocationManagerDelegate(permission: self)
        return manager
    }
}

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    let permission: Permission
    
    var callback: Callback {
        return permission.callbacks
    }
    
    var status: Permission.Status {
        return permission.status
    }
    
    var locationStatusDidChange: [Permission.Domain: Bool] = [
        .LocationWhenInUse: false,
        .LocationAlways: false
    ]
    
    init(permission: Permission) {
        self.permission = permission
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        guard locationStatusDidChange[permission.domain]! else {
            locationStatusDidChange[permission.domain] = true
            return
        }
        
        callback(self.status)
    }
}