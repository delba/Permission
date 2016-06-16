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

private var notificationTimer: Timer?

internal extension Permission {
    var statusNotifications: PermissionStatus {
        guard case .notifications(let settings) = type else { fatalError() }
        
        if let types = Application.currentUserNotificationSettings()?.types where types.contains(settings.types) {
            return .authorized
        }
        
        return Defaults.requestedNotifications ? .denied : .notDetermined
    }
    
    func requestNotifications(callback: Callback) {
        guard case .notifications(let settings) = type else { fatalError() }
		
        NotificationCenter.addObserver(self, selector: .requestingNotifications, name: NSNotification.Name.UIApplicationWillResignActive.rawValue)
        notificationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: .finishedRequestingNotifications, userInfo: nil, repeats: false)
        
        Application.registerUserNotificationSettings(settings)
    }
    
    @objc func requestingNotifications() {
        NotificationCenter.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive.rawValue)
        NotificationCenter.addObserver(self, selector: .finishedRequestingNotifications, name: NSNotification.Name.UIApplicationDidBecomeActive.rawValue)
        notificationTimer?.invalidate()
    }
    
    @objc func finishedRequestingNotifications() {
        NotificationCenter.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive.rawValue)
        NotificationCenter.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive.rawValue)
        notificationTimer?.invalidate()
        
        Defaults.requestedNotifications = true
        
        DispatchQueue.main.after(DispatchTimeInterval(0.1)) {
            self.callbacks(self.statusNotifications)
        }
    }
}
