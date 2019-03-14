//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit

struct DeviceInfo: Codable {
    let platform: String
    let platformVersion: String
    let manufacturer: String
    let model: String
    let appVersion: String

    init() {
        let device = UIDevice.current
        platform = device.systemName
        platformVersion = device.systemVersion
        manufacturer = "Apple"
        model = device.model
        appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}

public class DeviceExtension {
    public init() {}

    func getDeviceInfo() -> DeviceInfo {
        return DeviceInfo()
    }
}

extension DeviceExtension: NimbusExtension {
    public func preload(config: [String: String], webViewConfiguration: WKWebViewConfiguration, callback: @escaping (Bool) -> Void) {
        callback(true)
    }

    public func load(config: [String: String], webView: WKWebView, callback: @escaping (Bool) -> Void) {
        let connection = webView.addConnection(to: self, as: "DeviceExtension")
        connection.bind(DeviceExtension.getDeviceInfo, as: "getDeviceInfo")
        callback(true)
    }
}
