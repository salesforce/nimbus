//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or
// https://opensource.org/licenses/BSD-3-Clause
//

interface NimbusNative {
  makeCallback(callbackId: string): any;
  nativePluginNames(): string;
  pageUnloaded(): void;
}
declare var _nimbus: NimbusNative;
declare var __nimbusPluginExports: { [s: string]: string[] };

interface Window {
  _nimbus: NimbusNative;
  [s: string]: any;
}
