// Copyright (c) 2018, salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause


import UIKit
import WebKit

import Veil

class ViewController: UIViewController {

    var webView: WKWebView?
    var bridge: DemoAppBridge!

    override func viewDidLoad() {
        super.viewDidLoad()

        bridge = DemoAppBridge(host: self)

        let userContentController = WKUserContentController()
        let appScript = Bundle.main.url(forResource: "app", withExtension: "js")
            .flatMap { try? NSString(contentsOf: $0, encoding: String.Encoding.utf8.rawValue ) }
            .flatMap { WKUserScript(source: $0 as String, injectionTime: .atDocumentEnd, forMainFrameOnly: true) }
        if let appScript = appScript {
            userContentController.addUserScript(appScript)
        }
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        let webView = WKWebView(frame: view.bounds, configuration: config)

        // Connect the webview to our demo bridge
        let c = webView.addConnection(to: bridge!, as: "DemoAppBridge")
        c.bind(DemoAppBridge.showAlert, as: "showAlert")
        c.bind(DemoAppBridge.currentTime, as: "currentTime")
        c.bind(DemoAppBridge.withCallback, as: "withCallback")

        self.view.addSubview(webView)
        webView.loadHTMLString(htmlString, baseURL: nil)
        self.webView = webView
    }

}

let htmlString = """
<html>
<head>
  <meta name='viewport' content='initial-scale=1.0, user-scalable=no' />
</head>
<body>
  <button onclick='showAlert();'>Show Alert</button><br>
  <button onclick='logCurrentTime();'>Log Time</button><br>
  <button onclick='doCallback();'>Do Callback</button><br>
</body>
</html>
"""
