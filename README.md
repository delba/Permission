<p align="center">
  <img src="https://github.com/delba/Permission/raw/assets/Permission@2x.png">
</p>

<p align="center">
  <a href="https://travis-ci.org/delba/Permission"><img alt="Travis Status" src="https://img.shields.io/travis/delba/Permission.svg"/></a>
  <a href="https://img.shields.io/cocoapods/v/Permission.svg"><img alt="CocoaPods compatible" src="https://img.shields.io/cocoapods/v/Permission.svg"/></a>
  <a href="https://github.com/Carthage/Carthage"><img alt="Carthage compatible" src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"/></a>
</p>

**Permission** exposes a unified API to request permissions on iOS.

<p align="center">
    <a href="#usage">Usage</a> • <a href="#example">Example</a> • <a href="#installation">Installation</a> • <a href="#license">License</a>
</p>

## Usage

#### Permission

> [`Permission.swift`](https://github.com/delba/Permission/blob/master/Source/Permission.swift)
> [`PermissionStatus.swift`](https://github.com/delba/Permission/blob/master/Source/PermissionStatus.swift)

```swift
let permission: Permission = .contacts

print(permission.status) // .notDetermined

permission.request { status in
    switch status {
    case .authorized:    print("authorized")
    case .denied:        print("denied")
    case .disabled:      print("disabled")
    case .notDetermined: print("not determined")
    }
}
```

##### Supported Permissions

> [`PermissionType.swift`](https://github.com/delba/Permission/blob/master/Source/PermissionType.swift)
> [`Types/`](https://github.com/delba/Permission/tree/master/Source/Types)

- [`Bluetooth`](https://github.com/delba/Permission/blob/master/Source/Types/Bluetooth.swift)
- [`Camera`](https://github.com/delba/Permission/blob/master/Source/Types/Camera.swift)
- [`Contacts`](https://github.com/delba/Permission/blob/master/Source/Types/Contacts.swift)
- [`Events`](https://github.com/delba/Permission/blob/master/Source/Types/Events.swift)
- [`Motion`](https://github.com/delba/Permission/blob/master/Source/Types/Motion.swift)
- [`Microphone`](https://github.com/delba/Permission/blob/master/Source/Types/Microphone.swift)
- [`Notifications`](https://github.com/delba/Permission/blob/master/Source/Types/Notifications.swift)
- [`Photos`](https://github.com/delba/Permission/blob/master/Source/Types/Photos.swift)
- [`Reminders`](https://github.com/delba/Permission/blob/master/Source/Types/Reminders.swift)
- [`LocationAlways`](https://github.com/delba/Permission/blob/master/Source/Types/LocationAlways.swift)
- [`LocationWhenInUse`](https://github.com/delba/Permission/blob/master/Source/Types/LocationWhenInUse.swift)
- [`MediaLibrary`](https://github.com/delba/Permission/blob/master/Source/Types/MediaLibrary.swift)
- [`SpeechRecognizer`](https://github.com/delba/Permission/blob/master/Source/Types/SpeechRecognizer.swift)
- [`Siri`](https://github.com/delba/Permission/blob/master/Source/Types/Siri.swift)

#### PermissionAlert

> [`PermissionAlert.swift`](https://github.com/delba/Permission/blob/master/Source/PermissionAlert.swift)

##### Denied and disabled alerts

When you first request a permission, a system alert is presented to the user.
If you request a permission that was denied/disabled, a `PermissionAlert` will be presented.
You might want to change the default `title`, `message`, `cancel` and `settings` text:

```swift
let alert = permission.deniedAlert // or permission.disabledAlert

alert.title    = "Please allow access to your contacts"
alert.message  = nil
alert.cancel   = "Cancel"
alert.settings = "Settings"
```

Set `permission.presentDeniedAlert = false` or `permission.presentDisabledAlert = false` if you don't want to present these alerts.

##### Pre-permission alerts

In order not to burn your only chance of displaying the system alert, you can present a **pre-permission alert**. See this [article](http://techcrunch.com/2014/04/04/the-right-way-to-ask-users-for-ios-permissions/) for more informations.

```swift
permission.presentPrePermissionAlert = true

let alert = permission.prePermissionAlert

alert.title   = "Let Foo Access Photos?"
alert.message = "This lets you choose which photos you want to add to your Foo profile"
alert.cancel  = "Not now"
alert.confirm = "Give Access"
```

The system alert will only be presented if the user taps "Give Access".

#### PermissionSet

> [`PermissionSet.swift`](https://github.com/delba/Permission/blob/master/Source/PermissionSet.swift)

Use a `PermissionSet` to check the status of a group of `Permission` and to react when a permission is requested.

```swift
let permissionSet = PermissionSet(.contacts, .camera, .microphone, .photos)
permissionSet.delegate = self

print(permissionSet.status) // .notDetermined

// ...

func permissionSet(permissionSet: PermissionSet, willRequestPermission permission: Permission) {
    print("Will request \(permission)")
}

func permissionSet(permissionSet: PermissionSet, didRequestPermission permission: Permission) {
    switch permissionSet.status {
    case .authorized:    print("all the permissions are granted")
    case .denied:        print("at least one permission is denied")
    case .disabled:      print("at least one permission is disabled")
    case .notDetermined: print("at least one permission is not determined")
    }
}
```

#### PermissionButton

> [`PermissionButton`](https://github.com/delba/Permission/blob/master/Source/PermissionButton.swift)

A `PermissionButton` requests the permission when tapped and updates itself when its underlying permission status changes.

```swift
let button = PermissionButton(.photos)
```

`PermissionButton` is a subclass of `UIButton`. All the getters and setters of `UIButton` have their equivalent in `PermissionButton`.

```swift
button.setTitles([
    .authorized:    "Authorized",
    .denied:        "Denied",
    .disabled:      "Disabled",
    .notDetermined: "Not determined"
])

// button.setAttributedTitles
// button.setTitleColors
// button.setTitleShadowColors
// button.setImages
// button.setBackgroundImages
// etc.
```

#### Third-party libraries:

- [sunshinejr/**RxPermission**](https://github.com/sunshinejr/RxPermission) RxSwift bindings for Permissions API in iOS.

## Example

```swift
class PermissionsViewController: UIViewController, PermissionSetDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel()

        let contacts   = PermissionButton(.contacts)
        let camera     = PermissionButton(.camera)
        let microphone = PermissionButton(.microphone)
        let photos     = PermissionButton(.photos)

        contacts.setTitles([
            .notDetermined: "Contacts - NotDetermined"
            .authorized:    "Contacts - Authorized",
            .denied:        "Contacts - Denied"
        ])

        contacts.setTitleColors([
            .notDetermined: .black,
            .authorized:    .green,
            .denied:        .red
        ])

        // ...

        let permissionSet = PermissionSet(contacts, camera, microphone, photos)

        permissionSet.delegate = self

        label.text = String(describing: permissionSet.status)

        for subview in [label, contacts, camera, microphone, photos] {
            view.addSubview(subview)
        }
    }

    func permissionSet(permissionSet: PermissionSet, didRequestPermission permission: Permission) {
        label.text = String(permissionSet.status)
    }
}
```

<img align="center" src="https://raw.githubusercontent.com/delba/Permission/assets/permission.gif" />

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Permission into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "delba/Permission"
```

##### Configuration

Due to Apple's new policy regarding permission access, binaries may be rejected due to a perceived attempt
to access privacy-sensitive data without a usage key, and then further rejected for not actually requesting
permissions.

As a workaround, you can provide custom build flags _before_ building the dynamic framework to only compile
with permissions you request. This is done by adding a configuration file named `PermissionConfiguration.xcconfig`
to the root of your project. For convenience, you can use
`PermissionConfiguration.xcconfig` in the `Permission/` repo directory. Just comment out the permissions
you want to use, and compile the framework.

To compile with only notifications and photos permissions:
```
PERMISSION_BLUETOOTH         = // PERMISSION_BLUETOOTH
PERMISSION_CAMERA            = PERMISSION_CAMERA
PERMISSION_CONTACTS          = // PERMISSION_CONTACTS
PERMISSION_EVENTS            = // PERMISSION_EVENTS
PERMISSION_LOCATION          = // PERMISSION_LOCATION
PERMISSION_MICROPHONE        = // PERMISSION_MICROPHONE
PERMISSION_MOTION            = // PERMISSION_MOTION
PERMISSION_NOTIFICATIONS     = PERMISSION_NOTIFICATIONS
PERMISSION_PHOTOS            = // PERMISSION_PHOTOS
PERMISSION_REMINDERS         = // PERMISSION_REMINDERS
PERMISSION_SPEECH_RECOGNIZER = // PERMISSION_SPEECH_RECOGNIZER
PERMISSION_MEDIA_LIBRARY     = // PERMISSION_MEDIA_LIBRARY

// Do not modify this line. Instead, remove comments above as needed to enable the categories your app uses.
PERMISSION_FLAGS= $(PERMISSION_BLUETOOTH) $(PERMISSION_CAMERA) $(PERMISSION_CONTACTS) $(PERMISSION_EVENTS) $(PERMISSION_LOCATION) $(PERMISSION_MICROPHONE) $(PERMISSION_MOTION) $(PERMISSION_NOTIFICATIONS) $(PERMISSION_PHOTOS) $(PERMISSION_REMINDERS) $(PERMISSION_SPEECH_RECOGNIZER) $(PERMISSION_MEDIA_LIBRARY)

SWIFT_ACTIVE_COMPILATION_CONDITIONS = $(inherited) $(PERMISSION_FLAGS)
```

### Cocoapods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Permission into your Xcode project using CocoaPods, specify it in your `Podfile`. Due to Apple's new policy regarding permission access you need to specifically define what kind of permissions you want to access using subspecs. For example if you want to access the Camera and the Notifications you define the following:

```ruby
use_frameworks!

pod 'Permission/Camera'
pod 'Permission/Notifications'
```

Please see `Permission.podspec` for more information about which subspecs are available.

## License

Copyright (c) 2015-2019 Damien (http://delba.io)

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
