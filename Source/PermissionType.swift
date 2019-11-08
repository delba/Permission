//
// PermissionType.swift
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

public enum PermissionType {
    #if PERMISSION_CONTACTS
    case contacts
    #endif

    #if PERMISSION_LOCATION
    case locationAlways
    case locationWhenInUse
    #endif

    #if PERMISSION_NOTIFICATIONS
    case notifications(UNAuthorizationOptions)
    #endif

    #if PERMISSION_MICROPHONE
    case microphone
    #endif

    #if PERMISSION_CAMERA
    case camera
    #endif

    #if PERMISSION_PHOTOS
    case photos
    #endif

    #if PERMISSION_REMINDERS
    case reminders
    #endif

    #if PERMISSION_EVENTS
    case events
    #endif

    #if PERMISSION_BLUETOOTH
    case bluetooth
    #endif

    #if PERMISSION_MOTION
    case motion
    #endif

    #if PERMISSION_SPEECH_RECOGNIZER
    @available(iOS 10.0, *) case speechRecognizer
    #endif

    #if PERMISSION_MEDIA_LIBRARY
    @available(iOS 9.3, *) case mediaLibrary
    #endif

    #if PERMISSION_SIRI
    @available(iOS 10.0, *) case siri
    #endif

    case never
}

extension PermissionType: CustomStringConvertible {
    public var description: String {
        switch self {
        #if PERMISSION_CONTACTS
        case .contacts: return "Contacts"
        #endif

        #if PERMISSION_LOCATION
        case .locationAlways: return "Location"
        case .locationWhenInUse: return "Location"
        #endif

        #if PERMISSION_NOTIFICATIONS
        case .notifications: return "Notifications"
        #endif

        #if PERMISSION_MICROPHONE
        case .microphone: return "Microphone"
        #endif

        #if PERMISSION_CAMERA
        case .camera: return "Camera"
        #endif

        #if PERMISSION_PHOTOS
        case .photos: return "Photos"
        #endif

        #if PERMISSION_REMINDERS
        case .reminders: return "Reminders"
        #endif

        #if PERMISSION_EVENTS
        case .events: return "Events"
        #endif

        #if PERMISSION_BLUETOOTH
        case .bluetooth: return "Bluetooth"
        #endif

        #if PERMISSION_MOTION
        case .motion: return "Motion"
        #endif

        #if PERMISSION_SPEECH_RECOGNIZER
        case .speechRecognizer: return "Speech Recognizer"
        #endif

        #if PERMISSION_SIRI
        case .siri: return "SiriKit"
        #endif

        #if PERMISSION_MEDIA_LIBRARY
        case .mediaLibrary: return "Media Library"
        #endif

        case .never: fatalError()
        }
    }
}
