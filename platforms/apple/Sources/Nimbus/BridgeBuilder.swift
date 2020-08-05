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
    public static func createBridge(for bridgeType: BridgeType, plugins: [Plugin]) -> Bridge {
        switch bridgeType {
        case .webView(let webView):
            let bridge = WebViewBridge(webView: webView)
            attach(bridge: bridge, webView: webView, plugins: plugins)
            return bridge
        case .jsContext(let context):
            let bridge = JSContextBridge(context: context)
            attach(bridge: bridge, context: context, plugins: plugins)
            return Bridge()
        }
    }
    
    static func attach(bridge: WebViewBridge, webView: WKWebView, plugins: [Plugin]) {
        let configuration = webView.configuration
        configuration.userContentController.add(bridge, name: "_nimbus")
        configuration.preferences.javaScriptEnabled = true
        #if DEBUG
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        #endif
        
        for plugin in plugins {
            let connection = WebViewConnection(from: webView, bridge: bridge, as: plugin.namespace)
            plugin.bind(to: connection)
            if let script = connection.userScript() {
                let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                webView.configuration.userContentController.addUserScript(userScript)
            }
        }
    }
    
    static func attach(bridge: JSContextBridge, context: JSContext, plugins: [Plugin]) {
        let nimbusDeclaration = """
            __nimbus = {"plugins": {}};
            true;
            """
        context.evaluateScript(nimbusDeclaration)
        
        for plugin in plugins {
            let connection = JSContextConnection(from: context, bridge: bridge, as: plugin.namespace)
            plugin.bind(to: connection)
        }
    }
}

public class Bridge: NSObject {
    var plugins: [Plugin] = []
}
