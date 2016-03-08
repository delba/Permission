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

public typealias Callback = Permission.Status -> Void

public class Permission {
    public enum Status {
        case Authorized, Denied, Disabled, NotDetermined
    }
    
    public enum Domain {
        case Contacts
        case LocationAlways
        case LocationWhenInUse
        case Notifications
        case Microphone
        case Camera
        case Photos
        case Reminders
        case Events
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
    public lazy var deniedAlert: Permission.Alert = {
        let alert = Permission.Alert(permission: self)
        alert.status = .Denied
        return alert
    }()
    
    /// The alert when the permission is disabled.
    public lazy var disabledAlert: Permission.Alert = {
        let alert = Permission.Alert(permission: self)
        alert.status = .Disabled
        return alert
    }()
    
    internal var callback: Callback!
    
    internal var sets = [PermissionSet]()
    
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
    public func request(callback: Callback) {
        self.callback = callback
        
        let status = self.status
        
        switch status {
        case .Authorized:    callbacks(status)
        case .NotDetermined: requestAuthorization(callbacks)
        case .Denied:        deniedAlert.present(callbacks)
        case .Disabled:      disabledAlert.present(callbacks)
        }
    }
    
    // TODO: make private
    
    internal func callbacks(status: Permission.Status) {
        callback(status)
        
        for set in sets {
            set.didRequestPermission(self)
        }
    }
}

// MARK: - Request Authorizations

internal extension Permission {
    private func requestAuthorization(callback: Callback) {
        switch domain {
        case .Contacts:          requestContacts(callback)
        case .LocationAlways:    requestLocationAlways(callback)
        case .LocationWhenInUse: requestLocationWhenInUse(callback)
        case .Notifications:     requestNotifications(callback)
        case .Microphone:        requestMicrophone(callback)
        case .Camera:            requestCamera(callback)
        case .Photos:            requestPhotos(callback)
        case .Reminders:         requestReminders(callback)
        case .Events:            requestEvents(callback)
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

extension Permission: Hashable {
    public var hashValue: Int {
        return domain.hashValue
    }
}

public func ==(lhs: Permission, rhs: Permission) -> Bool {
    return lhs.hashValue == rhs.hashValue
}