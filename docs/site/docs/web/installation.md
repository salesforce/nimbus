---
layout: docs
---

# Integrating Nimbus into a Web App

The Nimbus web runtime provides both the integration hooks for using Nimbus
in a hybrid app container as well as support for web-platform plugins.

There are two ways to integrate Nimbus into your web app:

-   Including the Nimbus runtime in your web app bundle (preferred)
-   Injecting the Nimbus runtime when your web app is loaded in the hybrid container

## Including Nimbus in the Web App bundle

The preferred method is to include Nimbus in your web app bundle. This way
you have a single version of your web app that will run in any supported
Nimbus app container or the browser.

Start by adding Nimbus as a dependency:

```bash
npm install --save @salesforce/nimbus
```

Once Nimbus has been added to the project it can be imported as a module:

```typescript
import { Nimbus } from "@salesforce/nimbus";
```

## Injecting Nimbus from a hybrid app container

In some cases it may be impractical to bundle Nimbus with the web app. A secondary way of loading Nimbus is to inject its runtime javascript bundle from the hybrid app container. This means that the Nimbus web runtime is bundled as a resource in the hybrid app and loaded into the web view during app bootstrap.

Refer to the platform-specific documentation to learn how to inject the Nimbus runtime from the hybrid app container.
