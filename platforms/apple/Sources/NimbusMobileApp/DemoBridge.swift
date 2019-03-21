//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import Foundation
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
