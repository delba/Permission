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
    public let permission: Permission
    public var type: PermissionType { return permission.type }
    public var status: PermissionStatus { return permission.status }
    
    private var titles: [UIControlState: [PermissionStatus: String]] = [:]
    private var attributedTitles: [UIControlState: [PermissionStatus: NSAttributedString]] = [:]
    private var colors: [UIControlState: [PermissionStatus: UIColor]] = [:]
    
    // MARK: - Initialization
    
    public init(_ type: PermissionType) {
        self.permission = Permission(type)
        
        super.init(frame: .zero)
        
        self.addTarget(self, action: "tapped:", forControlEvents: .TouchUpInside)
        self.addTarget(self, action: "highlight:", forControlEvents: .TouchDown)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Titles
    
    public override func setTitle(title: String?, forState state: UIControlState) {
        titles[state] = nil
        super.setTitle(title, forState: state)
    }
    
    public func setTitle(title: String?, forStatus status: PermissionStatus, andState state: UIControlState = .Normal) {
        guard [.Normal, .Highlighted].contains(state) else { return }
        
        if titles[state] == nil {
            titles[state] = [:]
        }
        
        titles[state]?[status] = title
    }
    
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
    
    public override func setAttributedTitle(title: NSAttributedString?, forState state: UIControlState) {
        attributedTitles[state] = nil
        super.setAttributedTitle(title, forState: state)
    }
    
    public func setAttributedTitle(title: NSAttributedString?, forStatus status: PermissionStatus, andState state: UIControlState = .Normal) {
        guard [.Normal, .Highlighted].contains(state) else { return }
        
        if attributedTitles[state] == nil {
            attributedTitles[state] = [:]
        }
        
        attributedTitles[state]?[status] = title
    }
    
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
    
    public override func setTitleColor(color: UIColor?, forState state: UIControlState) {
        colors[state] = nil
        super.setTitleColor(color, forState: state)
    }
    
    public func setTitleColor(color: UIColor?, forStatus status: PermissionStatus, andState state: UIControlState = .Normal) {
        guard state == .Normal || state == .Highlighted else { return }
        
        if colors[state] == nil {
            colors[state] = [:]
        }
        
        colors[state]?[status] = color
    }
    
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
    
    public func configureAlert(status: PermissionStatus, block: PermissionAlert -> Void) {
        permission.configureAlert(status, block: block)
    }
    
    // MARK: - UIView
    
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