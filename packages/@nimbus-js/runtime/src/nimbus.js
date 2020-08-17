//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or
// https://opensource.org/licenses/BSD-3-Clause
//

// @ts-check

/**
 * @typedef { import("@nimbus-js/api").NimbusPlugins } NimbusPlugins
 */

var __nimbus = (function() {
  /**
   * @type {NimbusPlugins}
   */
  let plugins = {};

  // Store promise functions for later invocation
  /**
   *  @type { { [s: string]: { resolve: Function; reject: Function }; } }
   */
  let uuidsToPromises = {};

  // Store callback functions for later invocation
  //

  /**
   * @type  { { [s: string]: Function } }
   */
  var uuidsToCallbacks = {};

  // Store event listener functions for later invocation
  /**
   * @type { { [s: string]: Function[] } }
   */
  let eventNameToListeners = {};

  // influenced from
  // https://stackoverflow.com/questions/105034/create-guid-uuid-in-javascript
  /**
   * @returns {string}
   */
  let uuidv4 = () => {
    return "10000000-1000-4000-8000-100000000000".replace(/[018]/g, c => {
      const asNumber = Number(c);
      return (
        asNumber ^
        (crypto.getRandomValues(new Uint8Array(1))[0] & (15 >> (asNumber / 4)))
      ).toString(16);
    });
  };

  /**
   * @param {any[]} args
   * @returns {any[]}
   */
  let cloneArguments = args => {
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

  /**
   * @param {*} src
   * @returns {Object}
   */
  let promisify = src => {
    /** @type { {[s: string]: function(...any[]): Promise<any>} } */
    let dest = {};
    Object.keys(src).forEach(key => {
      let func = src[key];
      dest[key] = (...args) => {
        args = cloneArguments(args);

        return new Promise(function(resolve, reject) {
          var promiseId = uuidv4();
          uuidsToPromises[promiseId] = { resolve, reject };
          try {
            func.call(src, JSON.stringify({ promiseId }), ...args);
          } catch (error) {
            delete uuidsToPromises[promiseId];
            reject(error);
          }
        });
      };
    });
    return dest;
  };

  /**
   * @param {string} callbackId
   * @param {...any[]} args
   */
  let callCallback = (callbackId, ...args) => {
    if (uuidsToCallbacks[callbackId]) {
      uuidsToCallbacks[callbackId](...args);
    }
  };

  /**
   * @param {string} callbackId
   */
  let releaseCallback = callbackId => {
    delete uuidsToCallbacks[callbackId];
  };

  // Native side will callback this method. Match the callback to stored promise
  // in the storage
  /**
   * @param {string} promiseUuid
   * @param {*} data
   * @param {*} error
   */
  let resolvePromise = (promiseUuid, data, error) => {
    if (error) {
      uuidsToPromises[promiseUuid].reject(error);
    } else {
      uuidsToPromises[promiseUuid].resolve(data);
    }
    // remove reference to stored promise
    delete uuidsToPromises[promiseUuid];
  };

  /**
   * @param {string} message
   * @param {*} arg
   * @returns {number}
   */
  let broadcastMessage = (message, arg) => {
    let messageListeners = eventNameToListeners[message];
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
   * @param {string} message
   * @param {Function} listener
   */
  let subscribeMessage = (message, listener) => {
    let messageListeners = eventNameToListeners[message];
    if (!messageListeners) {
      messageListeners = [];
    }
    messageListeners.push(listener);
    eventNameToListeners[message] = messageListeners;
  };

  /**
   * @param {string} message
   * @param {Function} listener
   */
  let unsubscribeMessage = (message, listener) => {
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

  // { import("global.d.ts") }

  // Android plugin import
  if (
    typeof _nimbus !== "undefined" &&
    _nimbus.nativePluginNames !== undefined
  ) {
    // we're on Android, need to wrap native extension methods
    /** @type string[] */
    let extensionNames = JSON.parse(_nimbus.nativePluginNames());
    extensionNames.forEach(extension => {
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
    Object.keys(__nimbusPluginExports).forEach(pluginName => {
      let plugin = {};
      __nimbusPluginExports[pluginName].forEach(method => {
        Object.assign(plugin, {
          [method]: function() {
            let functionArgs = cloneArguments(Array.from(arguments));
            return new Promise(function(resolve, reject) {
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

  /** @type { import("@nimbus-js/api").Nimbus } */
  let nimbus = Object.defineProperties(nimbusBuilder, {
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

  // When the page unloads, reject all Promises for native-->web calls.
  window.addEventListener("unload", () => {
    if (typeof _nimbus !== "undefined") {
      _nimbus.pageUnloaded();
    } else if (typeof window.webkit !== "undefined") {
      window.webkit.messageHandlers._nimbus.postMessage({
        method: "pageUnloaded"
      });
    }
  });

  return nimbus;
})();
