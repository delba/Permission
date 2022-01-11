//
//  Tracking.swift
//  Permission
//
//  Created by user on 1/10/22.
//  Copyright © 2022 delba. All rights reserved.
//

#if PERMISSION_TRACKING
import AppTrackingTransparency

extension Permission {
    var statusTracking: PermissionStatus {
        guard #available(iOS 14.5, *) else { fatalError() }

        let status = ATTrackingManager.trackingAuthorizationStatus

        switch status {
        case .authorized:          return .authorized
        case .restricted, .denied: return .denied
        case .notDetermined:       return .notDetermined
        @unknown default:          return .notDetermined
        }
    }

    func requestTracking(_ callback: @escaping Callback) {
        guard #available(iOS 14.5, *) else { fatalError() }

        guard let _ = Bundle.main.object(forInfoDictionaryKey: .userTrackingUsageDescription) else {
            print("WARNING: \(String.userTrackingUsageDescription) not found in Info.plist")
            return
        }

        ATTrackingManager.requestTrackingAuthorization { _ in
            callback(self.statusTracking)
        }
    }
}
#endif
