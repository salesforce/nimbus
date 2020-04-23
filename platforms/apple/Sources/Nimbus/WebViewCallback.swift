//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit

/**
 `Callback` is a native proxy to a javascript function that
 is used for passing callbacks across the bridge.
 */
class WebViewCallback: Callable {
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

    func call(args: [Any]) throws -> Any {
        let jsonEncoder = JSONEncoder()
        let jsonArgs = try args.map { arg -> String in
            if let encodable = arg as? Encodable {
                let jsonData = try jsonEncoder.encode(EncodableValue.value(encodable))
                let jsonString = String(data: jsonData, encoding: .utf8)!
                return jsonString
            } else {
                // Parameters passed to callback are implied that they
                // conform to Encodable protocol.
                // If for some reason any elements don't throw parameter error.
                throw ParameterError.conversion
            }
        }
        let formattedJsonArgs = String(format: "[%@]", jsonArgs.joined(separator: ","))

        DispatchQueue.main.async {
            self.webView?.evaluateJavaScript("""
            {
                var jsonArgs = \(formattedJsonArgs);
                var mappedJsonArgs = jsonArgs.map(element => {
                  if (element.hasOwnProperty('v')) {
                    return element.v;
                  } else {
                    return element;
                  }
                });
                __nimbus.callCallback('\(self.callbackId)', ...mappedJsonArgs);
            }
            null;
            """)
        }
        return ()
    }

    weak var webView: WKWebView?
    let callbackId: String
}
