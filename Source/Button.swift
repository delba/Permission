//
// Button.swift
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

open class Button: UIButton {

    /// The permission of the button.
    open let permission: Permission
    
    /// The permission domain of the button.
    open var domain: Type { return permission.type }
    
    /// The permission status of the button.
    open var status: Status { return permission.status }
    
    fileprivate var titles: [UIControlState: [Status: String]] = [:]
    fileprivate var attributedTitles: [UIControlState: [Status: NSAttributedString]] = [:]
    fileprivate var titleColors: [UIControlState: [Status: UIColor]] = [:]
    fileprivate var titleShadowColors: [UIControlState: [Status: UIColor]] = [:]
    fileprivate var images: [UIControlState: [Status: UIImage]] = [:]
    fileprivate var backgroundImages: [UIControlState: [Status: UIImage]] = [:]
    
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
    Creates and returns a new button for the specified permission.
    
    - parameter permission: The permission.
    
    - returns: A newly created button.
    */
    public init(_ permission: Permission) {
        self.permission = permission
        
        super.init(frame: .zero)
        
        self.addTarget(self, action: .tapped, for: .touchUpInside)
        self.addTarget(self, action: .highlight, for: .touchDown)
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
    open func titleForStatus(_ status: Status, andState state: UIControlState = UIControlState()) -> String? {
        return titles[state]?[status]
    }
    
    /**
    Sets the title to use for the specified state.
    
    - parameter title: The title to use for the specified state.
    - parameter state: The state that uses the specified title.
    */
    open override func setTitle(_ title: String?, for state: UIControlState) {
        titles[state] = nil
        super.setTitle(title, for: state)
    }
    
    /**
     Sets the title to use for the specified permission status and state.
     
     - parameter title:  The title to use for the specified state.
     - parameter status: The permission status that uses the specified title.
     - parameter state:  The state that uses the specified title.
     */
    open func setTitle(_ title: String?, forStatus status: Status, andState state: UIControlState = UIControlState()) {
        guard [.highlighted].contains(state) else { return }
        
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
    open func setTitles(_ titles: [Status: String?], forState state: UIControlState = UIControlState()) {
        guard [.highlighted].contains(state) else { return }
        
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
    open func attributedTitleForStatus(_ status: Status, andState state: UIControlState = UIControlState()) -> NSAttributedString? {
        return attributedTitles[state]?[status]
    }
    
    /**
    Sets the styled title to use for the specified state.
    
    - parameter title: The styled text string to use for the title.
    - parameter state: The state that uses the specified title.
    */
    open override func setAttributedTitle(_ title: NSAttributedString?, for state: UIControlState) {
        attributedTitles[state] = nil
        super.setAttributedTitle(title, for: state)
    }
    
    /**
     Sets the styled title to use for the specifed permission status and state.
     
     - parameter title:  The styled text string to use for the title.
     - parameter status: The permission status that uses the specified title.
     - parameter state:  The state that uses the specified title.
     */
    open func setAttributedTitle(_ title: NSAttributedString?, forStatus status: Status, andState state: UIControlState = UIControlState()) {
        guard [.highlighted].contains(state) else { return }
        
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
    open func setAttributedTitles(_ titles: [Status: NSAttributedString?], forState state: UIControlState = UIControlState()) {
        guard [.highlighted].contains(state) else { return }
        
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
    
    - parameter status: The permission status that uses the title color.
    - parameter state:  The state that uses the title color.
    
    - returns: The color of the title for the specified permission status and state.
    */
    open func titleColorForStatus(_ status: Status, andState state: UIControlState = UIControlState()) -> UIColor? {
        return titleColors[state]?[status]
    }
    
    /**
    Sets the color of the title to use for the specified state.
    
    - parameter color: The color of the title to use for the specified state.
    - parameter state: The state that uses the specified color.
    */
    open override func setTitleColor(_ color: UIColor?, for state: UIControlState) {
        titleColors[state] = nil
        super.setTitleColor(color, for: state)
    }
    
    /**
     Sets the color of the title to use for the specified permission status and state.
     
     - parameter color:  The color of the title to use for the specified permission status and state.
     - parameter status: The permission status that uses the specified color.
     - parameter state:  The state that uses the specified color.
     */
    open func setTitleColor(_ color: UIColor?, forStatus status: Status, andState state: UIControlState = UIControlState()) {
        guard [.highlighted].contains(state) else { return }
        
        if titleColors[state] == nil {
            titleColors[state] = [:]
        }
        
        titleColors[state]?[status] = color
    }
    
    /**
     Sets the colors of the title to use for the specified permission statuses and state.
     
     - parameter colors: The colors to use for the specified permission statuses.
     - parameter state:  The state that uses the specified colors.
     */
    open func setTitleColors(_ colors: [Status: UIColor?], forState state: UIControlState = UIControlState()) {
        guard [.highlighted].contains(state) else { return }
        
        if titleColors[state] == nil {
            titleColors[state] = [:]
        }
        
        for (status, color) in colors {
            titleColors[state]?[status] = color
        }
    }
    
    // MARK: - Title shadow colors
    
    /**
    Returns the shadow color of the title used for a permission status and state.
    
    - parameter status: The permission status that uses the title shadow color.
    - parameter state:  The state that uses the title shadow color.
    
    - returns: The color of the title's shadow for the specified permission status and state.
    */
    open func titleShadowColorForStatus(_ status: Status, andState state: UIControlState = UIControlState()) -> UIColor? {
        return titleShadowColors[state]?[status]
    }
    
    /**
     Sets the color of the title shadow to use for the specified state.
     
     - parameter color: The color of the title shadow to use for the specified state.
     - parameter state: The state that uses the specified color.
     */
    open override func setTitleShadowColor(_ color: UIColor?, for state: UIControlState) {
        titleShadowColors[state] = nil
        super.setTitleShadowColor(color, for: state)
    }
    
    /**
     Sets the color of the title shadow to use for the specified permission status and state.
     
     - parameter color:  The color of the title shadow to use for the specified permission status and state.
     - parameter status: The permission status that uses the specified color.
     - parameter state:  The state that uses the specified color.
     */
    open func setTitleShadowColor(_ color: UIColor?, forStatus status: Status, andState state: UIControlState = UIControlState()) {
        guard [.highlighted].contains(state) else { return }
        
        if titleShadowColors[state] == nil {
            titleShadowColors[state] = [:]
        }
        
        titleShadowColors[state]?[status] = color
    }
    
    /**
    Sets the colors of the title shadow to use for the specified permission statuses and state.
    
    - parameter colors: The colors to use for the specified permission statuses.
    - parameter state:  The state that uses the specified colors.
    */
    open func setTitleShadowColors(_ colors: [Status: UIColor?], forState state: UIControlState = UIControlState()) {
        guard [.highlighted].contains(state) else { return }
        
        if titleShadowColors[state] == nil {
            titleShadowColors[state] = [:]
        }
        
        for (status, color) in colors {
            titleShadowColors[state]?[status] = color
        }
    }
    
    // MARK: - Images
    
    /**
    Returns the image used for a permission status and state
    
    - parameter status: The permission status that uses the image.
    - parameter state:  The state that uses the image.
    
    - returns: The image used for the specified permission status and state.
    */
    open func imageForStatus(_ status: Status, andState state: UIControlState = UIControlState()) -> UIImage? {
        return images[state]?[status]
    }
    
    /**
     Sets the image to use for the specified state.
     
     - parameter image: The image to use for the specified state.
     - parameter state: The state that uses the specified image.
     */
    open override func setImage(_ image: UIImage?, for state: UIControlState) {
        images[state] = nil
        super.setImage(image, for: state)
    }
    
    /**
     Sets the image to use for the specified permission status and state.
     
     - parameter image:  The image to use for the specified permission status and state.
     - parameter status: The permission status that uses the specified image.
     - parameter state:  The state that uses the specified image.
     */
    open func setImage(_ image: UIImage?, forStatus status: Status, andState state: UIControlState = UIControlState()) {
        guard [.highlighted].contains(state) else { return }
        
        if images[state] == nil {
            images[state] = [:]
        }
        
        images[state]?[status] = image
    }
    
    /**
     Sets the images for the specified permission statuses and state.
     
     - parameter images: The images to use for the specified permission statuses.
     - parameter state:  The state that uses the specified images.
     */
    open func setImages(_ images: [Status: UIImage], forState state: UIControlState = UIControlState()) {
        guard [.highlighted].contains(state) else { return }
        
        if self.images[state] == nil {
            self.images[state] = [:]
        }
        
        for (status, image) in images {
            self.images[state]?[status] = image
        }
    }
    
    // MARK: - Background images
    
    /**
    Returns the background image used for a permission status and a button state.
    
    - parameter status: The permission status that uses the background image.
    - parameter state:  The state that uses the background image.
    
    - returns: The background image used for the specified permission status and state.
    */
    open func backgroundImageForStatus(_ status: Status, andState state: UIControlState = UIControlState()) -> UIImage? {
        return backgroundImages[state]?[status]
    }
    
    /**
     Sets the background image to use for the specified button state.
     
     - parameter image: The background image to use for the specified state.
     - parameter state: The state that uses the specified image.
     */
    open override func setBackgroundImage(_ image: UIImage?, for state: UIControlState) {
        backgroundImages[state] = nil
        super.setBackgroundImage(image, for: state)
    }
    
    /**
     Sets the background image to use for the specified permission status and button state.
     
     - parameter image:  The background image to use for the specified permission status and button state.
     - parameter status: The permission status that uses the specified image.
     - parameter state:  The state that uses the specified image.
     */
    open func setBackgroundImage(_ image: UIImage?, forStatus status: Status, andState state: UIControlState = UIControlState()) {
        guard [.highlighted].contains(state) else { return }
        
        if backgroundImages[state] == nil {
            backgroundImages[state] = [:]
        }
        
        backgroundImages[state]?[status] = image
    }
    
    /**
     Set the background images to use for the specified permission statuses and button state.
     
     - parameter images: The background images to use for the specified permission statuses.
     - parameter state:  The state that uses the specified images.
     */
    open func setBackgroundImages(_ images: [Status: UIImage], forState state: UIControlState = UIControlState()) {
        guard [.highlighted].contains(state) else { return }
        
        if backgroundImages[state] == nil {
            backgroundImages[state] = [:]
        }
        
        for (status, image) in images {
            backgroundImages[state]?[status] = image
        }
    }
    
    // MARK: - UIView
    
    /**
    Tells the view that its superview changed.
    */
    open override func didMoveToSuperview() {
        render(.normal)
    }
}

internal extension Button {
    @objc func highlight(_ button: Button) {
        render(.highlighted)
    }
    
    @objc func tapped(_ button: Button) {
        permission.request { [weak self] status in
            self?.render()
        }
    }
}

private extension Button {
    func render(_ state: UIControlState = UIControlState()) {
        if let title = titleForStatus(status, andState: state) {
            super.setTitle(title, for: state)
        }
        
        if let title = attributedTitleForStatus(status, andState: state) {
            super.setAttributedTitle(title, for: state)
        }
        
        if let color = titleColorForStatus(status, andState: state) {
            super.setTitleColor(color, for: state)
        }
        
        if let color = titleShadowColorForStatus(status, andState: state) {
            super.setTitleShadowColor(color, for: state)
        }
        
        if let image = imageForStatus(status, andState: state) {
            super.setImage(image, for: state)
        }
        
        if let image = backgroundImageForStatus(status, andState: state) {
            super.setBackgroundImage(image, for: state)
        }
    }
}
