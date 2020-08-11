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
  promiseResolved(): Promise<string>;
  promiseRejected(): Promise<string>;
  promiseRejectedEncoded(): Promise<string>;
}

declare module "@nimbus-js/api" {
  interface NimbusPlugins {
    callbackTestPlugin: CallbackTestPlugin;
  }
}

describe("Callbacks with", () => {
  it("single user defined data type is called", done => {
    __nimbus.plugins.callbackTestPlugin.callbackWithSingleParam(
      (param0: MochaMessage) => {
        expect(param0).to.deep.equal({
          intField: 42,
          stringField: "This is a string"
        });
        done();
      }
    );
  });

  it("two user defined data types is called", done => {
    __nimbus.plugins.callbackTestPlugin.callbackWithTwoParams(
      (param0: MochaMessage, param1: MochaMessage) => {
        expect(param0).to.deep.equal({
          intField: 42,
          stringField: "This is a string"
        });
        expect(param1).to.deep.equal({
          intField: 6,
          stringField: "int param is 6"
        });
        done();
      }
    );
  });

  it("single primitive type is called", done => {
    __nimbus.plugins.callbackTestPlugin.callbackWithSinglePrimitiveParam(
      (param0: number) => {
        expect(param0).to.equal(777);
        done();
      }
    );
  });

  it("two primitive types is called", done => {
    __nimbus.plugins.callbackTestPlugin.callbackWithTwoPrimitiveParams(
      (param0: number, param1: number) => {
        expect(param0).to.equal(777);
        expect(param1).to.equal(888);
        done();
      }
    );
  });

  it("one primitive types and one user defined data typeis called", done => {
    __nimbus.plugins.callbackTestPlugin.callbackWithPrimitiveAndUddtParams(
      (param0: number, param1: MochaMessage) => {
        expect(param0).to.equal(777);
        expect(param1).to.deep.equal({
          intField: 42,
          stringField: "This is a string"
        });
        done();
      }
    );
  });

  it("promise resolves and passes the value", done => {
    __nimbus.plugins.callbackTestPlugin
      .promiseResolved()
      .then((result: string) => {
        expect(result).to.equal("promise");
        done();
      });
  });

  it("promise rejects and passes the error", done => {
    __nimbus.plugins.callbackTestPlugin
      .promiseRejected()
      .then(_ => done("unexpected completion"))
      .catch(_ => {
        done();
      });
  });
});
