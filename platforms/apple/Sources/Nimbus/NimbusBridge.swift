//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit

#if os(iOS)
    import UIKit
    public typealias BaseView = UIView
#elseif os(macOS)
    import Cocoa
    public typealias BaseView = NSView
#else
#endif

public class NimbusBridge {
    public enum State {
        case notReady
        case initializing
        case loading
        case ready
        case error
    }

    public class BridgeBuilder {
        // TODO: vend the builder interface:
        //   - set configs
        //   - add extensions
//        public func build() -> NimbusBridge {
//            return NimbusBridge()
//        }
    }

    public init(appURL: URL) {
        webViewConfiguration.preferences.javaScriptEnabled = true
        #if DEBUG
            webViewConfiguration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        #endif
        self.appURL = appURL
        contentView = BaseView(frame: .zero)
    }

    public func addExtension<T: NimbusExtension>(_ ext: T) {
        extensions.append(ext)
    }

    // TODO: this name stinks, but what is a better one? ¯\_(ツ)_/¯
    public func initialize() {
        state = .initializing

        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView?.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(webView!)
        webView?.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        webView?.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        webView?.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        webView?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        initializeExtensions(extensions)

        state = .ready
        webView?.load(URLRequest(url: appURL))
    }

    func initializeExtensions(_ extensions: [NimbusExtension]) {
        for ext in extensions {
            ext.bindToWebView(webView: webView!)
        }
    }

    public let contentView: BaseView
    public var webView: WKWebView?
    public private(set) var state: State = .notReady

    var extensions: [NimbusExtension] = []
    let webViewConfiguration = WKWebViewConfiguration()
    let appURL: URL
}
