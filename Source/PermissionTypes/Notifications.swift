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

#if PERMISSION_NOTIFICATION
private var notificationTimer: Timer?
#endif
    
internal extension Permission {
    var statusNotifications: PermissionStatus {
        #if PERMISSION_NOTIFICATION
        guard case .notifications(let settings) = type else { fatalError() }
        
        if let types = UIApplication.shared.currentUserNotificationSettings?.types , types.contains(settings.types) {
            return .authorized
        }
        
        return UserDefaults.standard.requestedNotifications ? .denied : .notDetermined
        #else
        invalidPermissionFatalError(type: .notifications(UIUserNotificationSettings()))
        #endif
    }
    
    func requestNotifications(_ callback: Callback) {
        #if PERMISSION_NOTIFICATION
        guard case .notifications(let settings) = type else { fatalError() }
        
        NotificationCenter.default.addObserver(self, selector: .requestingNotifications, name: .UIApplicationWillResignActive)
        notificationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: .finishedRequestingNotifications, userInfo: nil, repeats: false)
        
        UIApplication.shared.registerUserNotificationSettings(settings)
        #else
        callback(self.statusNotifications)
        #endif
    }
    
    #if PERMISSION_NOTIFICATION
    @objc func requestingNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: .UIApplicationWillResignActive)
        notificationCenter.addObserver(self, selector: .finishedRequestingNotifications, name: .UIApplicationDidBecomeActive)
        notificationTimer?.invalidate()
    }
    
    @objc func finishedRequestingNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: .UIApplicationWillResignActive)
        notificationCenter.removeObserver(self, name: .UIApplicationDidBecomeActive)
        notificationTimer?.invalidate()
        
        UserDefaults.standard.requestedNotifications = true

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.callbackAsync(self.statusNotifications)
        }
    }
    #endif
}
