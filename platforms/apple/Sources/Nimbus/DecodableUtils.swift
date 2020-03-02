//
//  DecodableUtils.swift
//  Nimbus
//
//  Created by Paul Tiarks on 3/2/20.
//  Copyright © 2020 Salesforce.com, inc. All rights reserved.
//

import Foundation

private extension Decodable {
    static func openedJSONDecode(using decoder: JSONDecoder, from data: Data) throws -> Self {
        return try decoder.decode(self, from: data)
    }
}

func decodeJSON<A>(_ data: Data, destinationType: A.Type) -> A? {
    guard let codableType = A.self as? Decodable.Type  else {
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
