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

    #if PERMISSION_CONTACTS
    /// The permission to access the user's contacts.
    @available(iOS 9.0, *)
    public static let contacts = Permission(type: .contacts)
    #endif
    
    #if PERMISSION_ADDRESS_BOOK
    /// The permission to access the user's address book. (Deprecated in iOS 9.0)
    public static let addressBook = Permission(type: .addressBook)
    #endif
    
    #if PERMISSION_LOCATION
    /// The permission to access the user's location when the app is in background.
    public static let locationAlways = Permission(type: .locationAlways)
    
    /// The permission to access the user's location when the app is in use.
    public static let locationWhenInUse = Permission(type: .locationWhenInUse)
    #endif
    
    #if PERMISSION_MICROPHONE
    /// The permission to access the microphone.
    public static let microphone = Permission(type: .microphone)
    #endif
    
    #if PERMISSION_CAMERA
    /// The permission to access the camera.
    public static let camera = Permission(type: .camera)
    #endif
    
    #if PERMISSION_PHOTOS
    /// The permission to access the user's photos.
    public static let photos = Permission(type: .photos)
    #endif
    
    #if PERMISSION_REMINDERS
    /// The permission to access the user's reminders.
    public static let reminders = Permission(type: .reminders)
    #endif
    
    #if PERMISSION_EVENTS
    /// The permission to access the user's events.
    public static let events = Permission(type: .events)
    #endif
    
    #if PERMISSION_BLUETOOTH
    /// The permission to access the user's bluetooth.
    public static let bluetooth = Permission(type: .bluetooth)
    #endif
    
    #if PERMISSION_MOTION
    /// The permission to access the user's motion.
    public static let motion = Permission(type: .motion)
    #endif
    
    #if PERMISSION_SPEECH_RECOGNIZER
    /// The permission to access the user's SpeechRecognizer.
    @available(iOS 10.0, *)
    public static let speechRecognizer = Permission(type: .speechRecognizer)
    #endif
    
    #if PERMISSION_MEDIA_LIBRARY
    /// The permission to access the user's MediaLibrary.
    @available(iOS 9.3, *)
    public static let mediaLibrary = Permission(type: .mediaLibrary)
    #endif
    
    #if PERMISSION_SIRI
    /// The permission to access the user's Siri.
    @available(iOS 10.0, *)
    public static let siri = Permission(type: .siri)
    #endif

    #if PERMISSION_NOTIFICATIONS
    /// The permission to send notifications.
    public static let notifications: Permission = {
        let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        return Permission(type: .notifications(settings))
    }()
    
    /// Variable used to retain the notifications permission.
    fileprivate static var _notifications: Permission?
    
    /// The permission to send notifications.
    public static func notifications(types: UIUserNotificationType, categories: Set<UIUserNotificationCategory>?) -> Permission {
        let settings   = UIUserNotificationSettings(types: types, categories: categories)
        let permission = Permission(type: .notifications(settings))
        _notifications = permission
        return permission
    }
    
    /// The permission to send notifications.
    public static func notifications(types: UIUserNotificationType) -> Permission {
        let settings   = UIUserNotificationSettings(types: types, categories: nil)
        let permission = Permission(type: .notifications(settings))
        _notifications = permission
        return permission
    }
    
    /// The permission to send notifications.
    public static func notifications(categories: Set<UIUserNotificationCategory>?) -> Permission {
        let settings  = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: categories)
        let permission = Permission(type: .notifications(settings))
        _notifications = permission
        return permission
    }
    #endif
    
    /// The permission domain.
    public let type: PermissionType
    
    /// The permission status.
    open var status: PermissionStatus {
        #if PERMISSION_CONTACTS
        if case .contacts = type { return statusContacts }
        #endif
        
        #if PERMISSION_ADDRESS_BOOK
        if case .addressBook = type { return statusAddressBook }
        #endif
        
        #if PERMISSION_LOCATION
        if case .locationAlways    = type { return statusLocationAlways }
        if case .locationWhenInUse = type { return statusLocationWhenInUse }
        #endif
        
        #if PERMISSION_NOTIFICATIONS
        if case .notifications = type { return statusNotifications }
        #endif
        
        #if PERMISSION_MICROPHONE
        if case .microphone = type { return statusMicrophone }
        #endif
        
        #if PERMISSION_CAMERA
        if case .camera = type { return statusCamera }
        #endif
        
        #if PERMISSION_PHOTOS
        if case .photos = type { return statusPhotos }
        #endif
        
        #if PERMISSION_REMINDERS
        if case .reminders = type { return statusReminders }
        #endif
        
        #if PERMISSION_EVENTS
        if case .events = type { return statusEvents }
        #endif
        
        #if PERMISSION_BLUETOOTH
        if case .bluetooth = type { return statusBluetooth }
        #endif
        
        #if PERMISSION_MOTION
        if case .motion = type { return statusMotion }
        #endif
        
        #if PERMISSION_SPEECH_RECOGNIZER
        if case .speechRecognizer = type { return statusSpeechRecognizer }
        #endif
        
        #if PERMISSION_MEDIA_LIBRARY
        if case .mediaLibrary = type { return statusMediaLibrary }
        #endif
        
        #if PERMISSION_SIRI
        if case .siri = type { return statusSiri }
        #endif
        
        fatalError()
    }
    
    /// Determines whether to present the pre-permission alert.
    open var presentPrePermissionAlert = false
    
    /// The pre-permission alert.
    open lazy var prePermissionAlert: PermissionAlert = {
        return PrePermissionAlert(permission: self)
    }()
    
    /// Determines whether to present the denied alert.
    open var presentDeniedAlert = true
    
    /// The alert when the permission was denied.
    open lazy var deniedAlert: PermissionAlert = {
        return DeniedAlert(permission: self)
    }()
    
    /// Determines whether to present the disabled alert.
    open var presentDisabledAlert = true
    
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
    open func request(_ callback: @escaping Callback) {
        self.callback = callback
        
        DispatchQueue.main.async {
            self.permissionSets.forEach { $0.willRequestPermission(self) }
        }
        
        let status = self.status
        
        switch status {
        case .authorized:    callbacks(status)
        case .notDetermined: presentPrePermissionAlert ? prePermissionAlert.present() : requestAuthorization(callbacks)
        case .denied:        presentDeniedAlert ? deniedAlert.present() : callbacks(status)
        case .disabled:      presentDisabledAlert ? disabledAlert.present() : callbacks(status)
        }
    }
    
    internal func requestAuthorization(_ callback: @escaping Callback) {
        #if PERMISSION_CONTACTS
        if case .contacts = type {
            requestContacts(callback)
            return
        }
        #endif
        
        #if PERMISSION_ADDRESS_BOOK
        if case .addressBook = type {
            requestAddressBook(callback)
            return
        }
        #endif
        
        #if PERMISSION_LOCATION
        if case .locationAlways    = type {
            requestLocationAlways(callback)
            return
        }
        
        if case .locationWhenInUse = type {
            requestLocationWhenInUse(callback)
            return
        }
        #endif
        
        #if PERMISSION_NOTIFICATIONS
        if case .notifications = type {
            requestNotifications(callback)
            return
        }
        #endif
        
        #if PERMISSION_MICROPHONE
        if case .microphone = type {
            requestMicrophone(callback)
            return
        }
        #endif
        
        #if PERMISSION_CAMERA
        if case .camera = type {
            requestCamera(callback)
            return
        }
        #endif
        
        #if PERMISSION_PHOTOS
        if case .photos = type {
            requestPhotos(callback)
            return
        }
        #endif
        
        #if PERMISSION_REMINDERS
        if case .reminders = type {
            requestReminders(callback)
            return
        }
        #endif
        
        #if PERMISSION_EVENTS
        if case .events = type {
            requestEvents(callback)
            return
        }
        #endif
        
        #if PERMISSION_BLUETOOTH
        if case .bluetooth = type {
            requestBluetooth(self.callback)
            return
        }
        #endif
        
        #if PERMISSION_MOTION
        if case .motion = type {
            requestMotion(self.callback)
            return
        }
        #endif
        
        #if PERMISSION_SPEECH_RECOGNIZER
        if case .speechRecognizer = type {
            requestSpeechRecognizer(callback)
            return
        }
        #endif
        
        #if PERMISSION_MEDIA_LIBRARY
        if case .mediaLibrary = type {
            requestMediaLibrary(callback)
            return
        }
        #endif
        
        #if PERMISSION_SIRI
        if case .siri = type {
            requestSiri(callback)
            return
        }
        #endif
        
        fatalError()
    }
    
    internal func callbacks(_ with: PermissionStatus) {
        DispatchQueue.main.async {
            self.callback?(self.status)
            self.permissionSets.forEach { $0.didRequestPermission(self) }
        }
    }
}

extension Permission {
    /// The textual representation of self.
    override open var description: String {
        return type.description
    }
    
    /// A textual representation of this instance, suitable for debugging.
    override open var debugDescription: String {
        return "\(type): \(status)"
    }
}
