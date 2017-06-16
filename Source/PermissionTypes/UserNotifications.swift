//
// UserNotifications.swift
//
// Copyright (c) 2015-2016 Damien (http://delba.io)
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

#if PERMISSION_USER_NOTIFICATIONS
import UserNotifications

internal extension Permission {
    
    var statusUserNotifications: PermissionStatus {
        guard #available(iOS 10.0, *) else { fatalError() }
        return synchronousStatusUserNotifications
    }
    
    func requestUserNotifications(_ callback: @escaping Callback) {
        guard #available(iOS 10.0, *) else { fatalError() }
        guard case .userNotifications(let settings) = type else { fatalError() }
        
        var status: PermissionStatus = .notDetermined
        UNUserNotificationCenter.current().requestAuthorization(options: settings) { (isGranted, error) in
            if error != nil {
                status = .denied
            } else {
                status = isGranted ? .authorized : .denied
            }
            callback(status)
        }
    }
    
    fileprivate var synchronousStatusUserNotifications: PermissionStatus {
        guard #available(iOS 10.0, *) else { fatalError() }
        let semaphore = DispatchSemaphore(value: 0)
        
        var status: PermissionStatus = .notDetermined
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                status = .authorized
            case .denied:
                status = .denied
            case .notDetermined:
                status = .notDetermined
            }
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return status
    }
}
#endif
