//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit

public protocol NimbusExtension {
    func preload(config: [String: String], webViewConfiguration: WKWebViewConfiguration, callback: @escaping (Bool) -> Void)

    func load(config: [String: String], webView: WKWebView, callback: @escaping (Bool) -> Void)

    // TODO: add bridge lifecycle hooks...
}
