# #!/bin/bash

# # Usage:
# # chmod +x release.sh
# # ./release.sh

# set -e

# # ---------- Helpers ----------
# print_error() {
#   echo "❌ $1"
#   exit 1
# }

# print_info() {
#   echo "👉 $1"
# }

# # ---------- Check git branch ----------
# CURRENT_BRANCH=$(git branch --show-current)

# if [ "$CURRENT_BRANCH" != "feature/fastlane-android" ]; then
#   print_error "You are on '$CURRENT_BRANCH'. Please switch to 'feature/fastlane-android' branch."
# fi

# print_info "On feature/fastlane-android branch ✔"

# # ---------- Flutter clean ----------
# print_info "Running flutter clean..."
# fvm flutter clean

# print_info "Running flutter pub get..."
# fvm flutter pub get


# # ---------- Read current version ----------
# CURRENT_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
# VERSION_NAME=$(echo "$CURRENT_VERSION" | cut -d+ -f1)
# BUILD_NUMBER=$(echo "$CURRENT_VERSION" | cut -d+ -f2)

# IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION_NAME"

# echo ""
# echo "Current version : $VERSION_NAME+$BUILD_NUMBER"
# echo ""

# # ---------- Ask version bump ----------
# echo "Select version bump type:"
# echo "1) Major"
# echo "2) Minor"
# echo "3) Patch"
# echo "4) Build number only"
# read -p "Enter choice (1/2/3/4): " VERSION_CHOICE

# case $VERSION_CHOICE in
#   1)
#     MAJOR=$((MAJOR + 1))
#     MINOR=0
#     PATCH=0
#     NEW_BUILD=$((BUILD_NUMBER + 1))
#     ;;
#   2)
#     MINOR=$((MINOR + 1))
#     PATCH=0
#     NEW_BUILD=$((BUILD_NUMBER + 1))
#     ;;
#   3)
#     PATCH=$((PATCH + 1))
#     NEW_BUILD=$((BUILD_NUMBER + 1))
#     ;;
#   4)
#     # Only increment build number
#     NEW_BUILD=$((BUILD_NUMBER + 1))
#     ;;
#   *)
#     print_error "Invalid version choice"
#     ;;
# esac

# NEW_VERSION="$MAJOR.$MINOR.$PATCH+$NEW_BUILD"

# print_info "Updating version to $NEW_VERSION"


# # ---------- Update pubspec.yaml ----------
# sed -i '' "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml

# # ---------- Ask release type ----------
# echo ""
# echo "Select release type:"
# echo "1) Internal Testing"
# echo "2) Closed Testing"
# echo "3) Production"
# read -p "Enter choice (1/2/3): " RELEASE_CHOICE


# case $RELEASE_CHOICE in
#   1)
#     print_info "Releasing to Internal Testing..."
#      cd android
#     fastlane android internal
#     ;;
#   2)
#     print_info "Releasing to Closed Testing..."
#      cd android
#     fastlane android beta
#     ;;
#   3)
#     print_info "Releasing to Production..."
#      cd android
#     fastlane android production
#     ;;
#   *)
#     print_error "Invalid release choice"
#     ;;
# esac

#  cd ..



# # ---------- Git commit ----------
# git add pubspec.yaml
# git commit -m "chore(android): bump version to $MAJOR.$MINOR.$PATCH ($NEW_BUILD)"

# # ---------- Git tag (Android standard) ----------
# TAG_NAME="android-v$MAJOR.$MINOR.$PATCH"

# # Check if tag already exists
# if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
#   print_error "Git tag '$TAG_NAME' already exists. Please bump version."
# fi

# print_info "Creating git tag $TAG_NAME"
# git tag -a "$TAG_NAME" -m "Android release $TAG_NAME"

# # ---------- Push commit & tag ----------
# print_info "Pushing commit and tag to remote"
# git push origin "$CURRENT_BRANCH"
# git push origin "$TAG_NAME"

# print_info "🎉 Release completed successfully!"
# print_info "Version : $NEW_VERSION"
# print_info "Tag     : $TAG_NAME"






#!/bin/bash
set -e

BUMP_TYPE=$1
RELEASE_TYPE=$2

if [ -z "$BUMP_TYPE" ] || [ -z "$RELEASE_TYPE" ]; then
  echo "Usage: ./release.sh <major|minor|patch|build> <internal|beta|production>"
  exit 1
fi

print_error() {
  echo "❌ $1"
  exit 1
}

print_info() {
  echo "👉 $1"
}

# ---------- Check git branch ----------
CURRENT_BRANCH=$(git branch --show-current)

if [ "$CURRENT_BRANCH" != "feature/fastlane-android" ]; then
  print_error "You are on '$CURRENT_BRANCH'. Please switch to 'feature/fastlane-android' branch."
fi

# ---------- Flutter ----------
fvm flutter clean
fvm flutter pub get

# ---------- Read version ----------
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
VERSION_NAME=$(echo "$CURRENT_VERSION" | cut -d+ -f1)
BUILD_NUMBER=$(echo "$CURRENT_VERSION" | cut -d+ -f2)

IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION_NAME"

# ---------- Version bump ----------
case $BUMP_TYPE in
  major)
    MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor)
    MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch)
    PATCH=$((PATCH + 1)) ;;
  build)
    ;;
  *)
    print_error "Invalid bump type"
    ;;
esac

NEW_BUILD=$((BUILD_NUMBER + 1))
NEW_VERSION="$MAJOR.$MINOR.$PATCH+$NEW_BUILD"

sed -i '' "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml

# ---------- Fastlane ----------
run_fastlane() {
  pushd android > /dev/null
  fastlane android "$1"
  popd > /dev/null
}

case $RELEASE_TYPE in
  internal) run_fastlane internal ;;
  beta) run_fastlane beta ;;
  production) run_fastlane production ;;
  *) print_error "Invalid release type" ;;
esac

# ---------- Git ----------
git add pubspec.yaml
git commit -m "chore(android): bump version to $NEW_VERSION"

TAG_NAME="android-v$MAJOR.$MINOR.$PATCH"

git tag -a "$TAG_NAME" -m "Android release $TAG_NAME"
git push --follow-tags origin "$CURRENT_BRANCH"

print_info "Release done: $NEW_VERSION"
