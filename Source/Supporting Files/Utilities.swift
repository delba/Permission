//
// Utilities.swift
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

extension UIApplication {
    fileprivate var topViewController: UIViewController? {
        var vc = delegate?.window??.rootViewController
        
        while let presentedVC = vc?.presentedViewController {
            vc = presentedVC
        }

        return vc
    }
    
    internal func presentViewController(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        topViewController?.present(viewController, animated: animated, completion: completion)
    }
}

extension Bundle {
    var name: String {
        return object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }
}

extension UIControl.State: Hashable {
    public var hashValue: Int { return Int(rawValue) }
}

internal extension String {
    static let locationWhenInUseUsageDescription = "NSLocationWhenInUseUsageDescription"
    static let locationAlwaysUsageDescription    = "NSLocationAlwaysUsageDescription"
    static let microphoneUsageDescription        = "NSMicrophoneUsageDescription"
    static let speechRecognitionUsageDescription = "NSSpeechRecognitionUsageDescription"
    static let photoLibraryUsageDescription      = "NSPhotoLibraryUsageDescription"
    static let cameraUsageDescription            = "NSCameraUsageDescription"
    static let mediaLibraryUsageDescription      = "NSAppleMusicUsageDescription"
    static let siriUsageDescription              = "NSSiriUsageDescription"
    
    
    static let requestedNotifications               = "permission.requestedNotifications"
    static let requestedLocationAlwaysWithWhenInUse = "permission.requestedLocationAlwaysWithWhenInUse"
    static let requestedMotion                      = "permission.requestedMotion"
    static let requestedBluetooth                   = "permission.requestedBluetooth"
    static let statusBluetooth                      = "permission.statusBluetooth"
    static let stateBluetoothManagerDetermined      = "permission.stateBluetoothManagerDetermined"
}

internal extension Selector {
    static let tapped = #selector(PermissionButton.tapped(_:))
    static let highlight = #selector(PermissionButton.highlight(_:))
    static let settingsHandler = #selector(DeniedAlert.settingsHandler)
}

extension UserDefaults {
    var requestedLocationAlwaysWithWhenInUse: Bool {
        get { return bool(forKey: .requestedLocationAlwaysWithWhenInUse) }
        set { set(newValue, forKey: .requestedLocationAlwaysWithWhenInUse) }
    }
    
    var requestedNotifications: Bool {
        get { return bool(forKey: .requestedNotifications) }
        set { set(newValue, forKey: .requestedNotifications) }
    }
    
    var requestedMotion: Bool {
        get { return bool(forKey: .requestedMotion) }
        set { set(newValue, forKey: .requestedMotion) }
    }
    
    var requestedBluetooth: Bool {
        get { return bool(forKey: .requestedBluetooth) }
        set { set(newValue, forKey: .requestedBluetooth) }
    }
    
    var statusBluetooth: PermissionStatus? {
        get { return PermissionStatus(string: string(forKey: .statusBluetooth)) }
        set { set(newValue?.rawValue, forKey: .statusBluetooth) }
    }
    
    var stateBluetoothManagerDetermined: Bool {
        get { return bool(forKey: .stateBluetoothManagerDetermined) }
        set { set(newValue, forKey: .stateBluetoothManagerDetermined) }
    }
}

extension OperationQueue {
    convenience init(_ qualityOfService: QualityOfService) {
        self.init()
        self.qualityOfService = qualityOfService
    }
}

internal extension NotificationCenter {
    func addObserver(_ observer: AnyObject, selector: Selector, name: NSNotification.Name?) {
        addObserver(observer, selector: selector, name: name!, object: nil)
    }
    
    func removeObserver(_ observer: AnyObject, name: NSNotification.Name?) {
        removeObserver(observer, name: name, object: nil)
    }
}
