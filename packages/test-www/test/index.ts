//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import nimbus from "nimbus-bridge";
import "./nimbus-core-tests";
import "./broadcast-tests";
import "./callback-encodable-tests";
import "./promised-javascript-tests";

const { plugins } = nimbus;

let callbackTestExtension = plugins.callbackTestExtension;

if (callbackTestExtension !== undefined) {
  callbackTestExtension.addOne = (x: number) => Promise.resolve(x + 1);
  callbackTestExtension.failWith = (message: string) => Promise.reject(message);
  callbackTestExtension.wait = (milliseconds: number) =>
    new Promise(resolve => setTimeout(resolve, milliseconds));
}

window.onload = () => {
  nimbus.plugins.mochaTestBridge.ready();
};
