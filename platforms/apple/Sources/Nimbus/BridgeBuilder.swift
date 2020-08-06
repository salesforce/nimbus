//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import Foundation
import JavaScriptCore
import WebKit

public class BridgeBuilder {
    public static func createBridge(for webView: WKWebView, plugins: [Plugin]) -> WebViewBridge {
        let bridge = WebViewBridge(webView: webView, plugins: plugins)
        attach(bridge: bridge, webView: webView, plugins: plugins)
        return bridge
    }
    
    public static func createBridge(for context: JSContext, plugins: [Plugin]) -> JSContextBridge {
        let bridge = JSContextBridge(context: context, plugins: plugins)
        attach(bridge: bridge, context: context, plugins: plugins)
        return bridge
    }
}

public protocol Bridge {
    var plugins: [Plugin] { get }
}
