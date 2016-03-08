//
//  Alert.swift
//
// Copyright (c) 2015 Damien (http://delba.io)
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

extension Permission {
    public class Alert {
        /// The title of the alert.
        public var title: String?
        
        /// Descriptive text that provides more details about the reason for the alert.
        public var message: String?
        
        /// The title of the cancel action.
        public var cancel: String?
        
        internal var status: Permission.Status!
        
        private let permission: Permission
        
        var controller: UIAlertController {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            let action = UIAlertAction(title: cancel, style: .Cancel, handler: permission.cancelHandler)
            controller.addAction(action)
            
            return controller
        }
        
        internal init(permission: Permission) {
            self.permission = permission
        }
        
        internal func present(callback: Callback) {
            // TODO: pass callback to settings handler and cancelHandler
            
            dispatch_async(dispatch_get_main_queue()) {
                if let vc = Application.delegate?.window??.rootViewController {
                    vc.presentViewController(self.controller, animated: true, completion: nil)
                }
            }
        }
    }

    class DeniedAlert: Alert {
        var settings: String?
        
        override var controller: UIAlertController {
            let controller = super.controller
            
            let action = UIAlertAction(title: settings, style: .Default, handler: settingsHandler)
            controller.addAction(action)
            
            return controller
        }
        
        override init(permission: Permission) {
            super.init(permission: permission)
            
            status = .Denied
            
            title    = "Permission for \(permission.domain) was denied"
            message  = "Please enable access to \(permission.domain) in the Settings app."
            cancel   = "Cancel"
            settings = "Settings"
        }
        
        private func settingsHandler(action: UIAlertAction) {
            NotificationCenter.addObserver(permission, selector: Selector("settingsHandler"), name: UIApplicationDidBecomeActiveNotification, object: nil)
            
            if let URL = NSURL(string: UIApplicationOpenSettingsURLString) {
                Application.openURL(URL)
            }
        }
    }

    class DisabledAlert: Alert {
        override init(permission: Permission) {
            super.init(permission: permission)
            
            status = .Disabled
            
            title   = "\(permission.domain) is currently disabled"
            message = "Please enable access to \(permission.domain) in the Settings app."
            cancel  = "OK"
        }
    }
}