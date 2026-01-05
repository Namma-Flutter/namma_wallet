fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios test

```sh
[bundle exec] fastlane ios test
```

Run all tests

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Push a new iOS beta build to TestFlight

### ios production

```sh
[bundle exec] fastlane ios production
```

Promote an existing build to App Store (Metadata + Submission only)

Usage: fastlane production [version:X.X.X] [build:XXX]

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
