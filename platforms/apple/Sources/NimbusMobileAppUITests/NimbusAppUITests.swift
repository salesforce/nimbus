//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import XCTest

class NimbusMobileAppUITests: XCTestCase {
    var app: XCUIApplication?

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    public var tabBar: XCUIElement {
        return app!.tabBars.element(boundBy: 0)
    }

    func testVeil() {
        app!.launch()
        let query: XCUIElementQuery = tabBar.children(matching: .button)
        var moreButton: XCUIElement?
        for button: XCUIElement in query.allElementsBoundByIndex where button.label == "Test" {
            moreButton = button
            break
        }
        moreButton?.tap()
        let statusLabel = app!.staticTexts.element(matching: .staticText, identifier: "nimbus.test.statusLabel")

        let wait = expectation(for: NSPredicate(format: "label != 'Running'"), evaluatedWith: statusLabel, handler: nil)
        self.wait(for: [wait], timeout: 10, enforceOrder: false)

        XCTAssertTrue(statusLabel.label == "Pass")
    }
}
