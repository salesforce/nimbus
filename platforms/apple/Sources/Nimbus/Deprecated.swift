//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit

@available(*, deprecated, message: "Use the `Plugin` protocol instead. `NimbusExtension` will be removed in the future")
public protocol NimbusExtension: Plugin {
    func bindToWebView(webView: WKWebView)
}

@available(*, deprecated, message: "Use `Bridge` instead")
public typealias NimbusBridge = Bridge

public extension Bridge {
    @available(*, deprecated, message: "Use `Bridge.addPlugin()` instead")
    func addExtension(ext: NimbusExtension) {
        plugins.append(ext)
    }

    @available(*, deprecated, message: "Use `Bridge.addPlugin()` instead")
    func addExtension<T: NimbusExtension>(_ ext: T) {
        plugins.append(ext)
    }
}

extension WKWebView {
    /**
     Call a Javascript function.

     - Parameter name: Name of a function or a method on an object to call.  Fully qualify this name
     by separating with a dot and do not need to add parenthesis. The function
     to be performed in Javascript must already be defined and exist there.  Do not
     pass a snippet of code to evaluate.
     - Parameter args: Array of encodable objects.  They will be Javascript stringified in this
     method and be passed the function as specified in 'name'. If you are calling a
     Javascript function that does not take any parameters pass empty array instead of nil.
     - Parameter completionHandler: A block to invoke when script evaluation completes or fails. You do not
     have to pass a closure if you are not interested in getting the callback.
     */
    @available(*, deprecated, message: "Call `Bridge.invoke` instead. This method will be removed prior to v1.0.0")
    public func callJavascript(name: String, args: [Encodable], completionHandler: ((Any?, Error?) -> Void)? = nil) {
        let jsonEncoder = JSONEncoder()
        var encodableValues = [EncodableValue]()
        for encodable in args {
            let wrappedValue = EncodableValue.value(encodable)
            encodableValues.append(wrappedValue)
        }
        var jsonString = "[]"
        if let jsonData = try? jsonEncoder.encode(encodableValues) {
            jsonString = String(data: jsonData, encoding: .utf8)!
        }
        let script = """
            var jsonData = \(jsonString);
            var jsonArr = jsonData.map(function(encodable){
                return encodable.v;
            });
            if (jsonArr && jsonArr.length > 0) {
                \(name)(...jsonArr);
            } else {
                \(name)();
            }
        """
        evaluateJavaScript(script) { (result: Any?, error: Error?) in
            if let handler = completionHandler {
                if error == nil {
                    handler(result, nil)
                } else {
                    handler(nil, error!)
                }
            }
        }
    }
}
