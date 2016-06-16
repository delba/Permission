//
// Motion.swift
//
// Copyright (c) 2015-2016 Damien (http://delba.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import CoreMotion

private let MotionManager = CMMotionActivityManager()

extension Permission {
    var statusMotion: PermissionStatus {
        if UserDefaults.standard().requestedMotion {
            return synchronousStatusMotion
        }
        
        return .notDetermined
    }
    
    func requestMotion(callback: Callback?) {
        UserDefaults.standard().requestedMotion = true
        
        let now = Date()
        
        MotionManager.queryActivityStarting(from: now, to: now, to: .main()) { activities, error in
            let status: PermissionStatus
            
            if  let error = error where error.code == Int(CMErrorMotionActivityNotAuthorized.rawValue) {
                status = .denied
            } else {
                status = .authorized
            }
            
            MotionManager.stopActivityUpdates()
            
            callback?(status)
        }
    }
    
    private var synchronousStatusMotion: PermissionStatus {
        let semaphore = DispatchSemaphore(value: 0)
        
        var status: PermissionStatus = .notDetermined
        
        let now = Date()
        
        MotionManager.queryActivityStarting(from: now, to: now, to: OperationQueue(.background)) { activities, error in
            if  let error = error where error.code == Int(CMErrorMotionActivityNotAuthorized.rawValue) {
                status = .denied
            } else {
                status = .authorized
            }
            
            MotionManager.stopActivityUpdates()
            
            semaphore.signal()
        }
        
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return status
    }
    
}
