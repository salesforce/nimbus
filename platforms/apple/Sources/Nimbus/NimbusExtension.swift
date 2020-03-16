//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit

@available(*, deprecated, message: "Use the `Plugin` protocol instead. `NimbusExtension` will be removed in the future")
public protocol NimbusExtension: Plugin {
    func bindToWebView(webView: WKWebView)
}
