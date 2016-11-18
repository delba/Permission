//
//  Permissionable.swift
//  Permission
//
//  Created by Gautier Gdx on 17/11/2016.
//  Copyright © 2016 delba. All rights reserved.
//

import UIKit

public protocol Permissionable: class {    
    static func alertController(title: String?,message: String?,type: PermissionType,status: PermissionStatus) -> Permissionable
    
    func addAction(title: String?, style: UIAlertActionStyle, handler: @escaping () -> Void)
}
