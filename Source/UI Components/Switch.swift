//
// Switch.swift
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

open class Switch: UISwitch {
    
    /// The permission of the switch.
    open let permission: Permission
    
    /// The permission type of the button.
    open var type: Type { return permission.type }
    
    /// The permission status of the button.
    open var status: Status { return permission.status }
    
    /// The alert when the permission was denied.
    open var deniedAlert: Alert {
        return permission.deniedAlert
    }
    
    /// The alert when the permission is disabled.
    open var disabledAlert: Alert {
        return permission.disabledAlert
    }
    
    /// The textual representation of self.
    open override var description: String {
        return permission.description
    }

    // MARK: - Initialization
    
    /**
    Creates and returns a new switch for the specified permission.
     
    - parameter permission: The permission.
    
    - returns: A newly created switch.
    */
    public init(_ permission: Permission) {
        self.permission = permission
        
        super.init(frame: .zero)
        
        self.addTarget(self, action: #selector(Switch.valueChanged), for: .valueChanged)
    }
    
    /**
    Returns an object initialized from data in a given unarchiver.
     
    - parameter aDecoder: An unarchiver object.
     
    - returns: self, initialized using the data in decoder.
    */
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Tint colors
    
    open func tintColorForStatus(_ status: Status) -> UIColor? {
        return nil
    }
    
    open func setTintColor(_ color: UIColor?, forStatus: Status) {
        
    }
    
    open func setTintColors(_ colors: [Status: UIColor?]) {
        
    }
    
    // MARK: - Thumb tint colors
    
    open func thumbTintColorForStatus(_ status: Status) -> UIColor? {
        return nil
    }
    
    open func setThumbTintColor(_ color: UIColor?, forStatus: Status) {
        
    }
    
    open func setThumbTintColors(_ colors: [Status: UIColor?]) {
        
    }
    
    // MARK: - Images

    open func imageForStatus(_ status: Status) -> UIImage? {
        return nil
    }
    
    open func setImage(_ image: UIImage?, forStatus: Status) {
        
    }
    
    open func setImages(_ images: [Status: UIImage?]) {
        
    }
}

internal extension Switch {
    @objc func valueChanged(_ switch: Switch) {
        
    }
}
