package com.salesforce.nimbus

enum class TrailingClosure {
    CLOSURE, PROMISE
}

@Retention(AnnotationRetention.SOURCE)
@Target(AnnotationTarget.FUNCTION)
annotation class ExtensionMethod(val trailingClosure: TrailingClosure = TrailingClosure.CLOSURE)
