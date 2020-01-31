//
//  WebView+NimbusJS.swift
//  NimbusJS
//
//  Created by Paul Tiarks on 1/31/20.
//  Copyright © 2020 Salesforce.com, inc. All rights reserved.
//

import WebKit

enum NimbusJSError: Error {
    case sourceNotFound
}

extension WKWebView {
    func injectNimbusJavascript(scriptName: String = "nimbus", bundle: Bundle = Bundle.main) throws {
        guard let sourcePath = bundle.path(forResource: scriptName, ofType: "js") else {
            throw NimbusJSError.sourceNotFound
        }

        let source = try String(contentsOfFile: sourcePath)
        let userScript = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        self.configuration.userContentController.addUserScript(userScript)
    }
}
