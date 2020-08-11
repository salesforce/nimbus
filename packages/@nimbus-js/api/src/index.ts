//
// Copyright (c) 2020, Salesforce.com, inc.
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
  var __nimbus: Nimbus;
}
