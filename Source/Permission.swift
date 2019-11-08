//
// Permission.swift
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

open class Permission: NSObject {
    public typealias Callback = (PermissionStatus) -> Void

    #if PERMISSION_CONTACTS
    /// The permission to access the user's contacts.
    public static let contacts = Permission(type: .contacts)
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
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        return Permission(type: .notifications(options))
    }()

    /// Variable used to retain the notifications permission.
    private static var _notifications: Permission?

    /// The permission to send notifications.
    public static func notifications(options: UNAuthorizationOptions) -> Permission {
        let permission = Permission(type: .notifications(options))
        _notifications = permission
        return permission
    }
    #endif

    /// The permission domain.
    public let type: PermissionType

    /// The permission status.
    open var status: PermissionStatus {
        switch type {
        #if PERMISSION_CONTACTS
        case .contacts: return statusContacts
        #endif

        #if PERMISSION_LOCATION
        case .locationAlways: return statusLocationAlways
        case .locationWhenInUse: return statusLocationWhenInUse
        #endif

        #if PERMISSION_NOTIFICATIONS
        case .notifications: return statusNotifications
        #endif

        #if PERMISSION_MICROPHONE
        case .microphone: return statusMicrophone
        #endif

        #if PERMISSION_CAMERA
        case .camera: return statusCamera
        #endif

        #if PERMISSION_PHOTOS
        case .photos: return statusPhotos
        #endif

        #if PERMISSION_REMINDERS
        case .reminders: return statusReminders
        #endif

        #if PERMISSION_EVENTS
        case .events: return statusEvents
        #endif

        #if PERMISSION_BLUETOOTH
        case .bluetooth: return statusBluetooth
        #endif

        #if PERMISSION_MOTION
        case .motion: return statusMotion
        #endif

        #if PERMISSION_SPEECH_RECOGNIZER
        case .speechRecognizer: return statusSpeechRecognizer
        #endif

        #if PERMISSION_MEDIA_LIBRARY
        case .mediaLibrary: return statusMediaLibrary
        #endif

        #if PERMISSION_SIRI
        case .siri: return statusSiri
        #endif

        case .never: fatalError()
        }
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

    var callback: Callback?

    var permissionSets: [PermissionSet] = []

    /**
     Creates and return a new permission for the specified type.
     
     - parameter type: The permission type.
     
     - returns: A newly created permission.
     */
    private init(type: PermissionType) {
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

    func requestAuthorization(_ callback: @escaping Callback) {
        switch type {
        #if PERMISSION_CONTACTS
        case .contacts: requestContacts(callback)
        #endif

        #if PERMISSION_LOCATION
        case .locationAlways: requestLocationAlways(callback)
        case .locationWhenInUse: requestLocationWhenInUse(callback)
        #endif

        #if PERMISSION_NOTIFICATIONS
        case .notifications: requestNotifications(callback)
        #endif

        #if PERMISSION_MICROPHONE
        case .microphone: requestMicrophone(callback)
        #endif

        #if PERMISSION_CAMERA
        case .camera: requestCamera(callback)
        #endif

        #if PERMISSION_PHOTOS
        case .photos: requestPhotos(callback)
        #endif

        #if PERMISSION_REMINDERS
        case .reminders: requestReminders(callback)
        #endif

        #if PERMISSION_EVENTS
        case .events: requestEvents(callback)
        #endif

        #if PERMISSION_BLUETOOTH
        case .bluetooth: requestBluetooth(self.callback)
        #endif

        #if PERMISSION_MOTION
        case .motion: requestMotion(self.callback)
        #endif

        #if PERMISSION_SPEECH_RECOGNIZER
        case .speechRecognizer: requestSpeechRecognizer(callback)
        #endif

        #if PERMISSION_MEDIA_LIBRARY
        case .mediaLibrary: requestMediaLibrary(callback)
        #endif

        #if PERMISSION_SIRI
        case .siri: requestSiri(callback)
        #endif

        case .never: fatalError()
        }
    }

    func callbacks(_ with: PermissionStatus) {
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
