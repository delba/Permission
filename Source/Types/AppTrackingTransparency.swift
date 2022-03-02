//
//  AppTrackingTransparency.swift
//  Permission
//
//  Created by Khanh Hoang Bui on 2/3/22.
//  Copyright © 2022 delba. All rights reserved.
//

#if PERMISSION_SIRI
import AppTrackingTransparency

extension Permission {
    var statusAppTrackingTransparency: PermissionStatus {
        guard #available(iOS 14.0, *) else { fatalError() }

        let status = ATTrackingManager.trackingAuthorizationStatus

        switch status {
        case .authorized:          return .authorized
        case .restricted, .denied: return .denied
        case .notDetermined:       return .notDetermined
        @unknown default:          return .notDetermined
        }
    }

    func requestAppTrackingTransparency(_ callback: @escaping Callback) {
        guard #available(iOS 14.0, *) else { fatalError() }

        guard let _ = Bundle.main.object(forInfoDictionaryKey: .appTrackingTransparencyUsageDescription) else {
            print("WARNING: \(String.appTrackingTransparencyUsageDescription) not found in Info.plist")
            return
        }

        ATTrackingManager.requestTrackingAuthorization { _ in
            callback(self.statusSiri)
        }
    }
}
#endif
