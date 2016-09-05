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
            case .Authorized:          return .Authorized
            case .Restricted, .Denied: return .Denied
            case .NotDetermined:       return .NotDetermined
            }
        }else{
            fatalError()
            
        }
    }
    
    func requestMediaLibrary(callback: Callback) {
        
        guard let _ = NSBundle.mainBundle().objectForInfoDictionaryKey(.requestedAppleMusicUsageDescription) else {
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

