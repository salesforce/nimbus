//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or
// https://opensource.org/licenses/BSD-3-Clause
//

/**
 * The Device extensions provides access to information about the device in
 * which the application is executing.
 */
export interface DeviceInfoPlugin {
  /// Return information about the current device
  getDeviceInfo(): Promise<DeviceInfo>;
}

export interface DeviceInfo {
  /// The device operating system
  platform: string;
  /// The device operating system version
  platformVersion: string;
  /// The device manufacturer
  manufacturer: string;
  /// The device model
  model: string;
  /// The version of the application
  appVersion: string;
}

export interface NimbusPlugins {
  DeviceInfoPlugin: DeviceInfoPlugin;
}
