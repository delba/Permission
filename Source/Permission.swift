//
// Permission.swift
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

public class Permission: NSObject {
    public typealias Callback = PermissionStatus -> Void

    /// The permission to access the user's contacts.
    @available(iOS 9.0, *)
    public static let Contacts = Permission(.Contacts)
    
    /// The permission to access the user's address book. (Deprecated in iOS 9.0)
    public static let AddressBook = Permission(.AddressBook)
    
    /// The permission to access the user's location when the app is in background.
    public static let LocationAlways = Permission(.LocationAlways)
    
    /// The permission to access the user's location when the app is in use.
    public static let LocationWhenInUse = Permission(.LocationWhenInUse)
    
    /// The permission to access the microphone.
    public static let Microphone = Permission(.Microphone)
    
    /// The permission to access the camera.
    public static let Camera = Permission(.Camera)
    
    /// The permission to access the user's photos.
    public static let Photos = Permission(.Photos)
    
    /// The permission to access the user's reminders.
    public static let Reminders = Permission(.Reminders)
    
    /// The permission to access the user's events.
    public static let Events = Permission(.Events)
    
    /// The permission to access the user's bluetooth.
    public static let Bluetooth = Permission(.Bluetooth)
    
    /// The permission to access the user's motion.
    public static let Motion = Permission(.Motion)
    
    /// The permission to send notifications.
    public static let Notifications: Permission = {
        let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        return Permission(.Notifications(settings))
    }()
    
    /// The permission to access the backround refresh permission.
    public static let BackgroundRefresh = Permission(.BackgroundRefresh)
    
    /// Variable used to retain the notifications permission.
    private static var notifications: Permission?
    
    /// The permission to send notifications.
    @warn_unused_result
    public static func Notifications(types types: UIUserNotificationType, categories: Set<UIUserNotificationCategory>?) -> Permission {
        let settings  = UIUserNotificationSettings(forTypes: types, categories: categories)
        notifications = Permission(.Notifications(settings))
        return notifications!
    }
    
    /// The permission to send notifications.
    @warn_unused_result
    public static func Notifications(types types: UIUserNotificationType) -> Permission {
        let settings  = UIUserNotificationSettings(forTypes: types, categories: nil)
        notifications = Permission(.Notifications(settings))
        return notifications!
    }
    
    /// The permission to send notifications.
    @warn_unused_result
    public static func Notifications(categories categories: Set<UIUserNotificationCategory>?) -> Permission {
        let settings  = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: categories)
        notifications = Permission(.Notifications(settings))
        return notifications!
    }
    
    /// The permission domain.
    public let type: PermissionType
    
    /// The permission status.
    public var status: PermissionStatus {
        switch type {
        case .Contacts:          return statusContacts
        case .AddressBook:       return statusAddressBook
        case .LocationAlways:    return statusLocationAlways
        case .LocationWhenInUse: return statusLocationWhenInUse
        case .Notifications:     return statusNotifications
        case .Microphone:        return statusMicrophone
        case .Camera:            return statusCamera
        case .Photos:            return statusPhotos
        case .Reminders:         return statusReminders
        case .Events:            return statusEvents
        case .Bluetooth:         return statusBluetooth
        case .Motion:            return statusMotion
        case .BackgroundRefresh: return statusBackgroundRefresh
        }
    }
    
    /// Determines whether to present the pre-permission alert.
    public var presentPrePermissionAlert = false
    
    /// The pre-permission alert.
    public lazy var prePermissionAlert: PermissionAlert = {
        return PrePermissionAlert(permission: self)
    }()
    
    /// The alert when the permission was denied.
    public lazy var deniedAlert: PermissionAlert = {
        return DeniedAlert(permission: self)
    }()
    
    /// The alert when the permission is disabled.
    public lazy var disabledAlert: PermissionAlert = {
        return DisabledAlert(permission: self)
    }()
    
    internal var callback: Callback?
    
    internal var permissionSets: [PermissionSet] = []
    
    /**
     Creates and return a new permission for the specified domain.
     
     - parameter domain: The permission domain.
     
     - returns: A newly created permission.
     */
    private init(_ type: PermissionType) {
        self.type = type
    }
    
    /**
     Requests the permission.
     
     - parameter callback: The function to be triggered after the user responded to the request.
     */
    public func request(callback: Callback) {
        self.callback = callback
        
        Queue.main {
            self.permissionSets.forEach { $0.willRequestPermission(self) }
        }
        
        let status = self.status
        
        switch status {
        case .Authorized:    callbacks(status)
        case .NotDetermined: requestInitialAuthorization()
        case .Denied:        deniedAlert.present()
        case .Disabled:      disabledAlert.present()
        }
    }
    
    private func requestInitialAuthorization() {
        presentPrePermissionAlert ? prePermissionAlert.present() : requestAuthorization(callbacks)
    }
    
    internal func requestAuthorization(callback: Callback) {
        switch type {
        case .Contacts:          requestContacts(callback)
        case .AddressBook:       requestAddressBook(callback)
        case .LocationAlways:    requestLocationAlways(callback)
        case .LocationWhenInUse: requestLocationWhenInUse(callback)
        case .Notifications:     requestNotifications(callback)
        case .Microphone:        requestMicrophone(callback)
        case .Camera:            requestCamera(callback)
        case .Photos:            requestPhotos(callback)
        case .Reminders:         requestReminders(callback)
        case .Events:            requestEvents(callback)
        case .Bluetooth:         requestBluetooth(self.callback)
        case .Motion:            requestMotion(self.callback)
        case .BackgroundRefresh: requestBackgroundRefresh(callback)
        }
    }
    
    internal func callbacks(status: PermissionStatus) {
        Queue.main {
            self.callback?(status)
            self.permissionSets.forEach { $0.didRequestPermission(self) }
        }
    }
}

extension Permission {
    /// The textual representation of self.
    override public var description: String {
        return "\(type): \(status)"
    }
    
    /// The pretty textual representation of self. 
    internal var prettyDescription: String {
        switch type {
        case .LocationAlways, .LocationWhenInUse:
            return "Location"
        case .Notifications:
            return "Notifications"
        default:
            return String(type)
        }
    }
    
}