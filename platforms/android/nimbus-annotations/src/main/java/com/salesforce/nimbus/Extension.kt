package com.salesforce.nimbus

@Retention(AnnotationRetention.RUNTIME)
@Target(AnnotationTarget.CLASS)
annotation class Extension(val name: String)
