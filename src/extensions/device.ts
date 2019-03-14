import {Extension} from '../extension';

/**
 * The Device extensions provides access to information about the device in
 * which the application is executing.
 */
export interface DeviceExtension extends Extension {
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

declare global {
  interface Extensions {
    device?: DeviceExtension;
  }
}