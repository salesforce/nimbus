//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit

public class NimbusBridge {
    public enum State {
        case notReady
        case preinitializing
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
        contentView = UIView(frame: .zero)
    }

    public func addExtension<T: NimbusExtension>(_ ext: T) {
        extensions.append(ext)
    }

    // TODO: this name stinks, but what is a better one? ¯\_(ツ)_/¯
    public func initialize() {
        state = .preinitializing
        preinitializeExtensions(extensions)
    }

    func preinitializeExtensions(_ extensions: [NimbusExtension]) {
        var extensionsToInitialize = extensions
        if extensionsToInitialize.isEmpty {
            preinitializingExtensionsSucceeded()
            return
        }
        let ext = extensionsToInitialize.removeFirst()
        let initializationCallback: (Bool) -> Void = { succeeded in
            if succeeded {
                self.preinitializeExtensions(extensionsToInitialize)
            } else {
                self.preinitializingExtensionsFailed()
            }
        }
        ext.preload(config: [:], webViewConfiguration: webViewConfiguration, callback: initializationCallback)
    }

    func initializeExtensions(_ extensions: [NimbusExtension]) {
        var extensionsToInitialize = extensions
        if extensionsToInitialize.isEmpty {
            initializingExtensionsSucceeded()
            return
        }
        let ext = extensionsToInitialize.removeFirst()
        let initializationCallback: (Bool) -> Void = { succeeded in
            if succeeded {
                self.initializeExtensions(extensionsToInitialize)
            } else {
                self.initializingExtensionsFailed()
            }
        }
        ext.load(config: [:], webView: webView!, callback: initializationCallback)
    }

    func preinitializingExtensionsSucceeded() {
        state = .initializing
        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView?.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(webView!)
        webView?.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        webView?.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        webView?.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        webView?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        initializeExtensions(extensions)
    }

    func preinitializingExtensionsFailed() {
        state = .error
    }

    func initializingExtensionsSucceeded() {
        state = .ready
        webView?.load(URLRequest(url: appURL))
    }

    func initializingExtensionsFailed() {
        state = .error
    }

    public let contentView: UIView
    public var webView: WKWebView?
    public private(set) var state: State = .notReady

    var extensions: [NimbusExtension] = []
    let webViewConfiguration = WKWebViewConfiguration()
    let appURL: URL
}
