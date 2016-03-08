//
//  Permission.swift
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

import EventKit

public class Permission: NSObject {
    public enum Status {
        case Authorized, Denied, Disabled, NotDetermined
    }
    
    public enum Domain {
        case Contacts, LocationAlways, LocationWhenInUse, Notifications, Microphone, Camera, Photos, Reminders, Events
    }
    
    public static let Contacts          = Permission(.Contacts)
    public static let LocationAlways    = Permission(.LocationAlways)
    public static let LocationWhenInUse = Permission(.LocationWhenInUse)
    public static let Notifications     = Permission(.Notifications)
    public static let Microphone        = Permission(.Microphone)
    public static let Camera            = Permission(.Camera)
    public static let Photos            = Permission(.Photos)
    public static let Reminders         = Permission(.Reminders)
    public static let Events            = Permission(.Events)
    
    /// The permission domain.
    public let domain: Domain
    
    /// The permission status.
    public var status: Permission.Status {
        switch domain {
        case .Contacts:          return statusContacts
        case .LocationAlways:    return statusLocationAlways
        case .LocationWhenInUse: return statusLocationWhenInUse
        case .Notifications:     return statusNotifications
        case .Microphone:        return statusMicrophone
        case .Camera:            return statusCamera
        case .Photos:            return statusPhotos
        case .Reminders:         return statusReminders
        case .Events:            return statusEvents
        }
    }
    
    /// The alert when the permission was denied.
    public lazy var deniedAlert: PermissionAlert = {
        let alert = PermissionAlert(permission: self)
        alert.status = .Denied
        return alert
    }()
    
    /// The alert when the permission is disabled.
    public lazy var disabledAlert: PermissionAlert = {
        let alert = PermissionAlert(permission: self)
        alert.status = .Disabled
        return alert
    }()
    
    internal var callback: (Permission.Status -> Void)!
    
    internal var sets = [PermissionSet]()
    
    private lazy var alert: PermissionAlert = PermissionAlert(permission: self)
    
    internal lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    private var locationStatusDidChange: [Domain: Bool] = [
        .LocationWhenInUse: false,
        .LocationAlways: false
    ]
    
    internal var notificationTimer: NSTimer?
    
    /**
     Creates and return a new permission for the specified domain.
     
     - parameter domain: The permission domain.
     
     - returns: A newly created permission.
     */
    private init(_ domain: Domain) {
        self.domain = domain
    }
    
    /**
     Requests the permission.
     
     - parameter callback: The function to be triggered after the user responded to the request.
     */
    public func request(callback: Permission.Status -> Void) {
        self.callback = callback
        
        switch status {
        case .Authorized: callbacks(status)
        case .NotDetermined: requestAuthorization()
        case .Denied, .Disabled: presentAlert(status)
        }
    }
    
    internal func callbacks(status: Permission.Status) {
        callback(status)
        
        for set in sets {
            set.didRequestPermission(self)
        }
    }
}

// MARK: - Request Authorizations

internal extension Permission {
    private func requestAuthorization() {
        switch domain {
        case .Contacts:          requestContacts()
        case .LocationAlways:    requestLocationAlways()
        case .LocationWhenInUse: requestLocationWhenInUse()
        case .Notifications:     requestNotifications()
        case .Microphone:        requestMicrophone()
        case .Camera:            requestCamera()
        case .Photos:            requestPhotos()
        case .Reminders:         requestReminders()
        case .Events:            requestEvents()
        }
    }
    
    private func presentAlert(status: Permission.Status) {
        let controller = alert.controllerFor(status)
        
        dispatch_async(dispatch_get_main_queue()) {
            if let vc = Application.delegate?.window??.rootViewController {
                vc.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
    
    @objc private func settingsHandler() {
        NotificationCenter.removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        callbacks(status)
    }
    
    internal func cancelHandler(action: UIAlertAction) {
        callbacks(status)
    }
}

// MARK: - CLLocationManagerDelegate

extension Permission: CLLocationManagerDelegate {
    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        guard locationStatusDidChange[domain]! else {
            locationStatusDidChange[domain] = true
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            guard let this = self else { return }
            this.callbacks(this.status)
        }
    }
}