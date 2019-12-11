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

    func call(args: [Any], forPromisifiedClosure: Bool) throws -> Any {
        if forPromisifiedClosure {
            if args.count != 1 {
                fatalError("Promise can only pass one success result")
            }
            var result: EncodableValue
            if type(of: args.first) == Void.self {
                result = .void
            } else if let encodable = args.first as? Encodable {
                result = .value(encodable)
            } else {
                throw ParameterError.conversion
            }
            self.webView?.resolvePromise(promiseId: self.callbackId, result: result)
        } else {
            let jsonEncoder = JSONEncoder()
            let jsonArgs = try args.map { arg -> String in
                if let encodable = arg as? Encodable {
                    let jsonData = try jsonEncoder.encode(EncodableValue.value(encodable))
                    let jsonString = String(data: jsonData, encoding: .utf8)!
                    return jsonString
                } else if arg is NSArray || arg is NSDictionary {
                    let data = try JSONSerialization.data(withJSONObject: arg, options: [])
                    let jsonString = String(data: data, encoding: String.Encoding.utf8)!
                    return jsonString
                } else {
                    // Parameters passed to callback are implied that they
                    // conform to Encodable protocol or be either NSArray or NSDictionary.
                    // If for some reason any elements don't throw parameter error.
                    throw ParameterError.conversion
                }
            }
            let formattedJsonArgs = String(format: "[%@]", jsonArgs.joined(separator: ","))

            DispatchQueue.main.async {
                self.webView?.evaluateJavaScript("""
                    var jsonArgs = \(formattedJsonArgs);
                    var mappedJsonArgs = jsonArgs.map(element => {
                      if (element.hasOwnProperty('v')) {
                        return element.v;
                      } else {
                        return element;
                      }
                    });
                    nimbus.callCallback('\(self.callbackId)', mappedJsonArgs);
                """)
            }
        }
        return ()
    }

    weak var webView: WKWebView?
    let callbackId: String
}
