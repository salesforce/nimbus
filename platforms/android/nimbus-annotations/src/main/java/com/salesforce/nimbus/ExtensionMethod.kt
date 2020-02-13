package com.salesforce.nimbus

enum class BindingType {
    Native,
    PromisedJavascript
}

@Retention(AnnotationRetention.SOURCE)
@Target(AnnotationTarget.FUNCTION)
annotation class ExtensionMethod(val bindingType: BindingType = BindingType.Native)
