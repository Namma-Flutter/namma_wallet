
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
