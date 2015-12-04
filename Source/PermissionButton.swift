//
//  PermissionButton.swift
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

public class PermissionButton: UIButton {
    /// The permission of the button.
    public let permission: Permission
    
    /// The permission type of the button.
    public var type: PermissionType { return permission.type }
    
    /// The permission status of the button.
    public var status: PermissionStatus { return permission.status }
    
    private var titles: [UIControlState: [PermissionStatus: String]] = [:]
    private var attributedTitles: [UIControlState: [PermissionStatus: NSAttributedString]] = [:]
    private var colors: [UIControlState: [PermissionStatus: UIColor]] = [:]
    
    // MARK: - Initialization
    
    /**
    Creates and returns a new button of the specified permission type.
    
    - parameter type: The permission type.
    
    - returns: A newly created button.
    */
    public init(_ type: PermissionType) {
        self.permission = Permission(type)
        
        super.init(frame: .zero)
        
        self.addTarget(self, action: "tapped:", forControlEvents: .TouchUpInside)
        self.addTarget(self, action: "highlight:", forControlEvents: .TouchDown)
    }
    
    /**
     Returns an object initialized from data in a given unarchiver.
     
     - parameter aDecoder: An unarchiver object.
     
     - returns: self, initialized using the data in decoder.
     */
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Titles
    
    /**
    Returns the title associated with the specified permission status and state.
    
    - parameter status: The permission status that uses the title.
    - parameter state:  The state that uses the title.
    
    - returns: The title for the specified permission status and state.
    */
    public func titleForStatus(status: PermissionStatus, andState state: UIControlState = .Normal) -> String? {
        return titles[state]?[status]
    }
    
    /**
    Sets the title to use for the specified state.
    
    - parameter title: The title to use for the specified state.
    - parameter state: The state that uses the specified title.
    */
    public override func setTitle(title: String?, forState state: UIControlState) {
        titles[state] = nil
        super.setTitle(title, forState: state)
    }
    
    /**
     Sets the title to use for the specified permission status and state.
     
     - parameter title:  The title to use for the specified state.
     - parameter status: The permission status that uses the specified title.
     - parameter state:  The state that uses the specified title.
     */
    public func setTitle(title: String?, forStatus status: PermissionStatus, andState state: UIControlState = .Normal) {
        guard [.Normal, .Highlighted].contains(state) else { return }
        
        if titles[state] == nil {
            titles[state] = [:]
        }
        
        titles[state]?[status] = title
    }
    
    /**
     Sets the titles to use for the specified permission statuses and state.
     
     - parameter titles: The titles to use for the specified statuses.
     - parameter state:  The state that uses the specifed titles.
     */
    public func setTitles(titles: [PermissionStatus: String?], forState state: UIControlState = .Normal) {
        guard [.Normal, .Highlighted].contains(state) else { return }
        
        if self.titles[state] == nil {
            self.titles[state] = [:]
        }
        
        for (status, title) in titles {
            self.titles[state]?[status] = title
        }
    }
    
    // MARK: - Attributed titles
    
    /**
    Returns the styled title associated with the specified permission status and state.
    
    - parameter status: The permission status that uses the styled title.
    - parameter state:  The state that uses the styled title.
    
    - returns: The title for the specified permission status and state.
    */
    public func attributedTitleForStatus(status: PermissionStatus, andState state: UIControlState = .Normal) -> NSAttributedString? {
        return attributedTitles[state]?[status]
    }
    
    /**
    Sets the styled title to use for the specified state.
    
    - parameter title: The styled text string to use for the title.
    - parameter state: The state that uses the specified title.
    */
    public override func setAttributedTitle(title: NSAttributedString?, forState state: UIControlState) {
        attributedTitles[state] = nil
        super.setAttributedTitle(title, forState: state)
    }
    
