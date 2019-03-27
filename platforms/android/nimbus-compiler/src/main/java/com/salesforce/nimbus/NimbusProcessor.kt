package com.salesforce.nimbus;

import javax.annotation.processing.AbstractProcessor
import javax.annotation.processing.ProcessingEnvironment
import javax.annotation.processing.RoundEnvironment
import javax.lang.model.SourceVersion
import javax.lang.model.element.TypeElement
import javax.tools.Diagnostic

class NimbusProcessor: AbstractProcessor() {

    var processingEnvironment: ProcessingEnvironment? = null

    override fun init(processingEnvironment: ProcessingEnvironment?) {
        super.init(processingEnvironment)
        this.processingEnvironment = processingEnvironment
    }

    override fun process(annotations: MutableSet<out TypeElement>?, roundEnvironment: RoundEnvironment?): Boolean {

        this.processingEnvironment!!.messager.printMessage(Diagnostic.Kind.WARNING, "whoops")

        return false
    }

    override fun getSupportedAnnotationTypes(): MutableSet<String> {
        return mutableSetOf(
                ExtensionMethod::class.java.canonicalName,
                Extension::class.java.canonicalName)
    }

    override fun getSupportedSourceVersion(): SourceVersion {
        return SourceVersion.latestSupported()
    }
}
