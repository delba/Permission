//
// Notifications.swift
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

#if PERMISSION_NOTIFICATIONS
import UserNotifications

extension Permission {
    var statusNotifications: PermissionStatus {
        if Defaults.requestedNotifications {
            return synchronousStatusNotifications
        }

        return .notDetermined
    }

    func requestNotifications(_ callback: Callback) {
        guard case .notifications(let options) = type else { fatalError() }

        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            Defaults.requestedNotifications = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.callbacks(self.statusNotifications)
            }
        }
    }

    private var synchronousStatusNotifications: PermissionStatus {
        let semaphore = DispatchSemaphore(value: 0)

        var status: PermissionStatus = .notDetermined

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized: status = .authorized
            case .denied: status = .denied
            case .notDetermined: status = .notDetermined
            case .provisional: status = .authorized
            @unknown default: status = .notDetermined
            }

            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .distantFuture)

        return status
    }
}
#endif
