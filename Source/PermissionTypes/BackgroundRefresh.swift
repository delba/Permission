//
//  BackgroundRefresh.swift
//  Permission
//
//  Created by Eike Bartels on 04/08/2016.
//  Copyright © 2016 delba. All rights reserved.
//


import AVFoundation

internal extension Permission {
    var statusBackgroundRefresh: PermissionStatus {
        switch UIApplication.sharedApplication().backgroundRefreshStatus {
        case .Restricted, .Denied:
            return .Denied
        case .Available:
            return .Authorized
        }
    }
    
    func requestBackgroundRefresh(callback: Callback) {
        assert(false, "request for BackgroundRefresh is not available")
    }
}
