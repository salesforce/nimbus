//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
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
