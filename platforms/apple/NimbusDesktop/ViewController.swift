//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import Cocoa
import Nimbus
import WebKit

class ViewController: NSViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Nimbus"
        bridge.addPlugin(DeviceInfoPlugin())
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        title = "Nimbus"
        bridge.addPlugin(DeviceInfoPlugin())
    }

    override func loadView() {
        view = webView
        view.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
        bridge.attach(to: webView)
        webView.load(URLRequest(url: URL(string: "http://localhost:3000/")!))
    }

    lazy var webView = WKWebView(frame: .zero)
    let bridge = Bridge()
}
