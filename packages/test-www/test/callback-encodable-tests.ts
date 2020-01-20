//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import 'mocha';
import { expect } from 'chai';

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
  promiseWithPrimitive(): Promise<String>;
  promiseWithDictionaryParam(): Promise<MochaMessage>;
  promiseWithMultipleParamsAndDictionaryParam(param0: number, param1: string): Promise<MochaMessage>;
  promiseRejects(): Promise<MochaMessage>;
  promiseWithMultipleParamsRejects(param0: number, param1: number): Promise<MochaMessage>;
}

declare var callbackTestExtension: CallbackTestExtension;

describe('Callbacks with', () => {
  it('single user defined data type is called', (done) => {
    callbackTestExtension.callbackWithSingleParam((param0: MochaMessage) => {
      expect(param0).to.deep.equal(
        { intField: 42, stringField: 'This is a string' });
      done();
    });
  });

  it('two user defined data types is called', (done) => {
    callbackTestExtension.callbackWithTwoParams((param0: MochaMessage, param1: MochaMessage) => {
      expect(param0).to.deep.equal(
        { intField: 42, stringField: 'This is a string' });
      expect(param1).to.deep.equal(
        { intField: 6, stringField: 'int param is 6' });
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
        { intField: 42, stringField: 'This is a string' });
      done();
    });
  });

  it('one primitive types and one user defined data type is called', (done) => {
    callbackTestExtension.callbackWithPrimitiveAndUddtParams((param0: number, param1: MochaMessage) => {
      expect(param0).to.equal(777);
      expect(param1).to.deep.equal(
        { intField: 42, stringField: 'This is a string' });
      done();
    });
  });

  it('method that returns promise called with one string param', (done) => {
    callbackTestExtension.promiseWithPrimitive().then((result) => {
      expect(result).to.equal("one");
      done();
    });
  });

  it('promise called with one object param', (done) => {
    callbackTestExtension.promiseWithDictionaryParam().then((result) => {
      expect(result).to.deep.equal(
        { intField: 6, stringField: 'int param is 6' });
      done();
    });
  });

  it('promise called with multiple params', (done) => {
    callbackTestExtension.promiseWithMultipleParamsAndDictionaryParam(777, "promise made").then((result) => {
      expect(result).to.deep.equal(
        { intField: 777, stringField: 'promise made' });
      done();
    });
  });

  it('promise called and returns in a rejected state.', (done) => {
    callbackTestExtension.promiseRejects().catch((error) => {
      expect(error).equals('rejected');
      done();
    });
  });

  it('promise called with multiple param and returns in a rejected state.', (done) => {
    callbackTestExtension.promiseWithMultipleParamsRejects(777, 888).catch((error) => {
      expect(error).equals('rejected');
      done();
    });
  });
});
