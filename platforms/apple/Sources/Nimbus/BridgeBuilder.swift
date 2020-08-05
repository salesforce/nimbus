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

public enum BridgeType {
    case webView(WKWebView)
    case jsContext(JSContext)
}

public class BridgeBuilder {
    public static func createBridge(for bridgeType: BridgeType, plugins: [Plugin]) -> NSObject {
        switch bridgeType {
        case .webView(let webView):
            let bridge = WebViewBridge(webView: webView, plugins: plugins)
            attach(bridge: bridge, webView: webView, plugins: plugins)
            return bridge
        case .jsContext(let context):
            let bridge = JSContextBridge(context: context, plugins: plugins)
            attach(bridge: bridge, context: context, plugins: plugins)
            return bridge
        }
    }
}

protocol Bridge {
    var plugins: [Plugin] { get }
}
