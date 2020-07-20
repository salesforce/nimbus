package com.salesforce.nimbus

import kotlin.reflect.KClass

@Retention(AnnotationRetention.RUNTIME)
@Target(AnnotationTarget.FUNCTION)
annotation class BoundMethod(vararg val throwsExceptions: KClass<out Throwable> = [])
