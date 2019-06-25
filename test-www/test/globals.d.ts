//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

interface MochaMessage {
  intField: number;
  stringField: string;
}

interface MochaTestBridge {
  ready(): void;
  sendMessage(name: string, includeParam: boolean): void;
}

interface CallbackTestExtension {
  callbackWithSingleParam(completion: (mm1: MochaMessage) => void): void;
  callbackWithTwoParams(completion: (mm1: MochaMessage, mm2: MochaMessage) => void): void;
}

declare var mochaTestBridge: MochaTestBridge;
declare var callbackTestExtension: CallbackTestExtension;
