//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import "./nimbus-core-tests";
import "./broadcast-tests";
import "./callback-encodable-tests";
import nimbus from "nimbus-bridge";

window.onload = () => {
  nimbus;
  mochaTestBridge.ready();
};
