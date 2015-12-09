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

import UIKit
import Contacts
import CoreLocation
import AVFoundation
import Photos
import EventKit

public enum PermissionStatus {
    case Authorized, Denied, Disabled, NotDetermined
}

public enum PermissionType {
    case Contacts, LocationAlways, LocationWhenInUse, Notifications, Microphone, Camera, Photos, Reminders, Events
}

private var permissions = NSCache()

public class Permission: NSObject {
    /// The permission type.
    public let type: PermissionType
    
    /// The permission status.
    public var status: PermissionStatus {
        switch type {
        case .Contacts: return statusContacts
        case .LocationAlways: return statusLocationAlways
        case .LocationWhenInUse: return statusLocationWhenInUse
        case .Notifications: return statusNotifications
        case .Microphone: return statusMicrophone
        case .Camera: return statusCamera
        case .Photos: return statusPhotos
        case .Reminders: return statusReminders
        case .Events: return statusEvents
        }
    }
    
    internal var callback: (PermissionStatus -> Void)!
    
    internal var sets = [PermissionSet]()
    
    private lazy var alert: PermissionAlert = PermissionAlert(permission: self)
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    private var locationStatusDidChange: [PermissionType: Bool] = [
        .LocationWhenInUse: false,
        .LocationAlways: false
    ]
    
    private var notificationTimer: NSTimer?
    
    /**
     Creates and return a new permission of the specified type.
     
     - parameter type: The permission type.
     
     - returns: A newly created permission.
     */
    public init(_ type: PermissionType) {
        self.type = type
    }
    
    /**
     Requests the permission.
     
     - parameter callback: The function to be triggered after the user responded to the request.
     */
    public func request(callback: PermissionStatus -> Void) {
        self.callback = callback
        
        permissions.setObject(self, forKey: type.hashValue)
        
        switch status {
        case .Authorized: callbacks(status)
        case .NotDetermined: requestAuthorization()
        case .Denied, .Disabled: presentAlert(status)
        }
    }
    
    /**
    Configures the alert for the specifed status.
    
    - parameter status: The status for which the alert is displayed.
    - parameter block:  The configuration block.
     */
    public func configureAlert(status: PermissionStatus, block: PermissionAlert -> Void) {
        guard [.Denied, .Disabled].contains(status) else { return }
        
        alert.status = status
        block(alert)
    }
    
    internal func callbacks(status: PermissionStatus) {
        callback(status)
        
        for set in sets {
            set.didRequestPermission(self)
        }
    }
}

// MARK: - Request Authorizations

internal extension Permission {
    private func requestAuthorization() {
        switch type {
        case .Contacts: requestContacts()
        case .LocationAlways: requestLocationAlways()
        case .LocationWhenInUse: requestLocationWhenInUse()
        case .Notifications: requestNotifications()
        case .Microphone: requestMicrophone()
        case .Camera: requestCamera()
        case .Photos: requestPhotos()
        case .Reminders: requestReminders()
        case .Events: requestEvents()
        }
    }
    
    private func presentAlert(status: PermissionStatus) {
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

// MARK: - Contacts

private extension Permission {
    var statusContacts: PermissionStatus {
        if #available(iOS 9.0, *) {
            switch CNContactStore.authorizationStatusForEntityType(.Contacts) {
            case .Authorized: return .Authorized
            case .Restricted, .Denied: return .Denied
            case .NotDetermined: return .NotDetermined
            }
        } else {
            switch ABAddressBookGetAuthorizationStatus() {
            case .Authorized: return .Authorized
            case .Restricted, .Denied: return .Denied
            case .NotDetermined: return .NotDetermined
            }
        }
    }
    
    func requestContacts() {
        if #available(iOS 9.0, *) {
            CNContactStore().requestAccessForEntityType(.Contacts) { _,_ in
                self.callbacks(self.status)
            }
        } else {
            ABAddressBookRequestAccessWithCompletion(nil) { _,_ in
                self.callbacks(self.status)
            }
        }
    }
}

// MARK: - LocationAlways

private extension Permission {
    var statusLocationAlways: PermissionStatus {
        guard CLLocationManager.locationServicesEnabled() else { return .Disabled }
        
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways: return .Authorized
        case .AuthorizedWhenInUse:
            let requested = UserDefaults.boolForKey(.requestedLocationAlways)
            return requested ? .Denied : .NotDetermined
        case .NotDetermined: return .NotDetermined
        case .Restricted, .Denied: return .Denied
        }
    }
    
    func requestLocationAlways() {
        guard let _ = NSBundle.mainBundle().objectForInfoDictionaryKey(.nsLocationAlwaysUsageDescription) else {
            print("WARNING: \(.nsLocationAlwaysUsageDescription) not found in Info.plist")
            return
        }
        
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            UserDefaults.setBool(true, forKey: .requestedLocationAlways)
            UserDefaults.synchronize()
        }
        
        locationManager.requestAlwaysAuthorization()
    }
}

