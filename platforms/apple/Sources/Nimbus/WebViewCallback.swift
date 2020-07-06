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

        let script: String
        if #available(iOS 13, macOS 10.15, *) {
            script = """
            {
                var jsonArgs = \(formattedJsonArgs);
                __nimbus.callCallback('\(self.callbackId)', ...jsonArgs);
            }
            null;
            """
        } else {
            // on iOS 12 and below, args are wrapped in an `EncodableValue`, so
            // peek through and get the actual values out of it
            script = """
            {
                var jsonArgs = \(formattedJsonArgs);
                jsonArgs = jsonArgs.map(v => v.v);
                __nimbus.callCallback('\(callbackId)', ...jsonArgs);
            }
            null;
            """
        }
        DispatchQueue.main.async {
            self.webView?.evaluateJavaScript(script)
        }
        return ()
    }

    weak var webView: WKWebView?
    let callbackId: String
}
