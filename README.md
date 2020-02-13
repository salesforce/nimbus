# Nimbus

[![codecov](https://codecov.io/gh/salesforce/nimbus/branch/codecoverage/graph/badge.svg)](https://codecov.io/gh/salesforce/nimbus)

> :warning: This is pre-production software and not recommended for production use.

Nimbus is a bridge for hybrid app development.

## Building and Running

Nimbus uses a hybrid web app located in `/packages/demo-www`. Ensure it is
running prior to launching one of the platform apps.

```sh
npm install
npm run serve:demo
```

Then launch one of the platforms apps located under `platforms/`.

### Generated Code

If you change the templates for any of the generated code, ensure that
you run the 'Generate Code from Templates' aggregate target in the
Xcode project to regenerate the destination source files.

## Usage Patterns

See [DeviceExtension.swift](./platforms/apple/Sources/Nimbus/Extensions/DeviceExtension.swift)
or [DeviceExtension.kt](./platforms/android/nimbus/src/main/java/com/salesforce/nimbus/extensions/DeviceExtension.kt)
for examples of creating methods callable from Web to Native (see `getDeviceInfo()`) and
Native to Web (see `getWebInfo()`)

## Contributing

### Code of Conduct

Salesforce expects all participants in its open source projects to adhere to
our [code of coduct](CODE_OF_CONDUCT.md).

## License

Nimbus is distributed under the [BSD 3-Clause](LICENSE) license.
