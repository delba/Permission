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
internal extension Permission {
    var statusNotifications: PermissionStatus {
        if UIApplication.shared.currentUserNotificationSettings?.types.isEmpty == false {
            return .authorized
        }
        
        return UserDefaults.standard.requestedNotifications ? .denied : .notDetermined
    }
    
    func requestNotifications(_ callback: Callback) {
        guard case .notifications(let settings) = type else { fatalError() }
        
        NotificationCenter.default.addObserver(self, selector: #selector(requestingNotifications), name: UIApplication.willResignActiveNotification)
        
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
    
    @objc func requestingNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification)
        NotificationCenter.default.addObserver(self, selector: #selector(finishedRequestingNotifications), name: UIApplication.didBecomeActiveNotification)
    }
    
    @objc func finishedRequestingNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification)
        
        UserDefaults.standard.requestedNotifications = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.callbacks(self.statusNotifications)
        }
    }
}
#endif
