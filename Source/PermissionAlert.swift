//
//  PermissionAlert.swift
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

import UIKit

public class PermissionAlert {
    /// The title of the alert.
    public var title: String? {
        get { return self.title }
        set(title) { strings[status]![.title] = title }
    }
    
    /// Descriptive text that provides more details about the reason for the alert.
    public var message: String? {
        get { return self.message }
        set(message) { strings[status]![.message] = message }
    }
    
    /// The title of the cancel action.
    public var cancel: String? {
        get { return self.cancel }
        set(cancel) { strings[status]![.cancel] = cancel }
    }
    
    /// The title of the settings action.
    public var settings: String? {
        get { return self.settings }
        set(settings) { strings[status]![.settings] = settings }
    }
    
    internal var status: PermissionStatus!
    
    private let permission: Permission
    private var strings: [PermissionStatus: [String: String]]
    
    internal init(permission: Permission) {
        self.permission = permission
        
        self.strings = [
            .Denied: [
                .title: "Permission for \(permission.type) was denied",
                .message: "Please enable access to \(permission.type) in the Settings app.",
                .cancel: "Cancel",
                .settings: "Settings"
            ],
            .Disabled: [
                .title: "\(permission.type) is currently disabled",
                .message: "Please enable access to \(permission.type) in the Settings app.",
                .cancel: "OK"
            ]
        ]
    }
    
    internal func controllerFor(status: PermissionStatus) -> UIAlertController {
        let strings = self.strings[status]!
        
        let alertController = UIAlertController(title: strings[.title], message: strings[.message], preferredStyle: .Alert)
        
        let cancel = UIAlertAction(title: strings[.cancel], style: .Cancel, handler: permission.cancelHandler)
        alertController.addAction(cancel)
        
        if status == .Denied {
            let settings = UIAlertAction(title: strings[.settings], style: .Default, handler: settingsHandler)
            alertController.addAction(settings)
        }
        
        return alertController
    }
    
    private func settingsHandler(action: UIAlertAction) {
        NotificationCenter.addObserver(permission, selector: "settingsHandler", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        if let URL = NSURL(string: UIApplicationOpenSettingsURLString) {
            Application.openURL(URL)
        }
    }
}