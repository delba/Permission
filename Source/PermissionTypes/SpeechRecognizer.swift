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

        let status = SFSpeechRecognizer.authorizationStatus()
        
        switch status {
        case .Authorized:          return .Authorized
        case .Restricted, .Denied: return .Denied
        case .NotDetermined:       return .NotDetermined
        }
    }
    
    func requestSpeechRecognizer(callback: Callback) {

        SFSpeechRecognizer.requestAuthorization { _ in
                    callback(self.statusSpeechRecognizer)

            }
    }
}
