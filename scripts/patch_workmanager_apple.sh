#!/usr/bin/env bash
set -e

# Workaround for workmanager_apple (0.9.10 - 0.9.11) compiler bug on Xcode 16 / iOS SDK
# BGContinuedProcessingTask is only available on iOS 26+ and does not exist in iOS 17/18 SDKs.
echo "Running patch_workmanager_apple.sh..."

if [ -f "pubspec.lock" ]; then
  WM_VERSION=$(grep -A 5 "workmanager_apple:" pubspec.lock | grep "version:" | awk -F '"' '{print $2}' || true)
  if [ -n "$WM_VERSION" ] && [ "$WM_VERSION" != "0.9.10" ] && [ "$WM_VERSION" != "0.9.11" ]; then
    echo "workmanager_apple version is $WM_VERSION. Patch is only for 0.9.10 and 0.9.11. Skipping."
  else
    DIRS=$(find ios/.symlinks -type d -path "*/workmanager_apple/Sources/workmanager_apple" 2>/dev/null || true)

    for dir in $DIRS; do
      echo "Found workmanager_apple directory: $dir"

      scheduler="$dir/BGContinuedProcessingTaskScheduler.swift"
      if [ -f "$scheduler" ]; then
        chmod u+w "$scheduler" 2>/dev/null || true
        cat << 'SWIFTEOF' > "$scheduler"
import Foundation

extension WorkmanagerPlugin {
#if os(iOS)
    func registerContinuedProcessingTask(
        request: ContinuedProcessingTaskRequest,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        completion(.failure(PigeonError(
            code: "99",
            message: "ContinuedProcessingTask could not be registered",
            details: "BGContinuedProcessingTask is not supported"
        )))
    }

    @objc
    public static func registerBGContinuedProcessingTask(withIdentifier identifier: String) {
    }
#endif
}
SWIFTEOF
        echo "Successfully patched $scheduler"
      fi

      plugin="$dir/WorkmanagerPlugin.swift"
      if [ -f "$plugin" ]; then
        chmod u+w "$plugin" 2>/dev/null || true

        awk '
        BEGIN { skip = 0 }
        /\} else if #available\(iOS 26\.0, \*\), request\.type == \.continuedProcessingTask \{/ {
          skip = 1
          next
        }
        /self\.handleBGContinuedProcessingTask\(request: request, completion: completion\)/ {
          if (skip) next
        }
        /^\s*\}/ {
          if (skip) {
            skip = 0
            next
          }
        }
        { print }
        ' "$plugin" > "$plugin.tmp"

        mv "$plugin.tmp" "$plugin"
        echo "Successfully patched $plugin"
      fi
    done
  fi
fi

echo "patch_workmanager_apple.sh finished."
