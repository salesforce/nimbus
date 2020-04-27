//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit

/**
 `WebViewCallback` is a native proxy to a javascript function that
 is used for passing callbacks across the bridge.
 */
class WebViewCallback {
    init(webView: WKWebView, callbackId: String) {
        self.webView = webView
        self.callbackId = callbackId
    }

    deinit {
        if let webView = self.webView {
            let script = """
            __nimbus.releaseCallback('\(self.callbackId)');
            """
            DispatchQueue.main.async {
                webView.evaluateJavaScript(script)
            }
        }
    }

    func call(args: [Any]) throws {
        guard let jsonArgs = args as? [String] else {
            throw ParameterError.conversion
        }
        let formattedJsonArgs = String(format: "[%@]", jsonArgs.joined(separator: ","))

        DispatchQueue.main.async {
            self.webView?.evaluateJavaScript("""
            {
                var jsonArgs = \(formattedJsonArgs);
                __nimbus.callCallback('\(self.callbackId)', ...jsonArgs);
            }
            null;
            """)
        }
        return ()
    }

    weak var webView: WKWebView?
    let callbackId: String
}
