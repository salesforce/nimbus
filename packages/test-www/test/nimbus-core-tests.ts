//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import "mocha";
import { expect } from "chai";
import nimbus from "nimbus-bridge";

interface JSAPITestStruct {
  intField: number;
  stringField: string;
}
interface JSAPITestPlugin {
  nullaryResolvingToInt(): Promise<number>;
  nullaryResolvingToIntArray(): Promise<Array<number>>;
  nullaryResolvingToObject(): Promise<JSAPITestStruct>;
  unaryResolvingToVoid(param0: number): Promise<void>;
  unaryObjectResolvingToVoid(param0: JSAPITestStruct): Promise<void>;
  binaryResolvingToIntCallback(
    param0: number,
    completion: (innerParam: number) => void
  ): Promise<void>;
  binaryResolvingToObjectCallback(
    param0: number,
    completion: (innerParam: JSAPITestStruct) => void
  ): Promise<void>;
  binaryResolvingToObjectCallbackToInt(
    param0: number,
    completion: (innerParam: JSAPITestStruct) => void
  ): Promise<number>;
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
  // This test is temporarily disabled until Android Array/List implementation is fixed
  // Test a binding of a nullary function that resolves to an array of Integers
  // it("nullary function resolving to Int array", (done) => {
  //   __nimbus.plugins.jsapiTestPlugin
  //     .nullaryResolvingToIntArray()
  //     .then((value: Array<number>) => {
  //       expect(value).to.be.an("array", "result should be an array");
  //       expect(value.length).to.deep.equal(3);
  //       expect(value[0]).to.deep.equal(1);
  //       expect(value[1]).to.deep.equal(2);
  //       expect(value[2]).to.deep.equal(3);
  //       done();
  //     });
  // });
  // Test a binding of a nullary function that resolves to an object
  it("nullary function resolving to an object", (done) => {
    __nimbus.plugins.jsapiTestPlugin
      .nullaryResolvingToObject()
      .then((value: JSAPITestStruct) => {
        expect(value).to.be.an("object", "result should be an object");
        expect(value.intField).to.deep.equal(42);
        expect(value.stringField).to.deep.equal("JSAPITEST");
        done();
      });
  });
  // Test a binding of a unary function that accepts an Integer and resolves to void
  it("unary int function resolving to void", (done) => {
    __nimbus.plugins.jsapiTestPlugin.unaryResolvingToVoid(5).then(() => {
      done();
    });
  });
  // Test a binding of a unary function that accepts an object and resolves to void
  it("unary object function resolving to void", (done) => {
    var param = { intField: 42, stringField: "JSAPITEST" };
    __nimbus.plugins.jsapiTestPlugin
      .unaryObjectResolvingToVoid(param)
      .then(() => {
        done();
      });
  });
  // Test a binding of a binary function that accepts an Integer and a function accepting an Integer
  it("binary function accepting int and callback", (done) => {
    __nimbus.plugins.jsapiTestPlugin.binaryResolvingToIntCallback(
      5,
      (result: number) => {
        expect(result).to.deep.equal(5);
        done();
      }
    );
  });
  // Test a binding of a binary function that accepts an Integer and a function accepting an object
  it("binary function accepting int and callback taking object", (done) => {
    __nimbus.plugins.jsapiTestPlugin.binaryResolvingToObjectCallback(
      5,
      (result: JSAPITestStruct) => {
        expect(result).to.deep.equal({
          intField: 42,
          stringField: "JSAPITEST",
        });
        done();
      }
    );
  });

  it('binary function accepting int and callback taking an object returning an int', (done) => {
    __nimbus.plugins.jsapiTestPlugin.binaryResolvingToObjectCallbackToInt(
      5,
      (result: JSAPITestStruct) => {
        expect(result).to.deep.equal({
          intField: 42,
          stringField: "JSAPITEST"
        });
      }
    ).then((value: number) => {
      expect(value).to.deep.equal(1);
      done();
    })
  });
});
