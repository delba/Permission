//
// PermissionAlert.swift
//
// Copyright (c) 2015-2019 Damien (http://delba.io)
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

public struct PermissionAlertConfig {
    var title: String
    var message: String
    var name: String
    var cancel: String?
    var settings: String?
    var confirm: String?

    public init(title: String, message: String, name: String, cancel: String? = nil, settings: String? = nil, confirm: String? = nil) {
        self.title = title
        self.message = message
        self.name = name
        self.cancel = cancel
        self.settings = settings
        self.confirm = confirm
    }
}

public class PermissionAlert {
    /// The permission.
    fileprivate let permission: Permission

    /// The status of the permission.
    fileprivate var status: PermissionStatus { return permission.status }

    /// The type of the permission.
    private var type: PermissionType { return permission.type }

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

    var config: PermissionAlertConfig

    var controller: UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let action = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: cancelHandler)
        controller.addAction(action)

        return controller
    }

    public init(permission: Permission, config: PermissionAlertConfig? = nil) {
        self.permission = permission
        self.config = config ?? PermissionAlertConfig(title: "", message: "", name: permission.description)
    }

    func present() {
        DispatchQueue.main.async {
            UIApplication.shared.present(self.controller)
        }
    }

    private func cancelHandler(_ action: UIAlertAction) {
        callbacks(status)
    }
}

/// DisabledAlert
/// config:
///         - title
///         - message
///         - cancel
public class DisabledAlert: PermissionAlert {
    override public init(permission: Permission, config: PermissionAlertConfig? = nil) {
        super.init(permission: permission, config: config)

        self.config = config ?? PermissionAlertConfig(
            title: "%@ is currently disabled",
            message: "Please enable access to %@ in the Settings app.",
            name: permission.description,
            cancel: "OK")

        title   = String.init(format: self.config.title, self.config.name)
        message = String.init(format: self.config.message, self.config.name)
        cancel  = self.config.cancel
    }
}

/// DeniedAlert
/// config:
///         - title
///         - message
///         - cancel
///         - settings
public class DeniedAlert: PermissionAlert {
    override var controller: UIAlertController {
        let controller = super.controller

        let action = UIAlertAction(title: defaultActionTitle, style: .default, handler: settingsHandler)
        controller.addAction(action)

        if #available(iOS 9.0, *) {
            controller.preferredAction = action
        }

        return controller
    }

    override public init(permission: Permission, config: PermissionAlertConfig? = nil) {
        super.init(permission: permission, config: config)

        self.config = config ?? PermissionAlertConfig(
            title: "Permission for %@ was denied",
            message: "Please enable access to %@ in the Settings app.",
            name: permission.description,
            cancel: "Cancel",
            settings: "Settings")

        title    = String.init(format: self.config.title, self.config.name)
        message  = String.init(format: self.config.message,  self.config.name)
        cancel   = self.config.cancel
        settings = self.config.settings
    }

    @objc func settingsHandler() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification)
        callbacks(status)
    }

    private func settingsHandler(_ action: UIAlertAction) {
        NotificationCenter.default.addObserver(self, selector: .settingsHandler, name: UIApplication.didBecomeActiveNotification)

        if let URL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(URL)
        }
    }
}

/// PrePermissionAlert
/// config:
///         - title
///         - message
///         - cancel
///         - confirm
public class PrePermissionAlert: PermissionAlert {
    override var controller: UIAlertController {
        let controller = super.controller

        let action = UIAlertAction(title: defaultActionTitle, style: .default, handler: confirmHandler)
        controller.addAction(action)

        if #available(iOS 9.0, *) {
            controller.preferredAction = action
        }

        return controller
    }

    override public init(permission: Permission, config: PermissionAlertConfig? = nil) {
        super.init(permission: permission, config: config)

        self.config = config ?? PermissionAlertConfig(
            title: "%@ would like to access your %@",
            message: "Please enable access to %@.",
            name: permission.description,
            cancel: "Cancel",
            confirm: "Confirm")

        title   = String.init(format: self.config.title, Bundle.main.name, self.config.name)
        message = String.init(format: self.config.message, self.config.name)
        cancel  = self.config.cancel
        confirm = self.config.confirm
    }

    private func confirmHandler(_ action: UIAlertAction) {
        permission.requestAuthorization(callbacks)
    }
}
