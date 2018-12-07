/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

class Veil {
  static promisify(src) {
    let dest = {};
    Object.keys(src).forEach(k => {
      let f = src[k];
      dest[k] = (...args) => {
        args = Veil.cloneArguments(args);
        return Promise.resolve(f.call(src, ...args));
      };
    });
    return dest;
  }

  static uuidv4() {
    return ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, c =>
      (
        c ^
        (crypto.getRandomValues(new Uint8Array(1))[0] & (15 >> (c / 4)))
      ).toString(16)
    );
  }

  static callCallback(callbackId, args) {
    if (Veil.callbacks[callbackId]) {
      Veil.callbacks[callbackId](...args);
    }
  }

  static cloneArguments(args) {
    var clonedArgs = [];
    for (var i = 0; i < args.length; ++i) {
      if (typeof args[i] === "function") {
        let callbackId = Veil.uuidv4();
        Veil.callbacks[callbackId] = args[i];
        clonedArgs.push(_Veil.makeCallback(callbackId));
      } else {
        clonedArgs.push(args[i]);
      }
    }
    return clonedArgs;
  }
}

Veil.callbacks = {};
