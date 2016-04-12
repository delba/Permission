//
//  Motion.swift
//
//  Copyright (c) 2015 Damien (http://delba.io)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import CoreMotion

private let MotionManager = CMMotionActivityManager()

extension Permission {
    var statusMotion: PermissionStatus {
        if Defaults.requestedMotion {
            return synchronousStatusMotion
        }
        
        return .NotDetermined
    }
    
    func requestMotion(callback: Callback?) {
        Defaults.requestedMotion = true
        
        let now = NSDate()
        
        MotionManager.queryActivityStartingFromDate(now, toDate: now, toQueue: .mainQueue()) { activities, error in
            let status: PermissionStatus
            
            if  let error = error where error.code == Int(CMErrorMotionActivityNotAuthorized.rawValue) {
                status = .Denied
            } else {
                status = .Authorized
            }
            
            MotionManager.stopActivityUpdates()
            
            callback?(status)
        }
    }
    
    private var synchronousStatusMotion: PermissionStatus {
        let semaphore = dispatch_semaphore_create(0)
        
        var status: PermissionStatus = .NotDetermined
        
        let now = NSDate()
        
        MotionManager.queryActivityStartingFromDate(now, toDate: now, toQueue: NSOperationQueue(.Background)) { activities, error in
            if  let error = error where error.code == Int(CMErrorMotionActivityNotAuthorized.rawValue) {
                status = .Denied
            } else {
                status = .Authorized
            }
            
            MotionManager.stopActivityUpdates()
            
            dispatch_semaphore_signal(semaphore)
        }
        
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return status
    }
    
}