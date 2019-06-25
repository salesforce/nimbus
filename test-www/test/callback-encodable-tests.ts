//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import 'mocha';
import {expect} from 'chai';

describe('Callbacks with', () => {
  it('single user defined data type is called', (done) => {
    callbackTestExtension.callbackWithSingleParam((mm1: MochaMessage) => {
       expect(mm1).to.deep.equal(
         {intField: 42, stringField: 'This is a string'});
      done();
    });
  });

  it('two user defined data type is called', (done) => {
    callbackTestExtension.callbackWithTwoParams((mm1: MochaMessage, mm2: MochaMessage) => {
       expect(mm1).to.deep.equal(
         {intField: 42, stringField: 'This is a string'});
       expect(mm2).to.deep.equal(
         {intField: 6, stringField: 'int param is 6'});
      done();
    });
  });
});
