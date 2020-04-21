//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import Foundation
import JavaScriptCore

private extension Decodable {
    static func openedJSONDecode(using decoder: JSONDecoder, from data: Data) throws -> Self {
        return try decoder.decode(self, from: data)
    }

    static func openedJSValueDecode(using decoder: JSValueDecoder, from value: JSValue) throws -> Self {
        return try decoder.decode(self, from: value)
    }
}

func decodeJSON<A>(_ data: Data, destinationType: A.Type) -> A? {
    guard let codableType = A.self as? Decodable.Type else {
        return nil
    }
    var returnValue: A?
    do {
        let decoded = try codableType.openedJSONDecode(using: JSONDecoder(), from: data) as! A // swiftlint:disable:this force_cast
        returnValue = decoded
        return returnValue
    } catch {
        return nil
    }
}

func decodeJSValue<A>(_ value: JSValue, destinationType: A.Type) -> A? {
    guard let codableType = A.self as? Decodable.Type else {
        return nil
    }
    var returnValue: A?
    do {
        let decoded = try codableType.openedJSValueDecode(using: JSValueDecoder(), from: value) as! A // swiftlint:disable:this force_cast
        returnValue = decoded
        return returnValue
    } catch {
        return nil
    }
}
