//
//  Calendar.swift
//  Permission
//
//  Created by user on 1/10/22.
//  Copyright © 2022 delba. All rights reserved.
//

#if PERMISSION_CALENDAR
import EventKit

extension Permission {
    var statusCalendar: PermissionStatus {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)

        switch status {
        case .authorized:          return .authorized
        case .restricted, .denied: return .denied
        case .notDetermined:       return .notDetermined
        @unknown default:          return .notDetermined
        }
    }

    func requestCalendar(_ callback: @escaping Callback) {
        guard let _ = Bundle.main.object(forInfoDictionaryKey: .calendarsUsageDescription) else {
            print("WARNING: \(String.calendarsUsageDescription) not found in Info.plist")
            return
        }

        let eventStore = EKEventStore()
        eventStore.requestAccess(to: EKEntityType.event) { _,_  in
            callback(self.statusCalendar)
        }
    }
}
#endif
