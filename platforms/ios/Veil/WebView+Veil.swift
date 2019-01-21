// Copyright (c) 2018, salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause


import WebKit

extension WKWebView {

    /**
     Create a connection from this web view to the specified object.
     */
    public func addConnection<C>(to target: C, as namespace: String) -> Connection<C> {
        return Connection(from: self, to: target, as: namespace)
    }
    
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
    public func callJavascript(name: String, args: [Encodable], completionHandler: ((Any?, Error?) -> Void)? = nil) {
        let jsonEncoder = JSONEncoder()
        var encodableValues = [EncodableValue]()
        for encodable in args {
            let wrappedValue = EncodableValue.value(encodable)
            encodableValues.append(wrappedValue)
        }
        let jsonData = try! jsonEncoder.encode(encodableValues)
        let jsonString = String(data: jsonData, encoding: .utf8)!
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
        self.evaluateJavaScript(script) { (result: Any?, error: Error?) in
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
