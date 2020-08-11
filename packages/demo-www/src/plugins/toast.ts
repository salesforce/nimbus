export interface ToastPlugin {
  toast(message: string): Promise<void>;
}

declare module "@nimbus-js/api" {
  export interface NimbusPlugins {
    ToastPlugin: ToastPlugin;
  }
}
