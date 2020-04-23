//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

/**
 A type that conforms to `JSEvaluating` can call JavaScript functions
 */
public protocol JSEvaluating {
    /**
     Call the function described by the identifierPath with the given args and pass the result to the callback.
     */
    func evaluate<R: Decodable>(
        _ identifierPath: String,
        with args: [Encodable],
        callback: @escaping (Error?, R?) -> Void
    )
}
