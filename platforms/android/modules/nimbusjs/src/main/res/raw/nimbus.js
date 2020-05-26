var __nimbus = (function () {
    'use strict';

    /*! *****************************************************************************
    Copyright (c) Microsoft Corporation. All rights reserved.
    Licensed under the Apache License, Version 2.0 (the "License"); you may not use
    this file except in compliance with the License. You may obtain a copy of the
    License at http://www.apache.org/licenses/LICENSE-2.0

    THIS CODE IS PROVIDED ON AN *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
    WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
    MERCHANTABLITY OR NON-INFRINGEMENT.

    See the Apache Version 2.0 License for specific language governing permissions
    and limitations under the License.
    ***************************************************************************** */

    function __spreadArrays() {
        for (var s = 0, i = 0, il = arguments.length; i < il; i++) s += arguments[i].length;
        for (var r = Array(s), k = 0, i = 0; i < il; i++)
            for (var a = arguments[i], j = 0, jl = a.length; j < jl; j++, k++)
                r[k] = a[j];
        return r;
    }

    //
    var plugins = {};
    // Store promise functions for later invocation
    var uuidsToPromises = {};
    // Store callback functions for later invocation
    var uuidsToCallbacks = {};
    // Store event listener functions for later invocation
    var eventNameToListeners = {};
    // influenced from
    // https://stackoverflow.com/questions/105034/create-guid-uuid-in-javascript
    var uuidv4 = function () {
        return "10000000-1000-4000-8000-100000000000".replace(/[018]/g, function (c) {
            var asNumber = Number(c);
            return (asNumber ^
                (crypto.getRandomValues(new Uint8Array(1))[0] & (15 >> (asNumber / 4)))).toString(16);
        });
    };
    var cloneArguments = function (args) {
        var clonedArgs = [];
        for (var i = 0; i < args.length; ++i) {
            if (typeof args[i] === "function") {
                var callbackId = uuidv4();
                uuidsToCallbacks[callbackId] = args[i];
                clonedArgs.push(callbackId);
            }
            else if (typeof args[i] === "object") {
                clonedArgs.push(JSON.stringify(args[i]));
            }
            else {
                clonedArgs.push(args[i]);
            }
        }
        return clonedArgs;
    };
    var promisify = function (src) {
        var dest = {};
        Object.keys(src).forEach(function (key) {
            var func = src[key];
            dest[key] = function () {
                var args = [];
                for (var _i = 0; _i < arguments.length; _i++) {
                    args[_i] = arguments[_i];
                }
                args = cloneArguments(args);
                var result = func.call.apply(func, __spreadArrays([src], args));
                if (result !== undefined) {
                    result = JSON.parse(result);
                }
                return Promise.resolve(result);
            };
        });
        return dest;
    };
    var callCallback = function (callbackId) {
        var args = [];
        for (var _i = 1; _i < arguments.length; _i++) {
            args[_i - 1] = arguments[_i];
        }
        if (uuidsToCallbacks[callbackId]) {
            uuidsToCallbacks[callbackId].apply(uuidsToCallbacks, args);
        }
    };
    var releaseCallback = function (callbackId) {
        delete uuidsToCallbacks[callbackId];
    };
    // Native side will callback this method. Match the callback to stored promise
    // in the storage
    var resolvePromise = function (promiseUuid, data, error) {
        if (error) {
            uuidsToPromises[promiseUuid].reject(data);
        }
        else {
            uuidsToPromises[promiseUuid].resolve(data);
        }
        // remove reference to stored promise
        delete uuidsToPromises[promiseUuid];
    };
    var broadcastMessage = function (message, arg) {
        var messageListeners = eventNameToListeners[message];
        var handlerCallCount = 0;
        if (messageListeners) {
            messageListeners.forEach(function (listener) {
                if (arg) {
                    listener(arg);
                }
                else {
                    listener();
                }
                handlerCallCount++;
            });
        }
        return handlerCallCount;
    };
    var subscribeMessage = function (message, listener) {
        var messageListeners = eventNameToListeners[message];
        if (!messageListeners) {
            messageListeners = [];
        }
        messageListeners.push(listener);
        eventNameToListeners[message] = messageListeners;
    };
    var unsubscribeMessage = function (message, listener) {
        var messageListeners = eventNameToListeners[message];
        if (messageListeners) {
            var counter = 0;
            var found = false;
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
        var extensionNames = JSON.parse(_nimbus.nativePluginNames());
        extensionNames.forEach(function (extension) {
            var _a;
            Object.assign(plugins, (_a = {},
                _a[extension] = Object.assign(plugins["" + extension] || {}, promisify(window["_" + extension])),
                _a));
        });
    }
    // iOS plugin import
    if (typeof __nimbusPluginExports !== "undefined") {
        Object.keys(__nimbusPluginExports).forEach(function (pluginName) {
            var _a;
            var plugin = {};
            __nimbusPluginExports[pluginName].forEach(function (method) {
                var _a;
                Object.assign(plugin, (_a = {},
                    _a[method] = function () {
                        var functionArgs = cloneArguments(Array.from(arguments));
                        return new Promise(function (resolve, reject) {
                            var promiseId = uuidv4();
                            uuidsToPromises[promiseId] = { resolve: resolve, reject: reject };
                            window.webkit.messageHandlers[pluginName].postMessage({
                                method: method,
                                args: functionArgs,
                                promiseId: promiseId
                            });
                        });
                    },
                    _a));
            });
            Object.assign(plugins, (_a = {},
                _a[pluginName] = plugin,
                _a));
        });
    }
    var nimbusBuilder = {
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
    var nimbus = nimbusBuilder;
    // When the page unloads, reject all Promises for native-->web calls.
    window.addEventListener("unload", function () {
        if (typeof _nimbus !== "undefined") {
            _nimbus.pageUnloaded();
        }
        else if (typeof window.webkit !== "undefined") {
            window.webkit.messageHandlers._nimbus.postMessage({
                method: "pageUnloaded"
            });
        }
    });
    window.__nimbus = nimbus;

    return nimbus;

}());
