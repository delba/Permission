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
    var statusUserNotifications: Status {
        guard #available(iOS 10, *) else { fatalError() }
        
        if UserDefaults.standard.requestedUserNotifications {
            return synchronousStatusUserNotifications
        }
        
        return .notDetermined
    }
    
    func requestUserNotifications(_ callback: @escaping Callback) {
        guard #available(iOS 10, *), case .userNotifications(let options) = type else { fatalError() }
        
        UserDefaults.standard.requestedUserNotifications = true
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            let status: Status = granted ? .authorized : .denied
            callback(status)
        }
    }
    
    fileprivate var synchronousStatusUserNotifications: Status {
        guard #available(iOS 10, *) else { fatalError() }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var status: Status = .notDetermined
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined: status = .notDetermined
            case .denied:        status = .denied
            case .authorized:    status = .authorized
            }
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return status
    }
}
#endif
