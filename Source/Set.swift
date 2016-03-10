//
//  Set.swift
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

extension Permission {
    public class Set {
        
        /// The permissions in the set.
        public let permissions: Swift.Set<Permission>
        
        /// The delegate of the permission set.
        public var delegate: PermissionSetDelegate?
        
        /// The permission set status
        public var status: Permission.Status {
            let statuses = permissions.map({ $0.status })
            
            for status in statuses where status == .Denied {
                return .Denied
            }
            
            for status in statuses where status == .Disabled {
                return .Disabled
            }
            
            for status in statuses where status == .NotDetermined {
                return .NotDetermined
            }
            
            return .Authorized
        }
        
        /**
         Creates and returns a new permission set containing the specified buttons.
         
         - parameter buttons: The buttons contained by the set.
         
         - returns: A newly created set.
         */
        public convenience init(_ buttons: Permission.Button...) {
            self.init(buttons: buttons)
        }
        
        /**
         Creates and returns a new permission set containing the specified buttons.
         
         - parameter buttons: The buttons contained by the set.
         
         - returns: A newly created set.
         */
        public convenience init(_ buttons: [Permission.Button]) {
            self.init(buttons: buttons)
        }
        
        /**
         Creates and returns a new permission set containing the specified buttons.
         
         - parameter permissions: The permissions contained by the set.
         
         - returns: A newly created set.
         */
        public convenience init(_ permissions: Permission...) {
            self.init(permissions: permissions)
        }
        
        /**
         Creates and returns a new permission set containing the specified buttons.
         
         - parameter permissions: The permissions contained by the set.
         
         - returns: A newly created set.
         */
        public convenience init(_ permissions: [Permission]) {
            self.init(permissions: permissions)
        }
        
        private init(buttons: [Permission.Button]) {
            self.permissions = Swift.Set(buttons.map({ $0.permission }))
            
            for permission in permissions {
                permission.sets.append(self)
            }
        }
        
        private init(permissions: [Permission]) {
            self.permissions = Swift.Set(permissions)
            
            for permission in self.permissions {
                permission.sets.append(self)
            }
        }
        
        internal func didRequestPermission(permission: Permission) {
            delegate?.permissionSet(self, didRequestPermission: permission)
        }
    }
}

public protocol PermissionSetDelegate {
    /**
     Tells the delegate that the specified permission has been requested.
     
     - parameter permissionSet: The permission set containing the requested permission.
     - parameter permission:    The requested permission.
     */
    func permissionSet(permissionSet: Permission.Set, didRequestPermission permission: Permission)
}

public extension PermissionSetDelegate {
    /**
     Tells the delegate that the specified permission has been requested.
     
     - parameter permissionSet: The permission set containing the requested permission.
     - parameter permission:    The requested permission.
     */
    func permissionSet(permissionSet: Permission.Set, didRequestPermission permission: Permission) {}
}