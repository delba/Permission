//
//  SpeechRecognizer.swift
//  Permission
//
//  Created by BinaryBoy on 8/13/16.
//  Copyright © 2016 delba. All rights reserved.
//




import Speech

internal extension Permission {
    var statusSpeechRecognizer: PermissionStatus {
        if #available(iOS 10.0, *) {
            
            let status = SFSpeechRecognizer.authorizationStatus()
            
            switch status {
            case .authorized:          return .authorized
            case .restricted, .denied: return .denied
            case .notDetermined:       return .notDetermined
            }
        }else{
            fatalError()
            
        }
    }
    
    func requestSpeechRecognizer(callback: Callback) {
        
        guard let _ = Bundle.main().objectForInfoDictionaryKey(.requestedMicrophoneUsageDescription) else {
            print("WARNING: \(.requestedMicrophoneUsageDescription) not found in Info.plist")
            return
        }
        
        
        guard let _ = Bundle.main().objectForInfoDictionaryKey(.requestedSpeechRecognitionUsageDescription) else {
            print("WARNING: \(.requestedSpeechRecognitionUsageDescription) not found in Info.plist")
            return
        }
        
        
        if #available(iOS 10.0, *) {
            
            SFSpeechRecognizer.requestAuthorization { _ in
                callback(self.statusSpeechRecognizer)
                
            }
        } else {
            fatalError()
        }
    }
}

