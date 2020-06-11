import { DeviceInfoPlugin, DeviceInfo } from "nimbus-types";

const template = document.createElement("template");
template.innerHTML = `
<slot></slot>
`;

declare interface NimbusWithDeviceInfoPlugin {
  DeviceInfoPlugin: DeviceInfoPlugin;
}

class NimbusDeviceInfo extends HTMLElement {
  public constructor() {
    super();
    let shadowRoot = this.attachShadow({ mode: "open" });
    shadowRoot.appendChild(template.content.cloneNode(true));
  }

  public connectedCallback(): void {
    let plugins = (<any>window.__nimbus!.plugins) as NimbusWithDeviceInfoPlugin;
    plugins.DeviceInfoPlugin.getDeviceInfo().then((info: DeviceInfo): void => {
      console.log(JSON.stringify(info));
      let shadowRoot = this.shadowRoot;
      if (shadowRoot === null) return;
      let slot = shadowRoot.querySelector("slot");
      if (slot !== null) {
        slot.innerHTML = `
          <p>Manufacturer: ${info.manufacturer}</p>
          <p>Model: ${info.model}</p>
          <p>Platform: ${info.platform}</p>
          <p>Version: ${info.platformVersion}</p>
          <p>App Version: ${info.appVersion}</p>
        `;
      }
    });
  }
}

customElements.define("nimbus-device-info", NimbusDeviceInfo);

export default NimbusDeviceInfo;
