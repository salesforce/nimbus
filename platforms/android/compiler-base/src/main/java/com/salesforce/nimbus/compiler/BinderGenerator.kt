package com.salesforce.nimbus.compiler

import com.salesforce.nimbus.BoundMethod
import com.salesforce.nimbus.PluginOptions
import com.squareup.kotlinpoet.ClassName
import com.squareup.kotlinpoet.FileSpec
import com.squareup.kotlinpoet.FunSpec
import com.squareup.kotlinpoet.KModifier
import com.squareup.kotlinpoet.ParameterizedTypeName.Companion.parameterizedBy
import com.squareup.kotlinpoet.PropertySpec
import com.squareup.kotlinpoet.TypeSpec
import com.squareup.kotlinpoet.asClassName
import kotlinx.metadata.KmFunction
import kotlinx.metadata.jvm.KotlinClassHeader
import kotlinx.metadata.jvm.KotlinClassMetadata
import kotlinx.serialization.Serializable
import javax.annotation.processing.AbstractProcessor
import javax.annotation.processing.Messager
import javax.annotation.processing.ProcessingEnvironment
import javax.annotation.processing.RoundEnvironment
import javax.lang.model.SourceVersion
import javax.lang.model.element.Element
import javax.lang.model.element.ElementKind
import javax.lang.model.element.ExecutableElement
import javax.lang.model.element.TypeElement
import javax.lang.model.type.TypeMirror
import javax.lang.model.util.Types
import javax.tools.Diagnostic

const val nimbusPackage = "com.salesforce.nimbus"

/**
 * Base class to generate plugin Binder classes from classes which are annotated with [PluginOptions]
 */
abstract class BinderGenerator : AbstractProcessor() {

    private lateinit var messager: Messager
    private lateinit var types: Types
    private var serializableElements: Set<Element> = emptySet()

    /**
     * The [ClassName] of the javascript engine that the Binder class will target
     */
    abstract val javascriptEngine: ClassName

    /**
     * The [ClassName] of the serialized output type the javascript engine expects
     */
    abstract val serializedOutputType: ClassName

    override fun init(processingEnvironment: ProcessingEnvironment) {
        super.init(processingEnvironment)
        messager = processingEnvironment.messager
        types = processingEnvironment.typeUtils
    }

    override fun process(
        annotations: MutableSet<out TypeElement>?,
        env: RoundEnvironment
    ): Boolean {
        try {

            // get all plugins
            val pluginElements = env.getElementsAnnotatedWith(PluginOptions::class.java)

            // get all serializable elements
            serializableElements = env.getElementsAnnotatedWith(Serializable::class.java)

            // find any duplicate plugin names
            val duplicates =
                pluginElements.groupingBy { it.getAnnotation(PluginOptions::class.java).name }
                    .eachCount().filterValues { it > 1 }.keys

            // if we have any duplicate plugin names then give an error
            if (duplicates.isNotEmpty()) {
                val name = duplicates.first()
                error(
                    pluginElements.first { it.getAnnotation(PluginOptions::class.java).name == name },
                    "A ${PluginOptions::class.java.simpleName} with name $name already exists."
                )
            } else {

                // loop through each plugin to create a binder class for it
                pluginElements.forEach { pluginElement ->

                    // make sure it implements `Plugin`
                    if (types.directSupertypes(pluginElement.asType()).map { it.toString() }.none { it == "$nimbusPackage.Plugin" }) {
                        error(
                            pluginElement,
                            "${PluginOptions::class.java.simpleName} class must extend $nimbusPackage.Plugin."
                        )
                    } else {

                        // process each plugin element to create a type spec
                        val typeSpec = processPluginElement(pluginElement, serializableElements)

                        // create the binder class for the plugin
                        FileSpec.builder(
                            processingEnv.elementUtils.getPackageOf(pluginElement).qualifiedName.toString(),
                            typeSpec.name!!
                        )
                            .addType(typeSpec)
                            .indent("    ")
                            .build()
                            .writeTo(processingEnv.filer)
                    }
                }
            }
        } catch (e: Exception) {
            messager.printMessage(Diagnostic.Kind.ERROR, e.message)
        }

        return true
    }

    override fun getSupportedAnnotationTypes(): MutableSet<String> {
        return mutableSetOf(
            BoundMethod::class.java.canonicalName,
            PluginOptions::class.java.canonicalName,
            Serializable::class.java.canonicalName
        )
    }

    override fun getSupportedSourceVersion(): SourceVersion {
        return SourceVersion.latestSupported()
    }

