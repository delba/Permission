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
