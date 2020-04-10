//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit

enum NimbusJSError: Error {
    case sourceNotFound
}

public extension WKWebView {
    func injectNimbusJavascript(scriptName: String = "nimbus", bundle: Bundle? = nil) throws {
        let bundlesToSearch: [Bundle]
        if let bundle = bundle {
            bundlesToSearch = [bundle]
        } else {
            bundlesToSearch = Bundle.allFrameworks
        }
        let foundPath = bundlesToSearch.compactMap { mapBundle in
            return mapBundle.path(forResource: scriptName, ofType: "js")
        }.first
        guard let sourcePath = foundPath else {
            throw NimbusJSError.sourceNotFound
        }

        let source = try String(contentsOfFile: sourcePath)
        let userScript = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        self.configuration.userContentController.addUserScript(userScript)
    }
}
