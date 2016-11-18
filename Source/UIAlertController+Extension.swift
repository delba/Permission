//
//  UIAlertController+Extension.swift
//  Permission
//
//  Created by Gautier Gdx on 17/11/2016.
//  Copyright © 2016 delba. All rights reserved.
//

import UIKit


extension UIAlertController: Permissionable {
    
    public static func alertController(title: String?,message: String?,type: PermissionType,status: PermissionStatus) -> Permissionable {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        return alertViewController
    }
    
    public func addAction(title: String?, style: UIAlertActionStyle, handler: @escaping () -> Void) {
        let action = UIAlertAction(title: title, style: style) { _ in
            handler()
        }
        addAction(action)
    }
}
