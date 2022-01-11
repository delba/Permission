//
//  LocationWhenInUsePrecise.swift
//  Permission
//
//  Created by user on 1/10/22.
//  Copyright © 2022 delba. All rights reserved.
//

#if PERMISSION_LOCATION
import CoreLocation

extension Permission {
    var statusLocationWhenInUsePrecise: PermissionStatus {
        let hasPrecision: Bool = {
            if #available(iOS 14.0, *), CLLocationManager().accuracyAuthorization != .fullAccuracy {
                return false
            }
            return true
        }()

        let status = statusLocationWhenInUse

        switch status {
        case .authorized: return hasPrecision ? .authorized : .denied
        default: return status
        }
    }
}
#endif