    /**
     Sets the styled title to use for the specifed permission status and state.
     
     - parameter title:  The styled text string to use for the title.
     - parameter status: The permission status that uses the specified title.
     - parameter state:  The state that uses the specified title.
     */
    public func setAttributedTitle(title: NSAttributedString?, forStatus status: PermissionStatus, andState state: UIControlState = .Normal) {
        guard [.Normal, .Highlighted].contains(state) else { return }
        
        if attributedTitles[state] == nil {
            attributedTitles[state] = [:]
        }
        
        attributedTitles[state]?[status] = title
    }
    
    /**
     Sets the styled titles to use for the specified permission statuses and state.
     
     - parameter titles: The titles to use for the specified statuses.
     - parameter state:  The state that uses the specified titles.
     */
    public func setAttributedTitles(titles: [PermissionStatus: NSAttributedString?], forState state: UIControlState = .Normal) {
        guard [.Normal, .Highlighted].contains(state) else { return }
        
        if attributedTitles[state] == nil {
            attributedTitles[state] = [:]
        }
        
        for (status, title) in titles {
            attributedTitles[state]?[status] = title
        }
    }
    
    // MARK: - Title colors
    
    /**
    Returns the title color used for a permission status and state.
    
    - parameter status: The permission status.
    - parameter state:  The state.
    
    - returns: The color of the title for the specified permission status and state. 
    */
    public func titleColorForStatus(status: PermissionStatus, andState state: UIControlState = .Normal) -> UIColor? {
        return colors[state]?[status]
    }
    
    /**
    Sets the color of the title to use for the specified state.
    
    - parameter color: The color of the title to use for the specified state.
    - parameter state: The state that uses the specified color.
    */
    public override func setTitleColor(color: UIColor?, forState state: UIControlState) {
        colors[state] = nil
        super.setTitleColor(color, forState: state)
    }
    
    /**
     Sets the color of the title to use for the specified permission status and state.
     
     - parameter color:  The color of the title to use for the specified permission status and state.
     - parameter status: The permission status that uses the specified color.
     - parameter state:  The state that uses the specified color.
     */
    public func setTitleColor(color: UIColor?, forStatus status: PermissionStatus, andState state: UIControlState = .Normal) {
        guard state == .Normal || state == .Highlighted else { return }
        
        if colors[state] == nil {
            colors[state] = [:]
        }
        
        colors[state]?[status] = color
    }
    
    /**
     Sets the colors of the title to use for the specified permission statuses and state.
     
     - parameter colors: The colors to use for the specified permission statuses.
     - parameter state:  The state that uses the specified colors.
     */
    public func setTitleColors(colors: [PermissionStatus: UIColor?], forState state: UIControlState = .Normal) {
        guard [.Normal, .Highlighted].contains(state) else { return }
        
        if self.colors[state] == nil {
            self.colors[state] = [:]
        }
        
        for (status, color) in colors {
            self.colors[state]?[status] = color
        }
    }
    
    // MARK: - PermissionAlert
    
    /**
    Configures the alert for the specifed status.
    
    - parameter status: The status for which the alert is displayed.
    - parameter block:  The configuration block.
    */
    public func configureAlert(status: PermissionStatus, block: PermissionAlert -> Void) {
        permission.configureAlert(status, block: block)
    }
    
    // MARK: - UIView
    
    /**
    Tells the view that its superview changed.
    */
    public override func didMoveToSuperview() {
        render(.Normal)
    }
}

private extension PermissionButton {
    func render(state: UIControlState = .Normal) {
        if let title = titles[state]?[status] {
            super.setTitle(title, forState: state)
        }
        
        if let color = colors[state]?[status] {
            super.setTitleColor(color, forState: state)
        }
    }
    
    @objc func highlight(button: PermissionButton) {
        render(.Highlighted)
    }
    
    @objc func tapped(button: PermissionButton) {
        permission.request { [weak self] _ in
            dispatch_async(dispatch_get_main_queue()) {
                self?.render()
            }
        }
    }
}