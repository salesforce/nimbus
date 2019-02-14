//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import Foundation
import Nimbus
import WebKit

class CookieExtension {}

extension CookieExtension: NimbusExtension {
    func preload(config _: [String: String], webViewConfiguration: WKWebViewConfiguration, callback: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            let localIP = Bundle.main.url(forResource: "ip", withExtension: "txt")
                .flatMap { try? String(contentsOf: $0) }
                .flatMap { $0.trimmingCharacters(in: CharacterSet.newlines) }?.description ?? "127.0.0.1"

            let cookieValue = "whatever"
            DispatchQueue.main.async {
                let cookieStore = webViewConfiguration.websiteDataStore.httpCookieStore
                if let cookie = HTTPCookie(properties: [
                    .name: "NimbusCookie",
                    .domain: localIP,
                    .path: "/",
                    .value: cookieValue,
                ]) {
                    cookieStore.setCookie(cookie, completionHandler: {
                        callback(true)
                    })
                } else {
                    callback(false) // callback(error)
                }
            }
        }
    }

    func load(config _: [String: String], webView _: WKWebView, callback: @escaping (Bool) -> Void) {
        callback(true)
    }
}
