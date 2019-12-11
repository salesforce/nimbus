package com.salesforce.nimbus

@Retention(AnnotationRetention.SOURCE)
@Target(AnnotationTarget.FUNCTION)
annotation class ExtensionMethod(val promisifyClosure: Boolean = false)
