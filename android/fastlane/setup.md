# fastlane documentation

# Installation

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

After setting up the environment, perform the following steps:

*   Ensure your `key.properties` file is in the root of the `android` folder.
*   Ensure your keystore file is in the `android/app` folder.
*   Ensure your Google Play service JSON file is in the `android/fastlane` folder.
*   Set environment variables with the path of the JSON file and the package name. Name the environment variable file `.env.local` and place it in the `android/fastlane` folder. Refer to the `.env.local.example` file in the same folder for guidance.

# Available Actions

## Android
### android beta

To build the app bundle and upload it to Play Store internal testing, run the following command:

```sh
[bundle exec] fastlane android beta
```
### android production

To promote the beta build to production, run the following command:

```sh
[bundle exec] fastlane android production
```

