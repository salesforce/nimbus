//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import UIKit
import WebKit

import Nimbus

class ViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        title = "Nimbus"

        bridge.addExtension(DemoBridge())
        bridge.addExtension(DeviceExtension())
    }

    override func loadView() {
        view = self.webView

        let url = Bundle.main.url(forResource: "ip", withExtension: "txt")
            .flatMap { try? String(contentsOf: $0) }
            .flatMap { $0.trimmingCharacters(in: CharacterSet.newlines) }
            .flatMap { URL(string: "http://\($0):3000") }
            ?? URL(string: "http://localhost:3000")!

        bridge.attach(to: webView)
        self.webView.load(URLRequest(url: url))
    }

    lazy var webView = WKWebView(frame: .zero)
    let bridge = NimbusBridge()
}
