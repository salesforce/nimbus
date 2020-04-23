//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

/**
 A `Connection` links native function to a javascript execution environment.
 */
public protocol Connection: class, Binder, JSEvaluating {}
