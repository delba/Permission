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

open class Permission: NSObject {
    public typealias Callback = (PermissionStatus) -> Void

    /// The permission to access the user's contacts.
    @available(iOS 9.0, *)
    open static let Contacts = Permission(type: .contacts)
    
    /// The permission to access the user's address book. (Deprecated in iOS 9.0)
    open static let AddressBook = Permission(type: .addressBook)
    
    /// The permission to access the user's location when the app is in background.
    open static let LocationAlways = Permission(type: .locationAlways)
    
    /// The permission to access the user's location when the app is in use.
    open static let LocationWhenInUse = Permission(type: .locationWhenInUse)
    
    /// The permission to access the microphone.
    open static let Microphone = Permission(type: .microphone)
    
    /// The permission to access the camera.
    open static let Camera = Permission(type: .camera)
    
    /// The permission to access the user's photos.
    open static let Photos = Permission(type: .photos)
    
    /// The permission to access the user's reminders.
    open static let Reminders = Permission(type: .reminders)
    
    /// The permission to access the user's events.
    open static let Events = Permission(type: .events)
    
    /// The permission to access the user's bluetooth.
    open static let Bluetooth = Permission(type: .bluetooth)
    
    /// The permission to access the user's motion.
    open static let Motion = Permission(type: .motion)
    
    /// The permission to access the user's SpeechRecognizer.
    @available(iOS 10.0, *)
    open static let SpeechRecognizer = Permission(type: .speechRecognizer)
    
    /// The permission to access the user's MediaLibrary.
    @available(iOS 9.3, *)
    open static let MediaLibrary = Permission(type: .mediaLibrary)

    /// The permission to send notifications.
    open static let Notifications: Permission = {
        let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        return Permission(type: .notifications(settings))
    }()
    
    /// Variable used to retain the notifications permission.
    fileprivate static var notifications: Permission?
    
    /// The permission to send notifications.
    open static func Notifications(_ types: UIUserNotificationType, categories: Set<UIUserNotificationCategory>?) -> Permission {
        let settings  = UIUserNotificationSettings(types: types, categories: categories)
        notifications = Permission(type: .notifications(settings))
        return notifications!
    }
    
    /// The permission to send notifications.
    open static func Notifications(_ types: UIUserNotificationType) -> Permission {
        let settings  = UIUserNotificationSettings(types: types, categories: nil)
        notifications = Permission(type: .notifications(settings))
        return notifications!
    }
    
    /// The permission to send notifications.
    open static func notifications(_ categories: Set<UIUserNotificationCategory>?) -> Permission {
        let settings  = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: categories)
        notifications = Permission(type: .notifications(settings))
        return notifications!
    }
    
    /// The permission domain.
    open let type: PermissionType
    
    /// The permission status.
    open var status: PermissionStatus {
        switch type {
        case .contacts:          return statusContacts
        case .addressBook:       return statusAddressBook
        case .locationAlways:    return statusLocationAlways
        case .locationWhenInUse: return statusLocationWhenInUse
        case .notifications:     return statusNotifications
        case .microphone:        return statusMicrophone
        case .camera:            return statusCamera
        case .photos:            return statusPhotos
        case .reminders:         return statusReminders
        case .events:            return statusEvents
        case .bluetooth:         return statusBluetooth
        case .motion:            return statusMotion
        case .speechRecognizer:  return statusSpeechRecognizer
        case .mediaLibrary:      return statusMediaLibrary
        }
    }
    
    /// Determines whether to present the pre-permission alert.
    open var presentPrePermissionAlert = false
    
    /// The pre-permission alert.
    open lazy var prePermissionAlert: PermissionAlert = {
        return PrePermissionAlert(permission: self)
    }()
    
    /// The alert when the permission was denied.
    open lazy var deniedAlert: PermissionAlert = {
        return DeniedAlert(permission: self)
    }()
    
    /// The alert when the permission is disabled.
    open lazy var disabledAlert: PermissionAlert = {
        return DisabledAlert(permission: self)
    }()
    
    internal var callback: Callback?
    
    internal var permissionSets: [PermissionSet] = []
    
    /**
     Creates and return a new permission for the specified domain.
     
     - parameter domain: The permission domain.
     
     - returns: A newly created permission.
     */
    fileprivate init(type: PermissionType) {
        self.type = type
    }
    
    /**
     Requests the permission.
     
     - parameter callback: The function to be triggered after the user responded to the request.
     */
    open func request(_ callback: Callback) {
        self.callback = callback
        
        DispatchQueue.main.async {
            self.permissionSets.forEach { $0.willRequestPermission(self) }
        }
        
        let status = self.status
        
        switch status {
        case .authorized:    callbackAsync(status)
        case .notDetermined: requestInitialAuthorization()
        case .denied:        deniedAlert.present()
        case .disabled:      disabledAlert.present()
        }
    }
    
    fileprivate func requestInitialAuthorization() {
        presentPrePermissionAlert ? prePermissionAlert.present() : requestAuthorization(callback!)
    }
    
    internal func requestAuthorization(_ callback: Callback) {
        switch type {
        case .contacts:          requestContacts(callback)
        case .addressBook:       requestAddressBook(callback)
        case .locationAlways:    requestLocationAlways(callback)
        case .locationWhenInUse: requestLocationWhenInUse(callback)
        case .notifications:     requestNotifications(callback)
        case .microphone:        requestMicrophone(callback)
        case .camera:            requestCamera(callback)
        case .photos:            requestPhotos(callback)
        case .reminders:         requestReminders(callback)
        case .events:            requestEvents(callback)
        case .bluetooth:         requestBluetooth(self.callback)
        case .motion:            requestMotion(self.callback)
        case .speechRecognizer:  requestSpeechRecognizer(callback)
        case .mediaLibrary:      requestMediaLibrary(callback)
        }
    }
    
    internal func callbackAsync(_ with: PermissionStatus) {
        DispatchQueue.main.async {
            self.callback?(self.status)
            self.permissionSets.forEach { $0.didRequestPermission(self) }
        }
    }
}

extension Permission {
    /// The textual representation of self.
    override open var description: String {
        return "\(type): \(status)"
    }
    
    /// The pretty textual representation of self. 
    internal var prettyDescription: String {
        switch type {
        case .locationAlways, .locationWhenInUse:
            return "Location"
        case .notifications:
            return "Notifications"
        default:
            return String(describing: type)
        }
    }
    
}
