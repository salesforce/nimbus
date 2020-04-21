//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import Foundation

public protocol Binder {

    /**
     Bind the specified function to this connection.
     */
    func bind(
        _ function: @escaping () throws -> Void,
        as name: String
    )

    /**
     Bind the specified function to this connection.
     */
    func bind<R: Encodable>(
        _ function: @escaping () throws -> R,
        as name: String
    )

    /**
     Bind the specified function to this connection.
     */
    func bind<A0>(
        _ function: @escaping (A0) throws -> Void,
        as name: String
    ) where A0: Decodable

    /**
     Bind the specified function to this connection.
     */
    func bind<R: Encodable, A0>(
        _ function: @escaping (A0) throws -> R,
        as name: String
    ) where A0: Decodable

    /**
     Bind the specified function to this connection.
     */
    func bind<CB0: Encodable>(
        _ function: @escaping (@escaping (CB0) -> Void) throws -> Void,
        as name: String
    )

    /**
     Bind the specified function to this connection.
     */
    func bind<CB0: Encodable, CB1: Encodable>(
        _ function: @escaping (@escaping (CB0, CB1) -> Void) throws -> Void,
        as name: String
    )

    /**
     Bind the specified function to this connection.
     */
    func bind<A0, A1>(
        _ function: @escaping (A0, A1) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable

    /**
     Bind the specified function to this connection.
     */
    func bind<R: Encodable, A0, A1>(
        _ function: @escaping (A0, A1) throws -> R,
        as name: String
    ) where A0: Decodable, A1: Decodable

    /**
     Bind the specified function to this connection.
     */
    func bind<A0, CB0: Encodable>(
        _ function: @escaping (A0, @escaping (CB0) -> Void) throws -> Void,
        as name: String
    ) where A0: Decodable

    /**
     Bind the specified function to this connection.
     */
    func bind<A0, CB0: Encodable, CB1: Encodable>(
        _ function: @escaping (A0, @escaping (CB0, CB1) -> Void) throws -> Void,
        as name: String
    ) where A0: Decodable

    /**
     Bind the specified function to this connection.
     */
    func bind<A0, A1, A2>(
        _ function: @escaping (A0, A1, A2) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable

    /**
     Bind the specified function to this connection.
     */
    func bind<R: Encodable, A0, A1, A2>(
        _ function: @escaping (A0, A1, A2) throws -> R,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable

    /**
     Bind the specified function to this connection.
     */
    func bind<A0, A1, CB0>(
        _ function: @escaping (A0, A1, @escaping (CB0) -> Void) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable, CB0: Encodable

    /**
     Bind the specified function to this connection.
     */
    func bind<A0, A1, CB0, CB1>(
        _ function: @escaping (A0, A1, @escaping (CB0, CB1) -> Void) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable, CB0: Encodable, CB1: Encodable

    /**
     Bind the specified function to this connection.
     */
    func bind<A0, A1, A2, A3>(
        _ function: @escaping (A0, A1, A2, A3) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable

    /**
     Bind the specified function to this connection.
     */
    func bind<R: Encodable, A0, A1, A2, A3>(
        _ function: @escaping (A0, A1, A2, A3) throws -> R,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable

    /**
     Bind the specified function to this connection.
     */
    func bind<A0, A1, A2, CB0: Encodable>(
        _ function: @escaping (A0, A1, A2, @escaping (CB0) -> Void) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable

    /**
     Bind the specified function to this connection.
     */
    func bind<A0, A1, A2, CB0: Encodable, CB1: Encodable>(
        _ function: @escaping (A0, A1, A2, @escaping (CB0, CB1) -> Void) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable

    /**
     Bind the specified function to this connection.
     */
    func bind<A0, A1, A2, A3, A4>(
        _ function: @escaping (A0, A1, A2, A3, A4) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable, A4: Decodable

    /**
     Bind the specified function to this connection.
     */
    func bind<R: Encodable, A0, A1, A2, A3, A4>(
        _ function: @escaping (A0, A1, A2, A3, A4) throws -> R,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable, A4: Decodable

    /**
     Bind the specified function to this connection.
     */
    func bind<A0, A1, A2, A3, CB0: Encodable>(
        _ function: @escaping (A0, A1, A2, A3, @escaping (CB0) -> Void) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable

    /**
     Bind the specified function to this connection.
     */
    func bind<A0, A1, A2, A3, CB0: Encodable, CB1: Encodable>(
        _ function: @escaping (A0, A1, A2, A3, @escaping (CB0, CB1) -> Void) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable

}
