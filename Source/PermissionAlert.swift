//
//  PermissionAlert.swift
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

public class PermissionAlert {
    /// The permission.
    private let permission: Permission
    
    /// The status of the permission.
    private var status: PermissionStatus { return permission.status }
    
    /// The domain of the permission.
    private var type: PermissionType { return permission.type }
    
    private var callbacks: Permission.Callback { return permission.callbacks }
    
    /// The title of the alert.
    public var title: String?
    
    /// Descriptive text that provides more details about the reason for the alert.
    public var message: String?
    
    /// The title of the cancel action.
    public var cancel: String?
    
    /// The title of the settings action.
    public var settings: String?
    
    /// The title of the confirm action.
    public var confirm: String?
    
    var controller: UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let action = UIAlertAction(title: cancel, style: .Cancel, handler: cancelHandler)
        controller.addAction(action)
        
        return controller
    }
    
    internal init(permission: Permission) {
        self.permission = permission
    }
    
    internal func present() {
        Queue.main {
            if let vc = Application.rootViewController {
                vc.presentViewController(self.controller, animated: true, completion: nil)
            }
        }
    }

    private func cancelHandler(action: UIAlertAction) {
        callbacks(status)
    }
}

internal class DisabledAlert: PermissionAlert {
    override init(permission: Permission) {
        super.init(permission: permission)
        
        title   = "\(permission.prettyDescription) is currently disabled"
        message = "Please enable access to \(permission.prettyDescription) in the Settings app."
        cancel  = "OK"
    }
}

internal class DeniedAlert: PermissionAlert {
    override var controller: UIAlertController {
        let controller = super.controller
        
        let action = UIAlertAction(title: settings, style: .Default, handler: settingsHandler)
        controller.addAction(action)
        
        return controller
    }
    
    override init(permission: Permission) {
        super.init(permission: permission)
        
        title    = "Permission for \(permission.prettyDescription) was denied"
        message  = "Please enable access to \(permission.prettyDescription) in the Settings app."
        cancel   = "Cancel"
        settings = "Settings"
    }
    
    @objc func settingsHandler() {
        NotificationCenter.removeObserver(self, name: UIApplicationDidBecomeActiveNotification)
        callbacks(status)
    }
    
    private func settingsHandler(action: UIAlertAction) {
        NotificationCenter.addObserver(self, selector: .settingsHandler, name: UIApplicationDidBecomeActiveNotification)
        
        if let URL = NSURL(string: UIApplicationOpenSettingsURLString) {
            Application.openURL(URL)
        }
    }
}

internal class InitialAlert: PermissionAlert {
    override var controller: UIAlertController {
        let controller = super.controller
        
        let action = UIAlertAction(title: confirm, style: .Default, handler: confirmHandler)
        controller.addAction(action)
        
        return controller
    }
    
    override init(permission: Permission) {
        super.init(permission: permission)
        
        title   = "\(Bundle.name) would like to access your \(permission.prettyDescription)"
        message = "Please enable access to \(permission.prettyDescription)."
        cancel  = "Cancel"
        confirm = "Confirm"
    }
    
    private func confirmHandler(action: UIAlertAction) {
        permission.requestAuthorization(callbacks)
    }
}