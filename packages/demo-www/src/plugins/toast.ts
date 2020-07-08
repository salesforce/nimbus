export interface ToastPlugin {
  toast(message: string): Promise<void>;
}

declare module 'nimbus-types' {
  export interface NimbusPlugins {
    ToastPlugin: ToastPlugin;
  }
}
