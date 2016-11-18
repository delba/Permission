//
//  Permissionable.swift
//  Permission
//
//  Created by Gautier Gdx on 17/11/2016.
//  Copyright © 2016 delba. All rights reserved.
//

import UIKit

public protocol Permissionable: class {
    init(title: String?, message: String?, preferredStyle: UIAlertControllerStyle)
    
    func addAction(title: String?, style: UIAlertActionStyle, handler: @escaping () -> Void)
}
