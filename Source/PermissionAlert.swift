//
// PermissionAlert.swift
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

import UIKit

open class PermissionAlert {
    /// The permission.
    fileprivate let permission: Permission
    
    //the alert controller class
    fileprivate let alertClass: Permissionable.Type
    
    /// The status of the permission.
    fileprivate var status: PermissionStatus { return permission.status }
    
    /// The domain of the permission.
    fileprivate var type: PermissionType { return permission.type }
    
    fileprivate var callbacks: Permission.Callback { return permission.callbacks }
    
    /// The title of the alert.
    open var title: String?
    
    /// Descriptive text that provides more details about the reason for the alert.
    open var message: String?
    
    /// The title of the cancel action.
    open var cancel: String? {
        get { return cancelActionTitle }
        set { cancelActionTitle = newValue }
    }
    
    /// The title of the settings action.
    open var settings: String? {
        get { return defaultActionTitle }
        set { defaultActionTitle = newValue }
    }
    
    /// The title of the confirm action.
    open var confirm: String? {
        get { return defaultActionTitle }
        set { defaultActionTitle = newValue }
    }
    
    fileprivate var cancelActionTitle: String?
    fileprivate var defaultActionTitle: String?
    
    var controller: Permissionable {
        let controller = alertClass.alertController(title: title, message: message, type: self.type, status: self.status)
        
        controller.addAction(title: cancelActionTitle, style: .default, handler: cancelHandler)
        
        return controller
    }
    
    internal init(permission: Permission) {
        self.permission = permission
        self.alertClass = permission.alertClass
    }
    
    internal func present() {
        DispatchQueue.main.async {
            UIApplication.shared.presentViewController(self.controller as! UIViewController)
        }
    }

    fileprivate func cancelHandler() {
        callbacks(status)
    }
}

internal class DisabledAlert: PermissionAlert {
    override init(permission: Permission) {
        super.init(permission: permission)
        
        title   = "\(permission) is currently disabled"
        message = "Please enable access to \(permission) in the Settings app."
        cancel  = "OK"
    }
}

internal class DeniedAlert: PermissionAlert {
    override var controller: Permissionable {
        let controller = super.controller
        
        controller.addAction(title: defaultActionTitle, style: .cancel, handler: settingHandler)
        
        return controller
    }
    
    override init(permission: Permission) {
        super.init(permission: permission)
        
        title    = "Permission for \(permission) was denied"
        message  = "Please enable access to \(permission) in the Settings app."
        cancel   = "Cancel"
        settings = "Settings"
    }
    
    @objc func settingsHandler() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive)
        callbacks(status)
    }
    
    private func settingHandler() {
        NotificationCenter.default.addObserver(self, selector: .settingsHandler, name: .UIApplicationDidBecomeActive)
        
        if let URL = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.openURL(URL)
        }
    }
}

internal class PrePermissionAlert: PermissionAlert {
    override var controller: Permissionable {
        let controller = super.controller
        
        controller.addAction(title: defaultActionTitle, style: .cancel, handler: confirmHandler)
        
        return controller
    }
    
    override init(permission: Permission) {
        super.init(permission: permission)
        
        title   = "\(Bundle.main.name) would like to access your \(permission)"
        message = "Please enable access to \(permission)."
        cancel  = "Cancel"
        confirm = "Confirm"
    }
    
    fileprivate func confirmHandler() {
        permission.requestAuthorization(callbacks)
    }
}
