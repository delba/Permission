//
//  MediaLibrary.swift
//  Permission
//
//  Created by BinaryBoy on 8/25/16.
//  Copyright © 2016 delba. All rights reserved.
//




import MediaPlayer

internal extension Permission {
    var statusMediaLibrary: PermissionStatus {
        if #available(iOS 10.0, *) {
            
            let status = MPMediaLibrary.authorizationStatus()
            
            switch status {
            case .authorized:          return .authorized
            case .restricted, .denied: return .denied
            case .notDetermined:       return .notDetermined
            }
        }else{
            fatalError()
            
        }
    }
    
    func requestMediaLibrary(_ callback: Callback) {
        
        guard let _ = Bundle.main.object(forInfoDictionaryKey: .requestedAppleMusicUsageDescription) else {
            print("WARNING: \(.requestedAppleMusicUsageDescription) not found in Info.plist")
            return
        }

        if #available(iOS 10.0, *) {
            
            MPMediaLibrary.requestAuthorization { _ in
                callback(self.statusMediaLibrary)
                
            }
        } else {
            fatalError()
        }
    }
}

