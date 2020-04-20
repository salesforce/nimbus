//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

public protocol Connection: class, Binder {
    func invoke<R>(
        _ identifierPath: String,
        with args: Encodable...,
        callback: @escaping (Error?, R?) -> Void
    )
}
