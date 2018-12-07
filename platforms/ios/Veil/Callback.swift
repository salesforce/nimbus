/**
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


import WebKit

/**
 `Callback` is a native proxy to a javascript function that
 is used for passing callbacks across the bridge.
 */
class Callback : Callable {

    init(webView: WKWebView, callbackId: String) {
        self.webView = webView
        self.callbackId = callbackId
    }

    deinit {
        if let webView = self.webView {
            let script = """
            delete callbacks['\(self.callbackId)'];
            """
            DispatchQueue.main.async {
                webView.evaluateJavaScript(script)
            }
        }
    }

    func call(args: [Any]) throws -> Any {
        let jsonData = try JSONSerialization.data(withJSONObject: args, options: [])
        let jsonString = String(data: jsonData, encoding: .utf8)
        DispatchQueue.main.async {
            self.webView?.evaluateJavaScript("""
                callCallback('\(self.callbackId)', \(jsonString!));
                """)
        }
        return ()
    }

    weak var webView: WKWebView?
    let callbackId: String

}
