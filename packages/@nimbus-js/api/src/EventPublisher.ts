/**
 * # Event Publishers
 *
 * Nimbus plugins have the ability to declare themselves as event plublishers
 * using the `EventPublisher` interface. Event publishers have a set of
 * well-known events that they may publish throughout the lifetime of the app
 * and which can be received and acted upon by listeners.
 *
 * A plugin that wishes to publish events should first define the set of known
 * events and the shape of the data sent for those events. This is done by
 * declaring an interface where the property keys represent event names and the
 * property types are the type of event data that corresponds to the event
 * name.
 *
 * ```typescript
 * interface DemoEventOne {
 *   message: string;
 * }
 *
 * interface DemoEventTwo {
 *   results: string[];
 * }
 *
 * interface DemoEvents {
 *   eventOne: DemoEventOne;
 *   eventTwo: DemoEventTwo;
 * }
 * ```
 *
 * After the events and their payload shapes have been defined, the plugin
 * declares itself as a publisher of those events by extending the
 * `EventPlublisher` interface and passing its events as the type parameter.
 *
 * ```typescript
 * interface DemoPlugin extends EventPublisher<DemoEvents> {
 * }
 * ```
 *
 * Plugins that declare themselves as publishers then support having listeners
 * added to them.
 *
 * ```typescript
 * __nimbus.plugins.DemoPlugin.addListener("eventOne", (eventOne: DemoEventOne) => {
 *   console.log(JSON.stringify(eventOne));
 * });
 * ```
 *
 * @packageDocumentation
 */

/**
 * The `EventPublisher` interface is used to declare that a plugin will publish
 * events and allows consumers to listen for those events.
 *
 * @typeParam T a type that maps property keys to event types
 */
export interface EventPublisher<T> {
  /**
   * Add a listener to a specific named event
   *
   * @param eventName the name of the event to listen for, which should be a key from the typeParam of the `EventPublisher`
   * @param listener a listener callback that is invoked when the named event is published
   * @returns a promise that resolves to a string token which can be used to remove the listener
   */
  addListener<K extends keyof T>(
    eventName: K,
    listener: (event: T[K]) => void
  ): Promise<string>;

  /**
   * Remove a listener that was previously added.
   *
   * @param listenerToken a token received from the return value of an `addListener` call
   */
  removeListener(listenerToken: string): void;
}
