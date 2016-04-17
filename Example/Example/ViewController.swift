//
//  ViewController.swift
//  Example
//
//  Created by Sunshinejr on 17.04.2016.
//  Copyright © 2016 Sunshinejr. All rights reserved.
//

import UIKit
import Permission

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let location   = PermissionButton(.LocationAlways)
        let camera     = PermissionButton(.Camera)
        let microphone = PermissionButton(.Microphone)
        let photos     = PermissionButton(.Photos)
        let buttons    = [location, camera, microphone, photos]
        
        buttons.forEach { $0.setTitles([
            .NotDetermined: $0.description,
            .Authorized: $0.description,
            .Denied: $0.description,
            .Disabled: $0.description
            ])}
        
        buttons.forEach { $0.setTitleColors([
            .NotDetermined: .blackColor(),
            .Authorized:    .greenColor(),
            .Denied:        .redColor(),
            .Disabled:      .blackColor()
            ])}
        
        let permissionSet = PermissionSet(buttons)
        permissionSet.delegate = self
        
        label.text = String(permissionSet.status)
        buttons.forEach { stackView.addArrangedSubview($0) }
    }
}

extension ViewController: PermissionSetDelegate {
    
    func permissionSet(permissionSet: PermissionSet, didRequestPermission permission: Permission) {
        label.text = String(permissionSet.status)
    }
}