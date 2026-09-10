#!/usr/bin/env bash
set -e

# Workaround for workmanager_apple (0.9.10 - 0.9.11) compiler bug on Xcode 16 / iOS SDK
# BGContinuedProcessingTask is only available on iOS 26+ and does not exist in iOS 17/18 SDKs.
echo "Running patch_workmanager_apple.sh..."

DIRS=$(find "${HOME}/.pub-cache" ios/.symlinks .symlinks -type d -path "*/workmanager_apple/Sources/workmanager_apple" 2>/dev/null || true)

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
    grep -v "BGContinuedProcessingTask" "$plugin" | grep -v "handleBGContinuedProcessingTask" > "$plugin.tmp" && mv "$plugin.tmp" "$plugin"
    echo "Successfully patched $plugin"
  fi
done

echo "patch_workmanager_apple.sh finished."
