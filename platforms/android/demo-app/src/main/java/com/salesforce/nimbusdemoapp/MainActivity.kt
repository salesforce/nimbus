//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbusdemoapp

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.salesforce.nimbus.NimbusBridge

class MainActivity : AppCompatActivity() {

    val bridge: NimbusBridge = NimbusBridge(this, "http://10.0.2.2:3000")

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val fm = supportFragmentManager
        if (fm.findFragmentByTag(bridge.fragment.tag) == null) {
            val ft = fm.beginTransaction()
            ft.add(R.id.container, bridge.fragment)
            ft.commit()
        }

        bridge.addExtension(SimpleBridgeExtension())
        bridge.initialize()
    }
}
