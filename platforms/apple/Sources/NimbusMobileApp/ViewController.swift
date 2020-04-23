//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import JavaScriptCore
import UIKit
import WebKit

import Nimbus

class ViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        title = "Nimbus"
        bridge.addPlugin(DeviceInfoPlugin())
        jsBridge.addPlugin(DeviceInfoPlugin())
    }

    override func loadView() {
        view = webView

        let url = Bundle.main.url(forResource: "ip", withExtension: "txt")
            .flatMap { try? String(contentsOf: $0) }
            .flatMap { $0.trimmingCharacters(in: CharacterSet.newlines) }
            .flatMap { URL(string: "http://\($0):3000") }
            ?? URL(string: "http://localhost:3000")!

        bridge.attach(to: webView)
        webView.load(URLRequest(url: url))

        if let context = self.context {
            jsBridge.attach(to: context)
        }
    }

    lazy var webView = WKWebView(frame: .zero)
    lazy var context = JSContext()
    let bridge = WebViewBridge()
    let jsBridge = JSContextBridge()
}
