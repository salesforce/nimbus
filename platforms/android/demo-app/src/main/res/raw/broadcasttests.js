// Copyright (c) 2019, salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause

function callMe() {
    console.log("callMe called");
    return "callMe called";
}

function callMeWithParam(arg) {
    console.log("callMeWithParam called");
    return "callMeWithParam called";
}

function unsubscribeTestMessageWithNoParam() {
    Veil.unsubscribeMessage("testMessageWithNoParam", callMe);
}

Veil.subscribeMessage("testMessageWithNoParam", callMe);
Veil.subscribeMessage("testMessageWithParam", callMeWithParam);
Veil.subscribeMessage("testUnsubscribingHandler", unsubscribeTestMessageWithNoParam);
