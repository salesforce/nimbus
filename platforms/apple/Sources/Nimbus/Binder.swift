//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

public protocol Binder {
    associatedtype Target
    var target: Target { get }

    func bind(_ callable: Callable, as name: String)
}
