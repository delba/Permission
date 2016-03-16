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
        /// The permission.
        private let permission: Permission
        
        /// The status of the permission.
        private var status: Permission.Status {
            return permission.status
        }
        
        /// The domain of the permission.
        private var domain: Permission.Domain {
            return permission.domain
        }
        
        private var callback: Callback!
        
        /// The title of the alert.
        public var title: String?
        
        /// Descriptive text that provides more details about the reason for the alert.
        public var message: String?
        
        /// The title of the cancel action.
        public var cancel: String?
        
        var controller: UIAlertController {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            let action = UIAlertAction(title: cancel, style: .Cancel, handler: cancelHandler)
            controller.addAction(action)
            
            return controller
        }
        
        internal init(permission: Permission) {
            self.permission = permission
        }
        
        internal func present(callback: Callback) {
            self.callback = callback
            
            dispatch_async(dispatch_get_main_queue()) {
                if let vc = Application.delegate?.window??.rootViewController {
                    vc.presentViewController(self.controller, animated: true, completion: nil)
                }
            }
        }
    
        private func cancelHandler(action: UIAlertAction) {
            callback(status)
        }
    }

    class DisabledAlert: Alert {
        override init(permission: Permission) {
            super.init(permission: permission)
            
            title   = "\(domain) is currently disabled"
            message = "Please enable the access to your \(domain.description.lowercaseString) in the settings."
            cancel  = "OK"
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
            
            title    = "The access to the \(domain.description.lowercaseString) has been denied"
            message  = "Please enable the access to your \(domain.description.lowercaseString) in the settings."
            cancel   = "Cancel"
            settings = "Settings"
        }
        
        private func settingsHandler(action: UIAlertAction) {
            NotificationCenter.addObserver(self, selector: Selector("settingsHandler"), name: UIApplicationDidBecomeActiveNotification, object: nil)
            
            if let URL = NSURL(string: UIApplicationOpenSettingsURLString) {
                Application.openURL(URL)
            }
        }
    
        @objc private func settingsHandler() {
            NotificationCenter.removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
            callback(status)
        }
    }
}