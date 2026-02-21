# fastlane documentation

# Installation

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

After setting up the environment, perform the following steps:

*   Place your `key.properties` file in the root of the `android` folder.
*   Place your keystore file in the `android/app` folder.
*   Place your Google Play service JSON file in the `android/fastlane` folder.
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

