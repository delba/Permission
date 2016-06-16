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

public class PermissionAlert {
    /// The permission.
    private let permission: Permission
    
    /// The status of the permission.
    private var status: PermissionStatus { return permission.status }
    
    /// The domain of the permission.
    private var type: PermissionType { return permission.type }
    
    private var callbacks: Permission.Callback { return permission.callbackAsync(with:) }
    
    /// The title of the alert.
    public var title: String?
    
    /// Descriptive text that provides more details about the reason for the alert.
    public var message: String?
    
    /// The title of the cancel action.
    public var cancel: String? {
        get { return cancelActionTitle }
        set { cancelActionTitle = newValue }
    }
    
    /// The title of the settings action.
    public var settings: String? {
        get { return defaultActionTitle }
        set { defaultActionTitle = newValue }
    }
    
    /// The title of the confirm action.
    public var confirm: String? {
        get { return defaultActionTitle }
        set { defaultActionTitle = newValue }
    }
    
    private var cancelActionTitle: String?
    private var defaultActionTitle: String?
    
    var controller: UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: cancelHandler)
        controller.addAction(action)
        
        return controller
    }
    
    internal init(permission: Permission) {
        self.permission = permission
    }
    
    internal func present() {
        DispatchQueue.main.async {
            UIApplication.shared().presentViewController(self.controller)
        }
    }

    private func cancelHandler(_ action: UIAlertAction) {
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
        
        let action = UIAlertAction(title: defaultActionTitle, style: .default, handler: settingsHandler)
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
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive.rawValue)
        callbacks(status)
    }
    
    private func settingsHandler(_ action: UIAlertAction) {
        NotificationCenter.default().addObserver(self, selector: .settingsHandler, name: NSNotification.Name.UIApplicationDidBecomeActive.rawValue)
        
        if let URL = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared().openURL(URL)
        }
    }
}

internal class PrePermissionAlert: PermissionAlert {
    override var controller: UIAlertController {
        let controller = super.controller
        
        let action = UIAlertAction(title: defaultActionTitle, style: .default, handler: confirmHandler)
        controller.addAction(action)
        
        return controller
    }
    
    override init(permission: Permission) {
        super.init(permission: permission)
        
        title   = "\(Bundle.main().name) would like to access your \(permission.prettyDescription)"
        message = "Please enable access to \(permission.prettyDescription)."
        cancel  = "Cancel"
        confirm = "Confirm"
    }
    
    private func confirmHandler(_ action: UIAlertAction) {
        permission.requestAuthorization(callbacks)
    }
}
