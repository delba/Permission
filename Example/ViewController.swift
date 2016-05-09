//
//  ViewController.swift
//  Example
//
//  Created by Błażej Wdowikowski on 11/04/16.
//  Copyright © 2016 delba. All rights reserved.
//

import UIKit
import Permission

// MARK: - Extension
extension PermissionButton{
    /**
     For example purpouse
     
     - parameter title: title of resoursce you want to access
     */
    func setTitleAndColors(title:String){
        self.setTitles([
            .NotDetermined: "\(title) - NotDetermined",
            .Authorized:    "\(title) - Authorized",
            .Denied:        "\(title) - Denied"
            ])
        
        self.setTitleColors([
            .NotDetermined: UIColor(red:0.56, green:0.56, blue:0.58, alpha:1.00),
            .Authorized:    UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.00),
            .Denied:        UIColor(red:1.00, green:0.58, blue:0.00, alpha:1.00)
            ])
    }
}

class ViewController: UIViewController,PermissionSetDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var permissionButtonsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contacts   = PermissionButton(.Contacts)
        let camera     = PermissionButton(.Camera)
        let microphone = PermissionButton(.Microphone)
        let photos     = PermissionButton(.Photos)
        
        contacts.setTitleAndColors("Contacts")
        camera.setTitleAndColors("Camera")
        microphone.setTitleAndColors("Microphone")
        photos.setTitleAndColors("Photos")
        
        let permissionSet = PermissionSet(contacts, camera, microphone, photos)
        
        permissionSet.delegate = self
        
        statusLabel.text = String(permissionSet.status)
        
        for subview in [contacts, camera, microphone, photos] {
            permissionButtonsView.addSubview(subview)
            arrangeButton(subview, inView: permissionButtonsView)
        }
        
    }
    
    /**
     Fuction to arrange buttons in view
     
     - parameter button: button to arrage
     - parameter v:      view where will be putted
     */
    private func arrangeButton(button:UIButton, inView v:UIView){
        button.translatesAutoresizingMaskIntoConstraints = false
        var viewAbove = v
        var anchor = NSLayoutAttribute.Top
        if v.subviews.count > 1 {
            let almostLastView = v.subviews[v.subviews.count-2]
            viewAbove = almostLastView
            anchor = .Bottom
        }
        v.addConstraint(NSLayoutConstraint(
            item: button,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: v,
            attribute: .Width,
            multiplier: 1,
            constant: 0))
        
        button.addConstraint(NSLayoutConstraint(item: button,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .Height,
            multiplier: 1,
            constant: 30))
        
        v.addConstraint(NSLayoutConstraint(item: button,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: viewAbove,
            attribute: anchor,
            multiplier: 1,
            constant: 8))
        
        v.addConstraint(NSLayoutConstraint(item: button,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: v,
            attribute: .CenterX,
            multiplier: 1,
            constant: 0))
    }
    
    //MARK: PermissionSetDelegate
    func permissionSet(permissionSet: PermissionSet, didRequestPermission permission: Permission) {
        statusLabel.text = String(permissionSet.status)
    }
}

