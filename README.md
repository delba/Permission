<p align="center">
  <img src="https://github.com/delba/Sorry/raw/assets/Sorry@2x.png">
</p>

<p align="center">
  <a href="https://travis-ci.org/delba/Sorry"><img alt="Travis Status" src="https://img.shields.io/travis/delba/Sorry.svg"/></a>
  <a href="https://img.shields.io/cocoapods/v/Sorry.svg"><img alt="CocoaPods compatible" src="https://img.shields.io/cocoapods/v/Sorry.svg"/></a>
  <a href="https://github.com/Carthage/Carthage"><img alt="Carthage compatible" src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"/></a>
</p>

## Usage

### Permission

#### Initialization

```swift
let permission: Permission = .Contacts
```

The supported permission types are the following: `Contacts`, `LocationAlways`, `LocationWhenInUse`, `Notifications`, `Microphone`, `Camera`, `Photos`, `Reminders`, `Events`

#### Customize the alerts

You can customize the alerts `Sorry` will present to the user if you don't like the default ones:

```swift
permission.configureAlert(.Denied) { alert in
    alert.title = "You denied access to your contacts"
    alert.message = "Please allow access in the settings app"
    alert.cancel = "Cancel"
    alert.settings = "Settings"
}
```

> Note: Only the alerts with `Denied` and `Disabled` statuses can be configured.

#### Request the permission

```swift
permission.request { status in
    // Do something depending on status
}
```

The status can be either `Authorized`, `Denied`, `Disabled` or `NotDetermined`

### PermissionButton

`PermissionButton` requests the permission on tap and updates itself when the permission changes.

#### Initialization

```swift
let button = PermissionButton(.Contacts)
```

#### Customize the button

The button will update themselves when the permission status change:

```swift
button.setTitle("Authorized", forStatus: .Authorized, andState: .Normal)
button.setTitleColor(UIColor.redColor(), forStatus: .Denied)
// ...
```

#### Customize the alerts

```swift
button.configureAlert(.Denied) { alert in
    alert.title = "You denied access to your contacts"
}
```

#### PermissionSet

```swift
class PermissionsViewController: UIViewController, PermissionSetDelegate {

    override func viewDidLoad() {
        let photos = PermissionButton(.Photos)
        let events = PermissionButton(.Events)
        let camera = PermissionButton(.Camera)

        // ...

        let permissionSet = PermissionSet(photos, events, camera)
        permissionSet.delegate = self
    }

    func permissionSet(permissionSet: PermissionSet, didRequestPermission permission: Permission) {
        if permissionSet.status == .Authorized {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

}
```

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Sorry into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "delba/Sorry"
```

### Cocoapods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Sorry into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
use_frameworks!

pod 'Sorry'
```

## License

Copyright (c) 2015 Damien (http://delba.io)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
