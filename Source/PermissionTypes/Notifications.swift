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

private var notificationTimer: NSTimer?

internal extension Permission {
    var statusNotifications: PermissionStatus {
        guard case .Notifications(let settings) = type else { fatalError() }
        
        if let types = Application.currentUserNotificationSettings()?.types where types.contains(settings.types) {
            return .Authorized
        }
        
        return Defaults.requestedNotifications ? .Denied : .NotDetermined
    }
    
    func requestNotifications(callback: Callback) {
        guard case .Notifications(let settings) = type else { fatalError() }
        
        NotificationCenter.addObserver(self, selector: .requestingNotifications, name: UIApplicationWillResignActiveNotification)
        notificationTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: .finishedRequestingNotifications, userInfo: nil, repeats: false)
        
        Application.registerUserNotificationSettings(settings)
    }
    
    @objc func requestingNotifications() {
        NotificationCenter.removeObserver(self, name: UIApplicationWillResignActiveNotification)
        NotificationCenter.addObserver(self, selector: .finishedRequestingNotifications, name: UIApplicationDidBecomeActiveNotification)
        notificationTimer?.invalidate()
    }
    
    @objc func finishedRequestingNotifications() {
        NotificationCenter.removeObserver(self, name: UIApplicationWillResignActiveNotification)
        NotificationCenter.removeObserver(self, name: UIApplicationDidBecomeActiveNotification)
        notificationTimer?.invalidate()
        
        Defaults.requestedNotifications = true
        
        Queue.main(after: 0.1) {
            self.callbacks(self.statusNotifications)
        }
    }
}
