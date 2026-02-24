# Flutter command - use 'fvm flutter' if using FVM, otherwise 'flutter'
FLUTTER ?= fvm flutter
# Dart command - use 'fvm dart' if using FVM, otherwise 'dart'
DART ?= fvm dart

.PHONY: help clean get codegen release-android release-ios release-apk release-appbundle release-ipa ios-test ios-beta ios-production

help:
	@echo "Available targets:"
	@echo "  clean              - Clean the project"
	@echo "  get                - Get dependencies"
	@echo "  codegen            - Run code generation"
	@echo "  release-android    - Build Android release APK"
	@echo "  release-ios        - Build iOS release app"
	@echo "  release-apk        - Build Android release APK"
	@echo "  release-appbundle  - Build Android release App Bundle"
	@echo "  release-ipa        - Build iOS release IPA"
	@echo ""
	@echo "Fastlane iOS targets:"
	@echo "  ios-test           - Run tests via fastlane"
	@echo "  ios-beta           - Build and deploy to TestFlight"
	@echo "  ios-production     - Promote TestFlight build to App Store"

clean:
	$(FLUTTER) clean

get:
	$(FLUTTER) pub get

codegen:
	$(DART) run build_runner build --delete-conflicting-outputs

# Release builds (with WASM module removal for pdfrx)
release-apk: get codegen
	$(DART) run pdfrx:remove_wasm_modules
	$(FLUTTER) build apk --release

release-appbundle: get codegen
	$(DART) run pdfrx:remove_wasm_modules
	$(FLUTTER) build appbundle --release

release-ipa: get codegen
	$(DART) run pdfrx:remove_wasm_modules
	$(FLUTTER) build ipa --release

# Fastlane android targets
android-beta:
	cd android && bundle exec fastlane beta

android-production:
	cd android && bundle exec fastlane production

# Fastlane iOS targets
ios-beta:
	cd ios && bundle exec fastlane beta

ios-production:
	cd ios && bundle exec fastlane production
