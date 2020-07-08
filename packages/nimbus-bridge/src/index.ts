//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or
// https://opensource.org/licenses/BSD-3-Clause
//

export { DeviceInfoPlugin, DeviceInfo } from "./plugins/device";
export { EventPublisher } from "./EventPublisher";

export interface NimbusPlugins {
  [s: string]: any;
}

export interface Nimbus {
  // Store any plugins injected by the native app here.
  plugins: NimbusPlugins;

  // Called by native code to execute a pending callback function.
  callCallback(callbackId: string, args: any[]): void;

  // Called by native code to execute a pending callback function.
  callCallback2(callbackId: string, ...args: any[]): void;

  // Called by native code to relese a pending callback function.
  releaseCallback(callbackId: string): void;

  // Called by native code to fulfill a pending promise.
  resolvePromise(promiseUuid: string, data: any, error: any): void;

  /**
   * Broadcast a message to subscribed listeners.  Listeners
   * can receive data associated with the message for more
   * processing.
   *
   * @param message String message that is uniquely
   *     registered as a key in the listener map.
   *     Multiple listeners can get triggered from a message.
   * @param arg Swift encodable type.
   * @return Number of listeners that were called by the
   *     message.
   */
  broadcastMessage(message: string, arg: any): number;

  /**
   * Subscribe a listener to message.
   *
   * @param message String message that is uniquely registered as a key
   *     in the listener map.  Multiple listeners can get triggered
   *     from a message.
   * @param listener A method that should be triggered when a message is
   *     broadcasted.
   */
  subscribeMessage(message: string, listener: Function): void;

  /**
   * Unsubscribe a listener from a message. Unsubscribed listener
   * will not be triggered.
   *
   * @param message String message that is uniquely registered as a
   *     key in the listener map.  Multiple listeners can get
   *     triggered from a message.
   * @param listener A method that should be triggered when a
   *     message is broadcasted.
   */
  unsubscribeMessage(message: string, listener: Function): void;
}

declare global {
  interface NimbusNative {
    makeCallback(callbackId: string): any;
    nativePluginNames(): string;
    pageUnloaded(): void;
  }
  var _nimbus: NimbusNative;
  var __nimbusPluginExports: { [s: string]: string[] };

  interface Window {
    [s: string]: any;
  }
}

let plugins: { [s: string]: any } = {};

// Store promise functions for later invocation
let uuidsToPromises: {
  [s: string]: { resolve: Function; reject: Function };
} = {};

// Store callback functions for later invocation
let uuidsToCallbacks: { [s: string]: Function } = {};

// Store event listener functions for later invocation
let eventNameToListeners: { [s: string]: Function[] } = {};

// influenced from
// https://stackoverflow.com/questions/105034/create-guid-uuid-in-javascript
let uuidv4 = (): string => {
  return "10000000-1000-4000-8000-100000000000".replace(
    /[018]/g,
    (c): string => {
      const asNumber = Number(c);
      return (
        asNumber ^
        (crypto.getRandomValues(new Uint8Array(1))[0] & (15 >> (asNumber / 4)))
      ).toString(16);
    }
  );
};

let cloneArguments = (args: any[]): any[] => {
  let clonedArgs = [];
  for (var i = 0; i < args.length; ++i) {
    if (typeof args[i] === "function") {
      const callbackId = uuidv4();
      uuidsToCallbacks[callbackId] = args[i];
      clonedArgs.push(callbackId);
    } else if (typeof args[i] === "object") {
      clonedArgs.push(JSON.stringify(args[i]));
    } else {
      clonedArgs.push(args[i]);
    }
  }
  return clonedArgs;
};

let promisify = (src: any): void => {
  let dest: any = {};
  Object.keys(src).forEach((key): void => {
    let func = src[key];
    dest[key] = (...args: any[]): Promise<any> => {
      args = cloneArguments(args);
      try {
        let result = func.call(src, ...args);
        if (result !== undefined) {
          result = JSON.parse(result);
        }
        return Promise.resolve(result);
      } catch (error) {
        return Promise.reject(error);
      }
    };
  });
  return dest;
};

