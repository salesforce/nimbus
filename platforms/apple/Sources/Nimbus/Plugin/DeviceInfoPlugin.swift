//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import Cocoa
    import Foundation
#else
    #error("Unsupported Platform")
#endif

struct DeviceInfo: Codable {
    let platform: String
    let platformVersion: String
    let manufacturer: String
    let model: String
    let appVersion: String

    #if os(iOS)
        init() {
            let device = UIDevice.current
            platform = device.systemName
            platformVersion = device.systemVersion
            manufacturer = "Apple"
            model = device.model
            appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        }
    #endif

    #if os(macOS)
        init() {
            platform = "macOS"
            let osVersion = ProcessInfo.processInfo.operatingSystemVersion
            platformVersion = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
            manufacturer = "Apple" // what about hackintoshes? ¯\_(ツ)_/¯
            var len: Int = 0
            if sysctlbyname("hw.model", nil, &len, nil, 0) == 0 {
                var result = [CChar](repeating: 0, count: len)
                sysctlbyname("hw.model", &result, &len, nil, 0)
                model = String(cString: result)
            } else {
                model = "unknown"
            }
            appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        }
    #endif
}

public class DeviceInfoPlugin {
    public init() {}

    func getDeviceInfo() -> DeviceInfo {
        return deviceInfo
    }

    let deviceInfo = DeviceInfo()
}

extension DeviceInfoPlugin: Plugin {
    public func bind(to webView: WKWebView, bridge: Bridge) {
        let connection = webView.addConnection(to: self, as: "DeviceExtension")
        connection.bind(DeviceInfoPlugin.getDeviceInfo, as: "getDeviceInfo")
    }
}
