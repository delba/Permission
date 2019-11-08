//
// LocationAlways.swift
//
// Copyright (c) 2015-2019 Damien (http://delba.io)
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

#if PERMISSION_LOCATION
import CoreLocation

extension Permission {
    var statusLocationAlways: PermissionStatus {
        guard CLLocationManager.locationServicesEnabled() else { return .disabled }

        let status = CLLocationManager.authorizationStatus()

        switch status {
        case .authorizedAlways: return .authorized
        case .authorizedWhenInUse:
            return Defaults.requestedLocationAlwaysWithWhenInUse ? .denied : .notDetermined
        case .notDetermined: return .notDetermined
        case .restricted, .denied: return .denied
        @unknown default: return .notDetermined
        }
    }

    func requestLocationAlways(_ callback: Callback) {
        guard let _ = Foundation.Bundle.main.object(forInfoDictionaryKey: .locationAlwaysUsageDescription) else {
            print("WARNING: \(String.locationAlwaysUsageDescription) not found in Info.plist")
            return
        }

        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            Defaults.requestedLocationAlwaysWithWhenInUse = true
        }

        LocationManager.request(self)
    }
}
#endif
