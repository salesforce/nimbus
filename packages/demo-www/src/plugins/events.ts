interface LogEvent {
  message: string;
}

interface ToastEvent {
  message: string;
}

interface MessageEvents {
  logEvent: LogEvent;
  toastEvent: ToastEvent;
}
