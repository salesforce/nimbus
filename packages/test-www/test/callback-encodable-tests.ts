//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import 'mocha';
import {expect} from 'chai';

interface MochaMessage {
  intField: number;
  stringField: string;
}

interface CallbackTestExtension {
  callbackWithSingleParam(completion: (param0: MochaMessage) => void): void;
  callbackWithTwoParams(completion: (param0: MochaMessage, param1: MochaMessage) => void): void;
  callbackWithSinglePrimitiveParam(completion: (param0: number) => void): void;
  callbackWithTwoPrimitiveParams(completion: (param0: number, param1: number) => void): void;
  callbackWithPrimitiveAndUddtParams(completion: (param0: number, param1: MochaMessage) => void): void;
}

declare var callbackTestExtension: CallbackTestExtension;

describe('Callbacks with', () => {
  it('single user defined data type is called', (done) => {
    callbackTestExtension.callbackWithSingleParam((param0: MochaMessage) => {
       expect(param0).to.deep.equal(
         {intField: 42, stringField: 'This is a string'});
      done();
    });
  });

  it('two user defined data types is called', (done) => {
    callbackTestExtension.callbackWithTwoParams((param0: MochaMessage, param1: MochaMessage) => {
       expect(param0).to.deep.equal(
         {intField: 42, stringField: 'This is a string'});
       expect(param1).to.deep.equal(
         {intField: 6, stringField: 'int param is 6'});
      done();
    });
  });

  it('single primitive type is called', (done) => {
    callbackTestExtension.callbackWithSinglePrimitiveParam((param0: number) => {
      expect(param0).to.equal(777);
      done();
    });
  });

  it('two primitive types is called', (done) => {
    callbackTestExtension.callbackWithTwoPrimitiveParams((param0: number, param1: number) => {
       expect(param0).to.equal(777);
       expect(param1).to.equal(888);
      done();
    });
  });

  it('one primitive types and one user defined data typeis called', (done) => {
    callbackTestExtension.callbackWithPrimitiveAndUddtParams((param0: number, param1: MochaMessage) => {
       expect(param0).to.equal(777);
       expect(param1).to.deep.equal(
        {intField: 42, stringField: 'This is a string'});
      done();
    });
  });
});
