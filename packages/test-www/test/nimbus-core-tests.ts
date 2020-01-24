//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import "mocha";
import { expect } from "chai";
import setup from "./nimbus-core-tests-setup";
import nimbus from "nimbus-bridge";

setup;
nimbus;

describe("Nimbus JS initialization", () => {
  it("preserves existing objects", () => {
    expect(nimbus).to.be.an("object", "nimbus should be an object")
    expect(window.mochaTestBridge).to.be.an("object", "mochaTestBridge should be an object")
    expect(window.mochaTestBridge.testsCompleted).to.be.a("function")
    expect(window.mochaTestBridge.myProp).to.equal("exists", "mochaTestBridge.myProp should still exist")
  });
});
