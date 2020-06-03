//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import "mocha";
import { expect } from "chai";

interface MochaMessage {
  intField: number;
  stringField: string;
}

interface CallbackTestPlugin {
  callbackWithSingleParam(completion: (param0: MochaMessage) => void): void;
  callbackWithTwoParams(
    completion: (param0: MochaMessage, param1: MochaMessage) => void
  ): void;
  callbackWithSinglePrimitiveParam(completion: (param0: number) => void): void;
  callbackWithTwoPrimitiveParams(
    completion: (param0: number, param1: number) => void
  ): void;
  callbackWithPrimitiveAndUddtParams(
    completion: (param0: number, param1: MochaMessage) => void
  ): void;
  callbackWithSingleParamAndReturn(
    completion: (param0: MochaMessage) => void
  ): Promise<string>;
  callbackWithSinglePrimitiveParamAndReturn(
    completion: (param0: number) => void
  ): Promise<string>;
  callbackWithTwoParamAndReturn(
    completion: (param0: MochaMessage, param1: MochaMessage) => void
  ): Promise<string>;
  callbackWithTwoPrimitiveParamAndReturn(
    completion: (param0: number, param1: number) => void
  ): Promise<string>;
}

declare interface NimbusWithCallbackTestPlugin {
  callbackTestPlugin: CallbackTestPlugin;
}

let nimbusWithCallbackTestPlugin: NimbusWithCallbackTestPlugin;

describe("Callbacks with", () => {
  before(() => {
    nimbusWithCallbackTestPlugin = (<any>(
      window.__nimbus!.plugins
    )) as NimbusWithCallbackTestPlugin;
  });

  it("single user defined data type is called", (done) => {
    nimbusWithCallbackTestPlugin.callbackTestPlugin.callbackWithSingleParam(
      (param0: MochaMessage) => {
        expect(param0).to.deep.equal({
          intField: 42,
          stringField: "This is a string",
        });
        done();
      }
    );
  });

  it("two user defined data types is called", (done) => {
    nimbusWithCallbackTestPlugin.callbackTestPlugin.callbackWithTwoParams(
      (param0: MochaMessage, param1: MochaMessage) => {
        expect(param0).to.deep.equal({
          intField: 42,
          stringField: "This is a string",
        });
        expect(param1).to.deep.equal({
          intField: 6,
          stringField: "int param is 6",
        });
        done();
      }
    );
  });

  it("single primitive type is called", (done) => {
    nimbusWithCallbackTestPlugin.callbackTestPlugin.callbackWithSinglePrimitiveParam(
      (param0: number) => {
        expect(param0).to.equal(777);
        done();
      }
    );
  });

  it("two primitive types is called", (done) => {
    nimbusWithCallbackTestPlugin.callbackTestPlugin.callbackWithTwoPrimitiveParams(
      (param0: number, param1: number) => {
        expect(param0).to.equal(777);
        expect(param1).to.equal(888);
        done();
      }
    );
  });

  it("one primitive types and one user defined data typeis called", (done) => {
    nimbusWithCallbackTestPlugin.callbackTestPlugin.callbackWithPrimitiveAndUddtParams(
      (param0: number, param1: MochaMessage) => {
        expect(param0).to.equal(777);
        expect(param1).to.deep.equal({
          intField: 42,
          stringField: "This is a string",
        });
        done();
      }
    );
  });
  // commented out until supported by android
  // tests work on iOS but fail on android
  // it('should return a promise string and the callback should have an object', done => {
  //   nimbusWithCallbackTestPlugin.callbackTestPlugin.callbackWithSingleParamAndReturn(
  //     (param0: MochaMessage) => {
  //       expect(param0).to.deep.equal({
  //         intField: 42,
  //         stringField: "This is a string"
  //       });
  //     }
  //   ).then((result: string) => {
  //     expect(result).to.equal("one");
  //     done();
  //   });
  // });

  // it('should return a promise string and the callback should have an int', done => {
  //   nimbusWithCallbackTestPlugin.callbackTestPlugin.callbackWithSinglePrimitiveParamAndReturn(
  //     (param0: number) => {
  //       expect(param0).to.equal(1);
  //     }
  //   ).then((result: string) => {
  //     expect(result).to.equal("one");
  //     done();
  //   });
  // });

  // it('should return a promise string and the callback should have two objects', done => {
  //   nimbusWithCallbackTestPlugin.callbackTestPlugin.callbackWithTwoParamAndReturn(
  //     (param0: MochaMessage, param1: MochaMessage) => {
  //       expect(param0).to.deep.equal({
  //         intField: 42,
  //         stringField: "This is a string"
  //       });

  //       expect(param1).to.deep.equal({
  //         intField: 3,
  //         stringField: "mock"
  //       });
  //     }
  //   ).then((result: string) => {
  //     expect(result).to.equal("two");
  //     done();
  //   });
  // });

  // it('should return a promise string and the callback should have two ints', done => {
  //   nimbusWithCallbackTestPlugin.callbackTestPlugin.callbackWithTwoPrimitiveParamAndReturn(
  //     (param0: number, param1: number) => {
  //       expect(param0).to.equal(1);
  //       expect(param1).to.equal(2);
  //     }
  //   ).then((result: string) => {
  //     expect(result).to.equal("two");
  //     done();
  //   });
  // });
});
