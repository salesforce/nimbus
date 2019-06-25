//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit

/**
 `Callback` is a native proxy to a javascript function that
 is used for passing callbacks across the bridge.
 */
class Callback: Callable {
    init(webView: WKWebView, callbackId: String) {
        self.webView = webView
        self.callbackId = callbackId
    }

    deinit {
        if let webView = self.webView {
            let script = """
            nimbus.releaseCallback('\(self.callbackId)');
            """
            DispatchQueue.main.async {
                webView.evaluateJavaScript(script)
            }
        }
    }

    func call(args: [Any]) throws -> Any {
        var jsonString: String = "[]"
        if let encodables = args as? [EncodableValue] {
            let jsonEncoder = JSONEncoder()
            let jsonData = try? jsonEncoder.encode(encodables)
            jsonString = String(data: jsonData!, encoding: .utf8)!
        }

        DispatchQueue.main.async {
            self.webView?.evaluateJavaScript("""
                var args = [];
                var jsonArgs = \(jsonString);
                jsonArgs.forEach(arg => {
                    args.push(arg.v);
                });
                nimbus.callCallback('\(self.callbackId)', args);
            """)
        }
        return ()
    }

    weak var webView: WKWebView?
    let callbackId: String
}
