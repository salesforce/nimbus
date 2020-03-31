//
//  JSContext+Nimbus.swift
//  Nimbus
//
//  Created by Paul Tiarks on 3/31/20.
//  Copyright © 2020 Salesforce.com, inc. All rights reserved.
//

import JavaScriptCore

extension JSContext {
    public func addConnection<C>(to target: C, as namespace: String) -> JSContextConnection<C> {
        return JSContextConnection(from: self, to: target, as: namespace)
    }
}
