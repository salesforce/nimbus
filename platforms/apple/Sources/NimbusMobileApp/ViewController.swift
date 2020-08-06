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
    }

    override func loadView() {
        view = webView

        let url = Bundle.main.url(forResource: "ip", withExtension: "txt")
            .flatMap { try? String(contentsOf: $0) }
            .flatMap { $0.trimmingCharacters(in: CharacterSet.newlines) }
            .flatMap { URL(string: "http://\($0):3000") }
            ?? URL(string: "http://localhost:3000")!

        let webBridge = BridgeBuilder.createBridge(for: webView, plugins: webViewPlugins)
        
        webView.load(URLRequest(url: url))

        let jsBridge = BridgeBuilder.createBridge(for: context, plugins: jsContextPlugins)

        if let demoPath = Bundle.main.path(forResource: "JSCoreDemo", ofType: "js"),
            let demoJS = try? String(contentsOfFile: demoPath) {
            context.evaluateScript(demoJS)
        }
    }

    lazy var webView = WKWebView(frame: .zero)
    lazy var context: JSContext = JSContext()
    let webViewPlugins: [Plugin] = [DeviceInfoPlugin()]
    let jsContextPlugins: [Plugin] = [DeviceInfoPlugin(), ConsolePlugin()]
}
