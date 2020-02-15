//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

const mochaTestBridge = window.mochaTestBridge || {}
mochaTestBridge.myProp = "exists";

const { plugins } = window.__nimbus!
const callbackTestExtension = plugins.callbackTestExtension || (plugins.callbackTestExtension = {})

callbackTestExtension.addOne = (x: number) => Promise.resolve(x + 1)
callbackTestExtension.failWith = (message: string) => Promise.reject(message)

export default mochaTestBridge
