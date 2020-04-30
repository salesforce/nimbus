//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import "mocha";
import { expect } from "chai";
import nimbus from "nimbus-bridge";

interface JSAPITestPlugin {
  nullaryResolvingToInt(): Promise<number>;
}

declare module "nimbus-bridge" {
  interface NimbusPlugins {
    jsapiTestPlugin: JSAPITestPlugin;
  }
}

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

describe("Nimbus JS API", () => {
  // Test a binding of a nullary function that resolves to an Integer
  it("nullary function resolving to Int", (done) => {
    __nimbus.plugins.jsapiTestPlugin
      .nullaryResolvingToInt()
      .then((value: number) => {
        expect(value).to.deep.equal(5);
        done();
      });
  });
  // Test a binding of a nullary function that resolves to an array of Integers
  // Test a binding of a nullary function that resolves to an object
  // Test a binding of a unary function that accepts an Integer and resolves to void
  // Test a binding of a unary function that accepts an object and resolves to void
  // Test a binding of a binary function that accepts an Integer and a function accepting an Integer
  // Test a binding of a binary function that accepts an Integare and a function accepting an object
});
