//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import nimbus from "nimbus-types";
import "./nimbus-core-tests";
import "./broadcast-tests";
import "./callback-encodable-tests";

const { plugins } = nimbus;

let callbackTestPlugin: any = plugins.callbackTestPlugin;

if (callbackTestPlugin !== undefined) {
  callbackTestPlugin.addOne = (x: number) => Promise.resolve(x + 1);
  callbackTestPlugin.failWith = (message: string) => Promise.reject(message);
  callbackTestPlugin.wait = (milliseconds: number) =>
    new Promise((resolve) => setTimeout(resolve, milliseconds));
}

window.onload = () => {
  __nimbus.plugins.mochaTestBridge.ready();
};
