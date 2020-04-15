package com.salesforce.nimbus.k2v8

import com.eclipsesource.v8.V8

/**
 * Configuration class to configure a [K2V8] instance. The [runtime] is the [V8] instance that
 * will be used to serialize/deserialize objects to/from.
 */
class Configuration(val runtime: V8)
