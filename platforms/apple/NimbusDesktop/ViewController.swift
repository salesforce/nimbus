//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import Cocoa
import Nimbus
import WebKit

class ViewController: NSViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Nimbus"
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        title = "Nimbus"
    }

    override func loadView() {
        view = webView
        view.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
        let bridge = BridgeBuilder.createBridge(for: webView, plugins: [DeviceInfoPlugin()])
        webView.load(URLRequest(url: URL(string: "http://localhost:3000/")!))
    }

    lazy var webView = WKWebView(frame: .zero)
}
