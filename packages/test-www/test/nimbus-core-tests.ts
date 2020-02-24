//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import "mocha";
import { expect } from "chai";
import nimbus from "nimbus-bridge";

describe("Nimbus JS initialization", () => {
  it("preserves existing objects", () => {
    expect(nimbus).to.be.an("object", "nimbus should be an object");
    expect(nimbus.plugins.mochaTestBridge).to.be.an(
      "object",
      "mochaTestBridge should be an object"
    );
    expect(nimbus.plugins.mochaTestBridge.testsCompleted).to.be.a("function");
  });
});
