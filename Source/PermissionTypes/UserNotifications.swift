//
//  UserNotifications.swift
//  Permission
//
//  Created by Andreas Grauel on 20.01.17.
//  Copyright © 2017 delba. All rights reserved.
//

#if PERMISSION_USER_NOTIFICATIONS
import UserNotifications

internal extension Permission {
    var statusUserNotifications: PermissionStatus {
        guard #available(iOS 10.0, *) else { fatalError() }
        var authorizationStatus: UNAuthorizationStatus?
        let group = DispatchGroup()
        
        group.enter()
        UNUserNotificationCenter.current().getNotificationSettings() {
            authorizationStatus = $0.authorizationStatus
            group.leave()
        }
        
        let _ = group.wait(timeout: DispatchTime.distantFuture)
        if let authorizationStatus = authorizationStatus {
            switch authorizationStatus {
            case .authorized: return .authorized
            case .denied: return .denied
            case .notDetermined: return .notDetermined
            }
        }
        return UserDefaults.standard.requestedNotifications ? .denied : .notDetermined
    }
    
    func requestUserNotifications(_ callback: Callback) {
        guard #available(iOS 10.0, *) else { fatalError() }
        guard case .userNotifications(let settings) = type else { fatalError() }
        
        NotificationCenter.default.addObserver(self, selector: #selector(requestingUserNotifications), name: .UIApplicationWillResignActive)
        UNUserNotificationCenter.current().requestAuthorization(options: settings, completionHandler: {_, _ in })
    }
    
    @objc func requestingUserNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive)
        NotificationCenter.default.addObserver(self, selector: #selector(finishedRequestingUserNotifications), name: .UIApplicationDidBecomeActive)
    }
    
    @objc func finishedRequestingUserNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive)
        
        UserDefaults.standard.requestedNotifications = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.callbacks(self.statusUserNotifications)
        }
    }
}
#endif
