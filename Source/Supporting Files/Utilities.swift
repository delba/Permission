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

internal let Application = UIApplication.shared()
internal let Defaults = UserDefaults.standard()
internal let NotificationCenter = Foundation.NotificationCenter.default()
internal let Bundle = Foundation.Bundle.main()

extension UIApplication {
    private var topViewController: UIViewController? {
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

extension Foundation.Bundle {
    var name: String {
        return objectForInfoDictionaryKey("CFBundleName") as? String ?? ""
    }
}

extension UIControlState: Hashable {
    public var hashValue: Int { return Int(rawValue) }
}

internal extension String {
    static let nsLocationWhenInUseUsageDescription = "NSLocationWhenInUseUsageDescription"
    static let nsLocationAlwaysUsageDescription = "NSLocationAlwaysUsageDescription"
    
    static let requestedNotifications               = "permission.requestedNotifications"
    static let requestedLocationAlwaysWithWhenInUse = "permission.requestedLocationAlwaysWithWhenInUse"
    static let requestedMotion                      = "permission.requestedMotion"
    static let requestedBluetooth                   = "permission.requestedBluetooth"
    
}

internal extension Selector {
    static let tapped = #selector(PermissionButton.tapped(_:))
    static let highlight = #selector(PermissionButton.highlight(_:))
    static let settingsHandler = #selector(DeniedAlert.settingsHandler)
    static let requestingNotifications = #selector(Permission.requestingNotifications)
    static let finishedRequestingNotifications = #selector(Permission.finishedRequestingNotifications)
}

extension UserDefaults {
    var requestedLocationAlwaysWithWhenInUse: Bool {
        get {
            return bool(forKey: .requestedLocationAlwaysWithWhenInUse)
        }
        set {
            set(newValue, forKey: .requestedLocationAlwaysWithWhenInUse)
            synchronize()
        }
    }
    
    var requestedNotifications: Bool {
        get {
            return bool(forKey: .requestedNotifications)
        }
        set {
            set(newValue, forKey: .requestedNotifications)
            synchronize()
        }
    }
    
    var requestedMotion: Bool {
        get {
            return bool(forKey: .requestedMotion)
        }
        set {
            set(newValue, forKey: .requestedMotion)
            synchronize()
        }
    }
    
    var requestedBluetooth: Bool {
        get {
            return bool(forKey: .requestedBluetooth)
        }
        set {
            set(newValue, forKey: .requestedBluetooth)
            synchronize()
        }
    }
}

extension DispatchTimeInterval {
    init(_ interval: TimeInterval) {
        self = DispatchTimeInterval.nanoseconds(Int(interval * 1_000_000_000.0))
    }
}

extension DispatchQueue {
    func after(_ interval: DispatchTimeInterval, execute: () -> Void) {
        after(when: DispatchTime.now() + interval, execute: execute)
    }
}

extension OperationQueue {
    convenience init(_ qualityOfService: QualityOfService) {
        self.init()
        self.qualityOfService = qualityOfService
    }
}

internal extension Foundation.NotificationCenter {
    func addObserver(_ observer: AnyObject, selector: Selector, name: String) {
        addObserver(observer, selector: selector, name: name, object: nil)
    }
    
    func removeObserver(_ observer: AnyObject, name: String) {
        removeObserver(observer, name: NSNotification.Name(rawValue: name), object: nil)
    }
}
