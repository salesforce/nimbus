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

        let webView = WKWebView(frame: view.bounds)

        bridge = DemoAppBridge(host: self, webView: webView)
        
        // Connect the webview to our demo bridge
        let c = webView.addConnection(to: bridge!, as: "DemoAppBridge")
        c.bind(DemoAppBridge.showAlert, as: "showAlert")
        c.bind(DemoAppBridge.currentTime, as: "currentTime")
        c.bind(DemoAppBridge.withCallback, as: "withCallback")
        c.bind(DemoAppBridge.initiateNativeCallingJs, as: "initiateNativeCallingJs")
        c.bind(DemoAppBridge.initiateNativeBroadcastMessage, as:"initiateNativeBroadcastMessage")

        self.view.addSubview(webView)
        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "demoApp")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        webView.load(URLRequest(url: url))
        self.webView = webView
    }

}
