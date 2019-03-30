//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import Cocoa
import Nimbus
import WebKit

class DemoBridge {
    func currentTime() -> String {
        return Date().description
    }
}

extension DemoBridge: NimbusExtension {
    func bindToWebView(webView: WKWebView) {
        let connection = webView.addConnection(to: self, as: "DemoBridge")
        connection.bind(DemoBridge.currentTime, as: "currentTime")
    }
}

class ViewController: NSViewController {
    init() {
        bridge = NimbusBridge(appURL: URL(string: "http://localhost:3000/")!)
        super.init(nibName: nil, bundle: nil)
        title = "Nimbus"
        bridge.addExtension(DemoBridge())
        bridge.initialize()
    }

    required init?(coder: NSCoder) {
        bridge = NimbusBridge(appURL: URL(string: "http://localhost:3000/")!)
        super.init(coder: coder)
        title = "Nimbus"
        bridge.addExtension(DemoBridge())
        bridge.initialize()
    }

    override func loadView() {
        view = bridge.contentView
        view.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
    }

    let bridge: NimbusBridge
}
