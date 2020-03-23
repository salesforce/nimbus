package com.salesforce.nimbus

@Retention(AnnotationRetention.RUNTIME)
@Target(AnnotationTarget.CLASS)
annotation class PluginOptions(val name: String)
