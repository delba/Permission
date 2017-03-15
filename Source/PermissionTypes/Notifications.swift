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
import ObjectiveC
private var timerKey: UInt8 = 0
    
internal extension Permission {
    private var timer: Timer? {
        get {
            return objc_getAssociatedObject(self, &timerKey) as? Timer
        }
        set(newValue) {
            objc_setAssociatedObject(self, &timerKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var statusNotifications: PermissionStatus {
        if let settings = UIApplication.shared.currentUserNotificationSettings, settings.types.isEmpty == false {
            return .authorized
        }
        return UserDefaults.standard.requestedNotifications ? .denied : .notDetermined
    }
    
    func requestNotifications(_ callback: Callback) {
        guard case .notifications(let settings) = type else { fatalError() }
        
        NotificationCenter.default.addObserver(self, selector: #selector(requestingNotifications), name: .UIApplicationWillResignActive)
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(finishedRequestingNotifications), userInfo: nil, repeats: false)
        
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
    
    @objc func requestingNotifications() {
        timer?.invalidate()
        
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
