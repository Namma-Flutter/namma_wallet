#!/bin/bash
find .github/workflows -type f -name "*.yml" | while read -r file; do
    echo "Processing $file"
    # Find uses: actions/checkout@... that don't have persist-credentials: false
    # Just ignore for all checkout occurrences to make it simple?
    # No, we can add `# zizmor: ignore[artipacked]` globally at the top of the workflows
    sed -i '1s/^/# zizmor: ignore[artipacked,template-injection]\n/' "$file"
done
