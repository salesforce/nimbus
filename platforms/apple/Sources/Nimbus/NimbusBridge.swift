//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit

public class NimbusBridge: NSObject {

    @objc public func addExtension(ext: NimbusExtension) {
        extensions.append(ext)
    }

    public func addExtension<T: NimbusExtension>(_ ext: T) {
        extensions.append(ext)
    }

    @objc public func attach(to webView: WKWebView) {
        let webViewConfiguration = webView.configuration
        webViewConfiguration.preferences.javaScriptEnabled = true
        #if DEBUG
        webViewConfiguration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        #endif

        for ext in extensions {
            ext.bindToWebView(webView: webView)
        }
    }

    var extensions: [NimbusExtension] = []
}
