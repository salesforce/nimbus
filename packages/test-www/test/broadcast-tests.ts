//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import "mocha";
import { expect } from "chai";
import { nimbus } from "nimbus-bridge";

describe("Message Broadcasting", () => {
  it("calls listener when message is broadcast", done => {
    let listener = () => {
      nimbus.unsubscribeMessage("test-message", listener);
      done();
    };
    nimbus.subscribeMessage("test-message", listener);
    mochaTestBridge.sendMessage("test-message", false);
  });

  it("encodes the message when including a param", async () => {
    let promise = new Promise((resolve, _) => {
      let listener = (message: object) => {
        nimbus.unsubscribeMessage("test-message-with-param", listener);
        // todo: assert shape of message
        resolve(message);
      };
      nimbus.subscribeMessage("test-message-with-param", listener);
    });
    mochaTestBridge.sendMessage("test-message-with-param", true);
    let message = await promise;
    expect(message).to.be.an("object");
    expect(message).to.deep.equal({
      stringField: "This is a string",
      intField: 42
    });
  });

  it("does not call a handler after it is unsubscribed", async () => {
    let listener = () => {
      throw new Error("listener should not be called");
    };
    nimbus.subscribeMessage("test-message-no-listener", listener);
    nimbus.unsubscribeMessage("test-message-no-listener", listener);
    nimbus.broadcastMessage("test-message-no-listener", undefined);
    mochaTestBridge.sendMessage("test-message-no-listener", false);
  });
});
