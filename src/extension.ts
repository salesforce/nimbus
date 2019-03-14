
/**
 * Interface to be implemented by all extensions.
 */
export interface Extension {}

/**
 * This interface acts as a registry for extensions.
 *
 * Each extension file should include a declaration of this interface that adds
 * an optional property for that extension. This allows consumers to destructure
 * the `extensions` property of the `Nimbus` object to access registered
 * extensions.
 */
export interface Extensions {}