    private fun processPluginElement(pluginElement: Element, serializableElements: Set<Element>): TypeSpec {

        // the binder class name will be <PluginClass><JavascriptEngine>Binder, such as DeviceInfoPluginWebViewBinder
        val binderTypeName = "${pluginElement.getName()}${javascriptEngine.simpleName}Binder"
        val pluginName = pluginElement.getAnnotation(PluginOptions::class.java).name
        val pluginTypeName = pluginElement.asKotlinTypeName()

        // read kotlin metadata so we can determine which types are nullable
        val kotlinClass =
            pluginElement.getAnnotation(Metadata::class.java)?.let { metadata ->
                (KotlinClassMetadata.read(
                    KotlinClassHeader(
                        metadata.kind,
                        metadata.metadataVersion,
                        metadata.bytecodeVersion,
                        metadata.data1,
                        metadata.data2,
                        metadata.extraString,
                        metadata.packageName,
                        metadata.extraInt
                    )
                ) as KotlinClassMetadata.Class).toKmClass()
            }

        val stringClassName = String::class.asClassName()
        val runtimeClassName =
            ClassName(nimbusPackage, "Runtime").parameterizedBy(javascriptEngine, serializedOutputType)

        // get all methods annotated with BoundMethod
        val boundMethodElements = pluginElement.enclosedElements
            .filter {
                it.kind == ElementKind.METHOD && it.getAnnotation(BoundMethod::class.java) != null
            }
            .map { it as ExecutableElement }

        // the binder needs to capture the bound target to pass through calls to it
        val type = TypeSpec.classBuilder(binderTypeName)

            // the Binder implements Binder<JavascriptEngine>
            .addSuperinterface(
                ClassName(nimbusPackage, "Binder").parameterizedBy(javascriptEngine, serializedOutputType)
            )
            .addModifiers(KModifier.PUBLIC)

            // add the <PluginClass> as a constructor property
            .primaryConstructor(
                FunSpec.constructorBuilder()
                    .addParameter("target", pluginTypeName)
                    .build()
            )

            // create the <PluginClass> property initializer
            .addProperty(
                PropertySpec.builder(
                    "target",
                    pluginTypeName,
                    KModifier.FINAL,
                    KModifier.PRIVATE
                )
                    .initializer("target")
                    .build()
            )

            // add the Runtime property
            .addProperty(
                PropertySpec.builder(
                    "runtime",
                    runtimeClassName.copy(nullable = true),
                    KModifier.PRIVATE
                )
                    .mutable()
                    .initializer("null")
                    .build()
            )

            // add the property to hold the plugin name
            .addProperty(
                PropertySpec.builder(
                    "pluginName",
                    stringClassName,
                    KModifier.FINAL,
                    KModifier.PRIVATE
                )
                    .initializer("\"$pluginName\"")
                    .build()
            )

            // allow subclasses to process properties
            .also(::processClassProperties)

            // add a getter for the plugin (implement Binder.getPlugin())
            .addFunction(
                FunSpec.builder("getPlugin")
                    .addModifiers(KModifier.OVERRIDE)
                    .returns(ClassName(nimbusPackage, "Plugin"))
                    .addStatement("return target")
                    .build()
            )

            // add a getter for the plugin name (implement Binder.getPluginName())
            .addFunction(
                FunSpec.builder("getPluginName")
                    .addModifiers(KModifier.OVERRIDE)
                    .returns(stringClassName)
                    .addStatement("return pluginName")
                    .build()
            )

            // add the bind function to bind the Runtime
            // (implement Binder.bind(Runtime<JavascriptEngine>))
            .addFunction(
                FunSpec.builder("bind")
                    .addModifiers(KModifier.OVERRIDE)
                    .addParameter("runtime", runtimeClassName)
                    .addStatement("this.%N = %N", "runtime", "runtime")

                    // allow subclasses to process bind function
                    .also { processBindFunction(boundMethodElements, it) }
                    .build()
            )

            // add the unbind function to unbind the runtime
            // (implement Binder.unbind(Runtime<JavascriptEngine>))
            .addFunction(
                FunSpec.builder("unbind")
                    .addModifiers(KModifier.OVERRIDE)
                    .addParameter("runtime", runtimeClassName)
                    .addStatement("this.%N = null", "runtime")
                    .build()
            )

        // loop through each bound function to generate a binder function
        boundMethodElements

            // process the function to create a FunSpec
            .map { functionElement ->
                processFunctionElement(
                    functionElement,
                    serializableElements,
                    kotlinClass?.functions?.find { it.name == functionElement.getName() }
                )
            }

            // add each FunSpec to the TypeSpec
            .forEach { funSpec -> type.addFunction(funSpec) }

        return type.build()
    }

    protected open fun processClassProperties(builder: TypeSpec.Builder) {
        /* leave for subclasses to override */
    }

    protected open fun processBindFunction(boundMethodElements: List<ExecutableElement>, builder: FunSpec.Builder) {
        /* leave for subclasses to override */
    }

    abstract fun processFunctionElement(
        functionElement: ExecutableElement,
        serializableElements: Set<Element>,
        kotlinFunction: KmFunction?
    ): FunSpec

    protected fun error(element: Element, message: String) {
        messager.printMessage(
            Diagnostic.Kind.ERROR,
            message,
            element
        )
    }

    protected fun TypeMirror.isStringType(): Boolean {
        return toString() in listOf("java.lang.String", "kotlin.String")
    }

    protected fun TypeMirror.isListType(): Boolean {
        return toString().startsWith("java.util.List") ||
            processingEnv.typeUtils.directSupertypes(this).map { it.toString() }
            .any { it.startsWith("java.util.List") }
    }

    protected fun TypeMirror.isMapType(): Boolean {
        return toString().startsWith("java.util.Map") ||
            processingEnv.typeUtils.directSupertypes(this).map { it.toString() }
                .any { it.startsWith("java.util.Map") }
    }

    protected fun TypeMirror.isJSONEncodableType(): Boolean {
        return toString().startsWith("$nimbusPackage.JSONEncodable") ||
            processingEnv.typeUtils.directSupertypes(this).map { it.toString() }
                .any { it.startsWith("$nimbusPackage.JSONEncodable") }
    }

    protected fun TypeMirror.isKotlinSerializableType(): Boolean {
        return serializableElements.map { it.asRawTypeName() }.any { it == asRawTypeName() }
    }

    protected fun TypeMirror.isFunctionType(): Boolean {
        return toString().startsWith("kotlin.jvm.functions.Function")
    }

    protected fun TypeMirror.isUnitType(): Boolean {
        return (asKotlinTypeName() as ClassName).simpleName == "Unit"
    }
}
