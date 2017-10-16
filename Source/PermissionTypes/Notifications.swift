//
// Notifications.swift
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

#if PERMISSION_NOTIFICATIONS

import UserNotifications
    
internal extension Permission {
    var statusNotifications: PermissionStatus {
        if UIApplication.shared.currentUserNotificationSettings?.types.isEmpty == false {
            return .authorized
        }
        
        return UserDefaults.standard.requestedNotifications ? .denied : .notDetermined
    }
    
    func requestNotifications(_ callback: Callback) {
        NotificationCenter.default.addObserver(self, selector: #selector(requestingNotifications), name: .UIApplicationWillResignActive)

        guard case .userNotifications(let options, let categories) = type else { fatalError() }
        let center = UNUserNotificationCenter.current()
        if let categories = categories {
            center.setNotificationCategories(categories)
        }
        center.requestAuthorization(options: options) { (granted, error) in
            if error == nil{
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    self.callbacks(self.statusNotifications)
                }
            }
        }
    }
    
    @objc func requestingNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive)
        NotificationCenter.default.addObserver(self, selector: #selector(finishedRequestingNotifications), name: .UIApplicationDidBecomeActive)
    }
    
    @objc func finishedRequestingNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive)
        
        UserDefaults.standard.requestedNotifications = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.callbacks(self.statusNotifications)
        }
    }
}
#endif
