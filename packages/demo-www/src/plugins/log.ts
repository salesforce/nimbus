export interface LogPlugin {
  debug(tag: string, message: string): Promise<void>;
}

declare module "@nimbus-js/api" {
  export interface NimbusPlugins {
    LogPlugin: LogPlugin;
  }
}
