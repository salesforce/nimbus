//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or
// https://opensource.org/licenses/BSD-3-Clause
//

export { DeviceExtension, DeviceInfo } from "./extensions/device";

declare global {
  interface NimbusNative {
    makeCallback(callbackId: string): any;
    nativeExtensionNames(): string;
  }
  var _nimbus: NimbusNative;

  interface Window {
    [s: string]: any;
  }
}

interface FinishedPromise {
  promiseId: string;
  err?: any;
  result?: any;
}

function promiseFinishedHandler(
  namespace: string
): (msg: FinishedPromise) => void {
  return window.webkit
    ? (msg: FinishedPromise): void => window.webkit.messageHandlers[namespace].postMessage(msg)
    : (msg: FinishedPromise): void => window[namespace].finishPromise(msg.promiseId, msg.err, msg.result);
}

class Nimbus {
  public constructor() {
    if (
      typeof _nimbus !== "undefined" &&
      _nimbus.nativeExtensionNames !== undefined
    ) {
      // we're on Android, need to wrap native extension methods
      let extensionNames = JSON.parse(_nimbus.nativeExtensionNames());
      extensionNames.forEach((extension: string) => {
        Object.assign(window, {
          [extension]: Object.assign(window[extension] || {}, this.promisify(window[`_${extension}`]))
        });
      });
    }
  }

  // There can be many promises so creating a storage for later look-up.
  public promises: {
    [s: string]: { resolve: Function; reject: Function };
  } = {};
  private callbacks: { [s: string]: Function } = {};

  // Dictionary to manage message&subscriber relationship.
  public listenerMap: { [s: string]: Function[] } = {};

  // influenced from
  // https://stackoverflow.com/questions/105034/create-guid-uuid-in-javascript
  public uuidv4 = (): string => {
    return "10000000-1000-4000-8000-100000000000".replace(/[018]/g, c => {
      const asNumber = Number(c);
      return (
        asNumber ^
        (crypto.getRandomValues(new Uint8Array(1))[0] & (15 >> (asNumber / 4)))
      ).toString(16);
    });
  };

  public promisify = (src: any) => {
    let dest: any = {};
    Object.keys(src).forEach(key => {
      let func = src[key];
      dest[key] = (...args: any[]) => {
        args = this.cloneArguments(args);
        args = args.map(arg => {
          if (typeof arg === "object") {
            return JSON.stringify(arg);
          }
          return arg;
        });
        let result = func.call(src, ...args);
        if (result !== undefined) {
          result = JSON.parse(result);
        }
        return Promise.resolve(result);
      };
    });
    return dest;
  };

  public cloneArguments = (args: any[]): any[] => {
    let clonedArgs = [];
    for (var i = 0; i < args.length; ++i) {
      if (typeof args[i] === "function") {
        const callbackId = this.uuidv4();
        this.callbacks[callbackId] = args[i];
        // TODO: this should generalize better, perhaps with an explicit platform
        // check?
        if (
          typeof _nimbus !== "undefined" &&
          _nimbus.makeCallback !== undefined
        ) {
          // TODO: Android passes only the callbackId string, whereas iOS passes an
          // object with the callbackId property. These need to be merged and handled
          // the same way to eliminate extraneous code paths
          clonedArgs.push(callbackId);
        } else {
          clonedArgs.push({ callbackId });
        }
      } else {
        clonedArgs.push(args[i]);
      }
    }
    return clonedArgs;
  };

  public callCallback = (callbackId: string, args: any[]): void => {
    if (this.callbacks[callbackId]) {
      this.callbacks[callbackId](...args);
    }
  };

  // TODO: This version is called by Android, callCallback is called by iOS. The
  // two need to be consolidated.
  public callCallback2 = (callbackId: string, ...args: any[]): void => {
    this.callCallback(callbackId, args);
  };

  public releaseCallback = (callbackId: string): void => {
    delete this.callbacks[callbackId];
  };

  // Native side will callback this method. Match the callback to stored promise
  // in the storage
  public resolvePromise = (promiseUuid: string, data: any, error: any): void => {
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
  public broadcastMessage = (message: string, arg: any): number => {
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
  public subscribeMessage = (message: string, listener: Function): void => {
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
  public unsubscribeMessage = (message: string, listener: Function): void => {
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

  /**
   * Call a Promise-returning function and track its resolution/rejection.
   * 
   * @param namespace String connection name, used both to find the function to
   * invoke (window.${namespace}.${name} as well as to identify the message
   * handler to inform about the resolutin/rejection of the Promise.
   * @param name String name of the function on window.${namespace} to invoke.
   * @param args arguments to pass to the specified function.
   */
  public callAwaiting = (
    namespace: string,
    name: string,
    ...args: any[]
  ): string | null => {
    const ext = window[namespace];
    if (!ext) {
      console.error(`window.${namespace} was not found.`);
      return null;
    }
    const fn = ext[name];
    if (!fn) {
      console.error(`window.${namespace}.${name} was not found.`);
      return null;
    }
    const promise = fn(...args);
    const promiseId = this.uuidv4();
    const handler = promiseFinishedHandler(namespace);
    promise.catch((err: any): void => handler({ promiseId, err }));
    promise.then((result: any): void => handler({ promiseId, result }));
    return promiseId;
  };
}

const nimbus = new Nimbus();

declare global {
  interface Window {
    nimbus?: Nimbus;
  }
}
window.nimbus = nimbus;

export default nimbus;
