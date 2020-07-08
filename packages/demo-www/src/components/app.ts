import nimbus from "nimbus-types";
import "../plugins/log";
import "../plugins/toast";
import "../plugins/events";

const template = document.createElement("template");
template.innerHTML = `
<slot></slot>
`;

class NimbusDemoApp extends HTMLElement {
  public constructor() {
    super();
    let shadowRoot = this.attachShadow({ mode: "open" });
    shadowRoot.appendChild(template.content.cloneNode(true));
  }

  public connectedCallback(): void {
    console.log(`component connected ${nimbus}`);

    if (__nimbus.plugins.EventPlugin !== undefined) {

     // listen for log events and then log the message using the log plugin
     __nimbus.plugins.EventPlugin.addListener("logEvent", (event: LogEvent) => {
       __nimbus.plugins.LogPlugin.debug("LogPlugin", JSON.stringify(event));
     });

     // listen for toast events and then toast the message using the toast
     // plugin
     __nimbus.plugins.EventPlugin.addListener("toastEvent", (event: ToastEvent) => {
       __nimbus.plugins.ToastPlugin.toast(event.message);
     });
   }
  }
}

customElements.define("nimbus-demo-app", NimbusDemoApp);

export default NimbusDemoApp;
