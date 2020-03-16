//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit

/**
 A plugin integrates native capabilities into a JavaScript runtime environment.
 */
public protocol Plugin: class {

    /**
     Bind this plugin to the specified web view and Nimbus bridge.

     Plugins can implement the bind method to add connections and expose methods
     to the web view, make additional configuration changes to the web view, or
     call additional methods on the nimbus bridge prior to the web app being loaded.
     */
    func bind(to webView: WKWebView, bridge: NimbusBridge)
}

extension Plugin where Self: NimbusExtension {
    public func bind(to webView: WKWebView, bridge: NimbusBridge) {
        bindToWebView(webView: webView)
    }
}
