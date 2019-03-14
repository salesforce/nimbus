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
        let url = Bundle.main.url(forResource: "ip", withExtension: "txt")
            .flatMap { try? String(contentsOf: $0) }
            .flatMap { $0.trimmingCharacters(in: CharacterSet.newlines) }
            .flatMap { URL(string: "http://\($0):3000") }
            ?? URL(string: "http://localhost:3000")!

        bridge = NimbusBridge(appURL: url)
        super.init(coder: aDecoder)
        title = "Nimbus"

        bridge.addExtension(DemoBridge())
        bridge.addExtension(CookieExtension())
        bridge.addExtension(DeviceExtension())
        bridge.initialize()
    }

    override func loadView() {
        view = bridge.contentView
    }

    let bridge: NimbusBridge
}
