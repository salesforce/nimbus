export interface LogPlugin {
  debug(tag: string, message: string): Promise<void>;
}

declare module 'nimbus-types' {
  export interface NimbusPlugins {
    LogPlugin: LogPlugin;
  }
}
