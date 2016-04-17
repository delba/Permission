//
//  Utilities.swift
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

internal let Application = UIApplication.sharedApplication()
internal let Defaults = NSUserDefaults.standardUserDefaults()
internal let NotificationCenter = NSNotificationCenter.defaultCenter()

extension UIApplication {
    var rootViewController: UIViewController? {
        let root = delegate?.window??.rootViewController
        return root?.presentedViewController ?? root // Handle presenting an alert over a modal screen
    }
}

extension UIControlState: Hashable {
    public var hashValue: Int { return Int(rawValue) }
}

internal extension String {
    static let nsLocationWhenInUseUsageDescription = "NSLocationWhenInUseUsageDescription"
    static let nsLocationAlwaysUsageDescription = "NSLocationAlwaysUsageDescription"
    
    static let requestedNotifications       = "permission.requestedNotifications"
    static let requestedLocationAlways      = "permission.requestedLocationAlways"
    static let requestedLocationWhenInUse   = "permission.requestedLocationWhenInUse"
    static let requestedMotion              = "permission.requestedMotion"
    static let requestedBluetooth           = "permission.requestedBluetooth"
}

internal extension Selector {
    static let tapped = #selector(PermissionButton.tapped(_:))
    static let highlight = #selector(PermissionButton.highlight(_:))
    static let settingsHandler = #selector(DeniedAlert.settingsHandler)
    static let requestingNotifications = #selector(Permission.requestingNotifications)
    static let finishedRequestingNotifications = #selector(Permission.finishedRequestingNotifications)
}

extension NSUserDefaults {
    var requestedLocationAlways: Bool {
        get {
            return boolForKey(.requestedLocationAlways)
        }
        set {
            setBool(newValue, forKey: .requestedLocationAlways)
            synchronize()
        }
    }
    
    var requestedNotifications: Bool {
        get {
            return boolForKey(.requestedNotifications)
        }
        set {
            setBool(newValue, forKey: .requestedNotifications)
            synchronize()
        }
    }
    
    var requestedMotion: Bool {
        get {
            return boolForKey(.requestedMotion)
        }
        set {
            setBool(newValue, forKey: .requestedMotion)
            synchronize()
        }
    }
    
    var requestedBluetooth: Bool {
        get {
            return boolForKey(.requestedBluetooth)
        }
        set {
            setBool(newValue, forKey: .requestedBluetooth)
            synchronize()
        }
    }
}

struct Queue {
    static func main(block: dispatch_block_t) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
    
    static func main(after seconds: Double, block: dispatch_block_t) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), block)
    }
}

extension NSOperationQueue {
    convenience init(_ qualityOfService: NSQualityOfService) {
        self.init()
        self.qualityOfService = qualityOfService
    }
}

internal extension NSNotificationCenter {
    func addObserver(observer: AnyObject, selector: Selector, name: String) {
        addObserver(observer, selector: selector, name: name, object: nil)
    }
    
    func removeObserver(observer: AnyObject, name: String) {
        removeObserver(observer, name: name, object: nil)
    }
}