// MARK: - LocationWhenInUse

private extension Permission {
    var statusLocationWhenInUse: PermissionStatus {
        guard CLLocationManager.locationServicesEnabled() else { return .Disabled }
        
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedWhenInUse, .AuthorizedAlways: return .Authorized
        case .Restricted, .Denied: return .Denied
        case .NotDetermined: return .NotDetermined
        }
    }
    
    func requestLocationWhenInUse() {
        guard let _ = NSBundle.mainBundle().objectForInfoDictionaryKey(.nsLocationWhenInUseUsageDescription) else {
            print("WARNING: \(.nsLocationWhenInUseUsageDescription) not found in Info.plist")
            return
        }

        locationManager.requestWhenInUseAuthorization()
    }
}

// MARK: - Notifications

private extension Permission {
    var statusNotifications: PermissionStatus {
        if let types = Application.currentUserNotificationSettings()?.types where types != .None {
            return .Authorized
        }
        
        let requested = UserDefaults.boolForKey(.requestedNotifications)
        
        return requested ? .Denied : .NotDetermined
    }
    
    func requestNotifications() {
        NotificationCenter.addObserver(self, selector: "requestingNotifications", name: UIApplicationWillResignActiveNotification, object: nil)
        notificationTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "finishedShowingNotificationPermission", userInfo: nil, repeats: false)
        Application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil))
    }
    
    @objc func requestingNotifications() {
        NotificationCenter.removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
        NotificationCenter.addObserver(self, selector: "doneRequestingNotifications", name: UIApplicationDidBecomeActiveNotification, object: nil)
        notificationTimer?.invalidate()
    }
    
    @objc func doneRequestingNotifications() {
        NotificationCenter.removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
        NotificationCenter.removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        notificationTimer?.invalidate()
        
        UserDefaults.setBool(true, forKey: .requestedNotifications)
        UserDefaults.synchronize()
        
        delay(0.1) { [weak self] in
            guard let this = self else { return }
            this.callbacks(this.status)
        }
    }
}

// MARK: - Microphone

private extension Permission {
    var statusMicrophone: PermissionStatus {
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.Denied: return .Denied
        case AVAudioSessionRecordPermission.Granted: return .Authorized
        default: return .NotDetermined
        }
    }
    
    func requestMicrophone() {
        AVAudioSession.sharedInstance().requestRecordPermission { _ in
            self.callbacks(self.status)
        }
    }
}

// MARK: - Camera

private extension Permission {
    var statusCamera: PermissionStatus {
        switch AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) {
        case .Authorized: return .Authorized
        case .Restricted, .Denied: return .Denied
        case .NotDetermined: return .NotDetermined
        }
    }
    
    func requestCamera() {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { _ in
            self.callbacks(self.status)
        }
    }
}

// MARK: - Photos

private extension Permission {
    var statusPhotos: PermissionStatus {
        switch PHPhotoLibrary.authorizationStatus() {
        case .Authorized: return .Authorized
        case .Denied, .Restricted: return .Denied
        case .NotDetermined: return .NotDetermined
        }
    }
    
    func requestPhotos() {
        PHPhotoLibrary.requestAuthorization { _ in
            self.callbacks(self.status)
        }
    }
}

// MARK: - Reminders

private extension Permission {
    var statusReminders: PermissionStatus {
        switch EKEventStore.authorizationStatusForEntityType(.Reminder) {
        case .Authorized: return .Authorized
        case .Restricted, .Denied: return .Denied
        case .NotDetermined: return .NotDetermined
        }
    }
    
    func requestReminders() {
        EKEventStore().requestAccessToEntityType(.Reminder) { _,_ in
            self.callbacks(self.status)
        }
    }
}

// MARK: - Events

private extension Permission {
    var statusEvents: PermissionStatus {
        switch EKEventStore.authorizationStatusForEntityType(.Event) {
        case .Authorized: return .Authorized
        case .Restricted, .Denied: return .Denied
        case .NotDetermined: return .NotDetermined
        }
    }
    
    func requestEvents() {
        EKEventStore().requestAccessToEntityType(.Event) { _,_ in
            self.callbacks(self.status)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension Permission: CLLocationManagerDelegate {
    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        guard locationStatusDidChange[type]! else {
            locationStatusDidChange[type] = true
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            guard let this = self else { return }
            this.callbacks(this.status)
        }
    }
}