let callCallback = (callbackId: string, ...args: any[]): void => {
  if (uuidsToCallbacks[callbackId]) {
    uuidsToCallbacks[callbackId](...args);
  }
};

let releaseCallback = (callbackId: string): void => {
  delete uuidsToCallbacks[callbackId];
};

// Native side will callback this method. Match the callback to stored promise
// in the storage
let resolvePromise = (promiseUuid: string, data: any, error: any): void => {
  if (error) {
    uuidsToPromises[promiseUuid].reject(error);
  } else {
    uuidsToPromises[promiseUuid].resolve(data);
  }
  // remove reference to stored promise
  delete uuidsToPromises[promiseUuid];
};

let broadcastMessage = (message: string, arg: any): number => {
  let messageListeners = eventNameToListeners[message];
  var handlerCallCount = 0;
  if (messageListeners) {
    messageListeners.forEach((listener: any): void => {
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

let subscribeMessage = (message: string, listener: Function): void => {
  let messageListeners = eventNameToListeners[message];
  if (!messageListeners) {
    messageListeners = [];
  }
  messageListeners.push(listener);
  eventNameToListeners[message] = messageListeners;
};

let unsubscribeMessage = (message: string, listener: Function): void => {
  let messageListeners = eventNameToListeners[message];
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
      eventNameToListeners[message] = messageListeners;
    }
  }
};

// Android plugin import
if (typeof _nimbus !== "undefined" && _nimbus.nativePluginNames !== undefined) {
  // we're on Android, need to wrap native extension methods
  let extensionNames = JSON.parse(_nimbus.nativePluginNames());
  extensionNames.forEach((extension: string): void => {
    Object.assign(plugins, {
      [extension]: Object.assign(
        plugins[`${extension}`] || {},
        promisify(window[`_${extension}`])
      )
    });
  });
}

// iOS plugin import
if (typeof __nimbusPluginExports !== "undefined") {
  Object.keys(__nimbusPluginExports).forEach((pluginName: string): void => {
    let plugin = {};
    __nimbusPluginExports[pluginName].forEach((method: string): void => {
      Object.assign(plugin, {
        [method]: function(): Promise<any> {
          let functionArgs = cloneArguments(Array.from(arguments));
          return new Promise(function(resolve, reject): void {
            var promiseId = uuidv4();
            uuidsToPromises[promiseId] = { resolve, reject };
            window.webkit.messageHandlers[pluginName].postMessage({
              method: method,
              args: functionArgs,
              promiseId: promiseId
            });
          });
        }
      });
    });
    Object.assign(plugins, {
      [pluginName]: plugin
    });
  });
}

let nimbusBuilder = {
  plugins: plugins
};

Object.defineProperties(nimbusBuilder, {
  callCallback: {
    value: callCallback
  },
  releaseCallback: {
    value: releaseCallback
  },
  resolvePromise: {
    value: resolvePromise
  },
  broadcastMessage: {
    value: broadcastMessage
  },
  subscribeMessage: {
    value: subscribeMessage
  },
  unsubscribeMessage: {
    value: unsubscribeMessage
  }
});

let nimbus: Nimbus = nimbusBuilder as Nimbus;

// When the page unloads, reject all Promises for native-->web calls.
window.addEventListener("unload", (): void => {
  if (typeof _nimbus !== "undefined") {
    _nimbus.pageUnloaded();
  } else if (typeof window.webkit !== "undefined") {
    window.webkit.messageHandlers._nimbus.postMessage({
      method: "pageUnloaded"
    });
  }
});

declare global {
  var __nimbus: Nimbus;
}

window.__nimbus = nimbus;

export default nimbus;
