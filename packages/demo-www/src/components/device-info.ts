import { DeviceInfo } from 'nimbus-bridge';

const template = document.createElement('template');
template.innerHTML = `
<slot id='first'></slot>
<slot id='second'></slot>
`;

class NimbusDeviceInfo extends HTMLElement {
    public constructor() {
        super();
        let shadowRoot = this.attachShadow({ mode: 'open' });
        shadowRoot.appendChild(template.content.cloneNode(true));
    }

    public connectedCallback(): void {
        if (window.DeviceExtension !== undefined) {
            window.DeviceExtension.getDeviceInfo().then(
                (info: DeviceInfo): void => {
                    console.log(JSON.stringify(info));
                    let shadowRoot = this.shadowRoot;
                    if (shadowRoot === null) return;
                    let slot = shadowRoot.querySelector('#first');
                    if (slot !== null) {
                        slot.innerHTML = `
          <p>Manufacturer: ${info.manufacturer}</p>
          <p>Model: ${info.model}</p>
          <p>Platform: ${info.platform}</p>
          <p>Version: ${info.platformVersion}</p>
          <p>App Version: ${info.appVersion}</p>
        `;
                    }
                }
            );
            window.DeviceExtension.getDeviceDesignLocation().then(
                (name: string): void => {
                    console.log(name);
                    let shadowRoot = this.shadowRoot;
                    if (shadowRoot === null) return;
                    let slot = shadowRoot.querySelector('#second');
                    if (slot !== null) {
                        slot.innerHTML = `
          <p>Designed at: ${name}</p>
        `;
                    }
                }
            );
        }
    }
}

customElements.define('nimbus-device-info', NimbusDeviceInfo);

export default NimbusDeviceInfo;
