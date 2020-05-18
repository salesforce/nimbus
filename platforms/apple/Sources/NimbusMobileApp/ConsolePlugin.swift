//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import Nimbus

class ConsolePlugin: Plugin {
    func log(_ line: String) {
        NSLog("[ConsolePlugin]: " + line)
    }

    func bind<C>(to connection: C) where C: Connection {
        connection.bind(log, as: "log")
    }
}
