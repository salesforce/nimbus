import nimbus from 'nimbus-bridge';

const template = document.createElement('template');
template.innerHTML = `
<slot></slot>
`;

class NimbusDemoApp extends HTMLElement {
    public constructor() {
        super();
        let shadowRoot = this.attachShadow({ mode: 'open' });
        shadowRoot.appendChild(template.content.cloneNode(true));
    }

    public connectedCallback(): void {
        console.log(`component connected ${nimbus}`);
    }
}

customElements.define('nimbus-demo-app', NimbusDemoApp);

export default NimbusDemoApp;
