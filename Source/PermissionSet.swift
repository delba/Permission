//
// PermissionSet.swift
//
// Copyright (c) 2015-2019 Damien (http://delba.io)
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

open class PermissionSet {

    /// The permissions in the set.
    public let permissions: Swift.Set<Permission>

    /// The delegate of the permission set.
    open weak var delegate: PermissionSetDelegate?

    /// The permission set status
    open var status: PermissionStatus {
        let statuses = permissions.map({ $0.status })

        for status in statuses where status == .denied {
            return .denied
        }

        for status in statuses where status == .disabled {
            return .disabled
        }

        for status in statuses where status == .notDetermined {
            return .notDetermined
        }

        return .authorized
    }

    /**
     Creates and returns a new permission set containing the specified buttons.
     
     - parameter buttons: The buttons contained by the set.
     
     - returns: A newly created set.
     */
    public convenience init(_ buttons: PermissionButton...) {
        self.init(buttons: buttons)
    }

    /**
     Creates and returns a new permission set containing the specified buttons.
     
     - parameter buttons: The buttons contained by the set.
     
     - returns: A newly created set.
     */
    public convenience init(_ buttons: [PermissionButton]) {
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

    private convenience init(buttons: [PermissionButton]) {
        let permissions = buttons.map({ $0.permission })

        self.init(permissions: permissions)
    }

    private init(permissions: [Permission]) {
        self.permissions = Swift.Set(permissions)
        self.permissions.forEach { $0.permissionSets.append(self) }
    }

    func willRequestPermission(_ permission: Permission) {
        delegate?.permissionSet(self, willRequestPermission: permission)
    }

    func didRequestPermission(_ permission: Permission) {
        delegate?.permissionSet(self, didRequestPermission: permission)
    }
}

extension PermissionSet: CustomStringConvertible {
    /// The textual representation of self.
    public var description: String {
        return [
            "\(status): [",
            permissions.map { "\t\($0)" }.joined(separator: ",\n"),
            "]"
        ].joined(separator: "\n")
    }
}

public protocol PermissionSetDelegate: class {
    /**
     Tells the delegate that the specified permission has been requested.
     
     - parameter permissionSet: The permission set containing the requested permission.
     - parameter permission:    The requested permission.
     */
    func permissionSet(_ permissionSet: PermissionSet, didRequestPermission permission: Permission)

    /**
     Tells the delegate that the specified permission will be requested.
     
     - parameter permissionSet: The permission set containing the requested permission.
     - parameter permission:    The requested permission.
     */
    func permissionSet(_ permissionSet: PermissionSet, willRequestPermission permission: Permission)
}

public extension PermissionSetDelegate {
    /**
     Tells the delegate that the specified permission has been requested.
     
     - parameter permissionSet: The permission set containing the requested permission.
     - parameter permission:    The requested permission.
     */
    func permissionSet(_ permissionSet: PermissionSet, didRequestPermission permission: Permission) {}

    /**
     Tells the delegate that the specified permission will be requested.
     
     - parameter permissionSet: The permission set containing the requested permission.
     - parameter permission:    The requested permission.
     */
    func permissionSet(_ permissionSet: PermissionSet, willRequestPermission permission: Permission) {}
}
