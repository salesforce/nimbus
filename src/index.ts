//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or
// https://opensource.org/licenses/BSD-3-Clause
//

declare global {
  interface _Nimbus {
    makeCallback(callbackId: string): any;
    nativeExtensionNames(): string;
  }
  var _nimbus: _Nimbus;

  interface Window {
    [s: string]: any
  }
}

class Nimbus {
  constructor() {
    if (typeof _nimbus !== 'undefined' &&
        _nimbus.nativeExtensionNames !== undefined) {
      // we're on Android, need to wrap native extension methods
      let extensionNames = JSON.parse(_nimbus.nativeExtensionNames());
      extensionNames.forEach((extension: string) => {
        Object.assign(
            window, {[extension]: this.promisify(window[`_${extension}`])});
      });
    }
  }

  // There can be many promises so creating a storage for later look-up.
  public promises: {[s: string]: {resolve: Function; reject: Function};} = {};
  private callbacks: {[s: string]: Function} = {};

  // Dictionary to manage message&subscriber relationship.
  public listenerMap: {[s: string]: Function[]} = {};

  // influenced from
  // https://stackoverflow.com/questions/105034/create-guid-uuid-in-javascript
  public uuidv4 = (): string => {
    return '10000000-1000-4000-8000-100000000000'.replace(/[018]/g, c => {
      const asNumber = Number(c);
      return (asNumber ^
              (crypto.getRandomValues(new Uint8Array(1))[0] &
               (15 >> (asNumber / 4))))
          .toString(16);
    });
  };

  public promisify =
      (src: any) => {
        let dest: any = {};
        Object.keys(src).forEach(k => {
          let f = src[k];
          dest[k] = (...args: any[]) => {
            args = this.cloneArguments(args);
            return Promise.resolve(f.call(src, ...args));
          };
        });
        return dest;
      }

  public cloneArguments = (args: any[]): any[] => {
    let clonedArgs = [];
    for (var i = 0; i < args.length; ++i) {
      if (typeof args[i] === 'function') {
        const callbackId = this.uuidv4();
        this.callbacks[callbackId] = args[i];
        // TODO: this should generalize better, perhaps with an explicit
        // platform check?
        if (typeof _nimbus !== 'undefined' &&
            _nimbus.makeCallback !== undefined) {
          clonedArgs.push(_nimbus.makeCallback(callbackId));
        } else {
          clonedArgs.push({callbackId});
        }
      } else {
        clonedArgs.push(args[i]);
      }
    }
    return clonedArgs;
  };

  public callCallback = (callbackId: string, args: [any]) => {
    if (this.callbacks[callbackId]) {
      this.callbacks[callbackId](...args);
    }
  };

  public releaseCallback = (callbackId: string) => {
    delete this.callbacks[callbackId];
  };

  // Native side will callback this method. Match the callback to stored promise
  // in the storage
  public resolvePromise = (promiseUuid: string, data: any, error: any) => {
    if (error) {
      this.promises[promiseUuid].reject(data);
    } else {
      this.promises[promiseUuid].resolve(data);
    }
    // remove reference to stored promise
    delete this.promises[promiseUuid];
  };

  /**
   * Broadcast a message to subscribed listeners.  Listeners
   * can receive data associated with the message for more
   * processing.
   *
   * @param message String message that is uniquely
   *     registered as a key in the
   *                listener map.  Multiple listeners can
   * get triggered from a message.
   * @param arg Swift encodable type.
   * @return Number of listeners that were called by the
   *     message.
   */
  public broadcastMessage = (message: string, arg: any) => {
    let messageListeners = this.listenerMap[message];
    var handlerCallCount = 0;
    if (messageListeners) {
      messageListeners.forEach(listener => {
        if (arg) {
          listener(arg);
        } else {
          listener();
        }
        handlerCallCount++;
      });
    }
    return handlerCallCount;
  };

  /**
   * Subscribe a listener to message.
   *
   * @param message String message that is uniquely registered as a key
   *     in the
   *                listener map.  Multiple listeners can get triggered
   * from a message.
   * @param listener A method that should be triggered when a message is
   *     broadcasted.
   */
  public subscribeMessage = (message: string, listener: Function) => {
    let messageListeners = this.listenerMap[message];
    if (!messageListeners) {
      messageListeners = [];
    }
    messageListeners.push(listener);
    this.listenerMap[message] = messageListeners;
  };

  /**
   * Unsubscribe a listener from a message. Unsubscribed listener
   * will not be triggered.
   *
   * @param message String message that is uniquely registered as a
   *     key in the
   *                listener map.  Multiple listeners can get
   * triggered from a message.
   * @param listener A method that should be triggered when a
   *     message is broadcasted.
   */
  public unsubscribeMessage = (message: string, listener: Function) => {
    let messageListeners = this.listenerMap[message];
    if (messageListeners) {
      let counter = 0;
      let found = false;
      for (counter; counter < messageListeners.length; counter++) {
        if (messageListeners[counter] === listener) {
          found = true;
          break;
        }
      }
      if (found) {
        messageListeners.splice(counter, 1);
        this.listenerMap[message] = messageListeners;
      }
    }
  };
}

let nimbus = new Nimbus();
declare global {
  interface Window {
    nimbus?: Nimbus;
  }
}
window.nimbus = nimbus;

export default nimbus;
