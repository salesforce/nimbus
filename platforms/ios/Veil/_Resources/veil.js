// Namespace for Veil
var SalesforceVeil = SalesforceVeil || {}

// Dictionary to manage message&subscriber relationship.
SalesforceVeil.listenerMap = {}

/**
 * Broadcast a message to subscribed listeners.  Listeners can
 * receive data associated with the message for more processing.
 *
 * @param message String message that is uniquely registered as a key in the
 *                listener map.  Multiple listeners can get triggered from a
 *                message.
 * @param arg Swift encodable type.
 * @return Number of listeners that were called by the message.
 */
SalesforceVeil.broadcastMessage = function(message, arg) {
    let messageListeners = this.listenerMap[message];
    var handlerCallCount = 0;
    if (messageListeners) {
        messageListeners.forEach((listener)=> {
             if (arg) {
                 listener(arg);
             } else {
                 listener();
             }
             handlerCallCount++;
        });
    }
    return handlerCallCount;
}
/**
 * Subscribe a listener to message.
 *
 * @param message String message that is uniquely registered as a key in the
 *                listener map.  Multiple listeners can get triggered from a
 *                message.
 * @param listener A method that should be triggered when a message is broadcasted.
 */
SalesforceVeil.subscribeMessage = function(message, listener) {
    let messageListeners = this.listenerMap[message];
    if (!messageListeners) {
        messageListeners = [];
    }
    messageListeners.push(listener);
    this.listenerMap[message] = messageListeners;
}

/**
 * Unsubscribe a listener from a message. Unsubscribed listener will not be triggered.
 *
 * @param message String message that is uniquely registered as a key in the
 *                listener map.  Multiple listeners can get triggered from a
 *                message.
 * @param listener A method that should be triggered when a message is broadcasted.
 */
SalesforceVeil.unsubscribeMessage = function(message, listener) {
    let messageListeners = this.listenerMap[message];
    if (messageListeners) {
        let counter = 0;
        let found = false;
        for(counter; counter < messageListeners.length; counter++) {
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
}

// There can be many promises so creating a storage for later look-up.
var promises = {}
var callbacks = {}

// https://stackoverflow.com/questions/105034/create-guid-uuid-in-javascript
function uuidv4() {
    return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c =>
                                                (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16));
}

function cloneArguments(args) {
    var clonedArgs = []
    for (var i = 0; i < args.length; ++i) {
        if (typeof args[i] === 'function') {
            let callbackId = uuidv4();
            callbacks[callbackId] = args[i];
            clonedArgs.push({callbackId});
        } else {
            clonedArgs.push(args[i]);
        }
    }
    return clonedArgs;
}

function callCallback(callbackId, args) {
    if (callbacks[callbackId]) {
        callbacks[callbackId](...args);
    }
}

// Native side will callback this method. Match the callback to stored promise
// in the storage
function resolvePromise(promiseUuid, data, error) {
    if (error) {
        promises[promiseUuid].reject(data);
    } else {
        promises[promiseUuid].resolve(data.v);
    }
    // remove reference to stored promise
    delete promises[promiseUuid];
}
