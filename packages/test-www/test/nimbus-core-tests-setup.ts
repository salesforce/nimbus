//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

const mochaTestBridge = window.mochaTestBridge || {}
mochaTestBridge.myProp = "exists";

mochaTestBridge.addOne = (x: number) => Promise.resolve(x + 1)
mochaTestBridge.failWith = (message: string) => Promise.reject(message)

export default mochaTestBridge
