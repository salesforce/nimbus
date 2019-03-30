//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//
#if os(iOS)

    import UIKit
    import WebKit

    public class NimbusView: UIView {
        // TODO: decide if having multiple views per bridge is worth the comlexity cost

        public init(bridge: NimbusBridge, url: URL) {
            self.bridge = bridge
            webView = WKWebView(frame: .zero, configuration: bridge.webViewConfiguration)
            webView.translatesAutoresizingMaskIntoConstraints = false
            super.init(frame: .zero)
            webView.frame = bounds
            addSubview(webView)
            webView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            webView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            webView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            webView.load(URLRequest(url: url))
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("unavailable")
        }

        let bridge: NimbusBridge
        let webView: WKWebView
    }
#endif
