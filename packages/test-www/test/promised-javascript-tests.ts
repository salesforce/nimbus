//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import "mocha";
import { expect } from "chai";
import __nimbus from "nimbus-bridge";

interface PromiseFinished {
  promiseId: string,
  err: string | null,
  result: any | null
}

interface PromiseFinishedSpy {
  expectThen: (expected: PromiseFinished, done: Function) => void
}

describe("Native --> Promise-returning Javascript function", () => {
  before(() => {
    __nimbus.plugins.TestExt = {
      f_0_succeed: () => Promise.resolve(26),
      f_0_fail: () => Promise.reject("terrible"),
      f_1_succeed: (x: number) => Promise.resolve(x + 1),
      f_1_fail: (x: number) => Promise.reject(`${x - 1}`)
    }
  })
  after(() => {
    delete __nimbus.plugins.TestExt
  })

  let promiseFinishedSpy: PromiseFinishedSpy | null
  function setupWebkitSpy() {
    let _expected: PromiseFinished | null = null
    let _done: Function | null = null
    window.webkit.messageHandlers.TestExt = {
      postMessage: (msg: PromiseFinished) => {
        if (!msg.err) msg.err = null
        if (!msg.result) msg.result = null
        expect(msg).to.deep.equal(_expected)
        _done!()
      }
    }

    promiseFinishedSpy = {
      expectThen: (expected: PromiseFinished, done: Function) => {
        _expected = expected
        _done = done
      }
    }
  }
  function teardownWebkitSpy() {
    promiseFinishedSpy = null
    delete window.webkit.messageHandlers.TestExt
  }

  function setupAndroidSpy() {
    let _expected: PromiseFinished | null = null
    let _done: Function | null = null
    Object.keys(__nimbus.plugins.TestExt).forEach(name => {
      __nimbus.plugins.TestExt[`__${name}_finished`] = (promiseId: string, err: string | null, result: any | null) => {
        if (!err) err = null
        if (!result) result = null
        expect({ promiseId, err, result }).to.deep.equal(_expected)
        _done!()
      }
    })

    promiseFinishedSpy = {
      expectThen: (expected: PromiseFinished, done: Function) => {
        _expected = expected
        _done = done
      }
    }
  }
  function teardownAndroidSpy() {
    promiseFinishedSpy = null
    Object.keys(__nimbus.plugins.TestExt).filter(name => name.startsWith("__")).forEach(name => {
      delete __nimbus.plugins.TestExt[name]
    })
  }

  if (window.webkit && window.webkit.messageHandlers) {
    beforeEach(setupWebkitSpy)
    afterEach(teardownWebkitSpy)
  } else {
    beforeEach(setupAndroidSpy)
    afterEach(teardownAndroidSpy)
  }

  describe("with no args", () => {
    it("calls promise handler on resolve", done => {
      promiseFinishedSpy!.expectThen({ promiseId: "_ID_", err: null, result: 26 }, done)
      expect(__nimbus.callAwaiting("TestExt", "f_0_succeed", "_ID_")).to.be.null
    })

    it("calls promise handler on reject", done => {
      promiseFinishedSpy!.expectThen({ promiseId: "_ID_", err: "terrible", result: null }, done)
      expect(__nimbus.callAwaiting("TestExt", "f_0_fail", "_ID_")).to.be.null
    })
  })

  describe("with one args", () => {
    it("calls promise handler on resolve", done => {
      promiseFinishedSpy!.expectThen({ promiseId: "_ID_", err: null, result: 6 }, done)
      expect(__nimbus.callAwaiting("TestExt", "f_1_succeed", "_ID_", 5)).to.be.null
    })

    it("calls promise handler on reject", done => {
      promiseFinishedSpy!.expectThen({ promiseId: "_ID_", err: "4", result: null }, done)
      expect(__nimbus.callAwaiting("TestExt", "f_1_fail", "_ID_", 5)).to.be.null
    })
  })
});
