//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

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
    @available(*, deprecated, message: "Call `NimbusBridge.invoke` instead")
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

    /**
     Broadcast a message to subscribers listening on Javascript side.  Message can be
     delivered with an argument so that subscriber can use that pass useful data.

     - Parameter name: Message name.  Listeners are keying on unique message names on Javascript side.
     There can be multiple listeners listening on same message.
     - Parameter arg: Any encodable object to pass to Javascript as useful data.  If there is nothing to be
     passed don't specify the parameter since it has nil as default parameter.
     - Parameter completionHandler: A block to invoke when script evaluation completes or fails. You do not
     have to pass a closure if you are not interested in getting the callback.
     */
    public func broadcastMessage(name: String, arg: Encodable? = nil, completionHandler: ((Int, Error?) -> Void)? = nil) {
        var script = ""
        if let validArg = arg {
            let wrappedValue = EncodableValue.value(validArg)
            let jsonEncoder = JSONEncoder()
            var jsonString = "{v:undefined}"
            if let jsonData = try? jsonEncoder.encode(wrappedValue) {
                jsonString = String(data: jsonData, encoding: .utf8)!
            }
            script = """
                try {
                    var jsonData = \(jsonString);
                    var unwrappedArg = jsonData.v;
                    if (unwrappedArg) {
                        window.__nimbus.broadcastMessage('\(name)', unwrappedArg);
                    } else {
                        window.__nimbus.broadcastMessage('\(name)');
                    }
                } catch(e) {
                    console.log('Error parsing JSON during a call to broadcastMessage:' + e.toString());
                }
            """
        } else {
            script = """
                window.__nimbus.broadcastMessage('\(name)');
            """
        }
        evaluateJavaScript(script) { (result: Any?, error: Error?) in
            if let handler = completionHandler {
                if error == nil {
                    let completedCount = result as? Int ?? 0
                    handler(completedCount, nil)
                } else {
                    handler(0, error!)
                }
            }
        }
    }
}
