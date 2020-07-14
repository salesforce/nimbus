# Nimbus

[![Android](https://api.bintray.com/packages/salesforce-mobile/android/nimbus/images/download.svg) ](https://bintray.com/salesforce-mobile/android/nimbus/_latestVersion)

<!-- [![Snapshot](https://img.shields.io/badge/snapshot-2.0.0--SNAPSHOT-green)](https://https://oss.jfrog.org/artifactory/libs-snapshot/com/salesforce/nimbus/) -->

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

## Contributing

### Code of Conduct

Salesforce expects all participants in its open source projects to adhere to
our [code of coduct](CODE_OF_CONDUCT.md).

## License

Nimbus is distributed under the [BSD 3-Clause](LICENSE) license.
