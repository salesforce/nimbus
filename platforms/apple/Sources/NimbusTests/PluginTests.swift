//
//  PluginTests.swift
//  NimbusTests
//
//  Created by Paul Tiarks on 4/2/20.
//  Copyright © 2020 Salesforce.com, inc. All rights reserved.
//

import XCTest
@testable import Nimbus

private class ExternalTestPlugin: Plugin {
    func bind<C>(to connection: C) where C: Connection {
        // do nothing
    }
}

class PluginTests: XCTestCase {

    private class InternalTestPlugin: Plugin {
        func bind<C>(to connection: C) where C: Connection {
            // do nothing
        }

    }

    func testPluginDefaultNamespaceImplementation() {
        XCTAssertEqual(InternalTestPlugin().namespace, "InternalTestPlugin")
        XCTAssertEqual(ExternalTestPlugin().namespace, "ExternalTestPlugin")
    }

}
