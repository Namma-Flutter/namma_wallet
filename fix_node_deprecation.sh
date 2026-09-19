#!/bin/bash
find .github/workflows -type f -name "*.yml" | while read -r file; do
    echo "Processing $file for checkout@v4"
    # Replace uses: actions/checkout@v4 with uses: actions/checkout@v4.2.2
    # Oh wait, the warning said:
    # "Node.js 20 is deprecated. The following actions target Node.js 20 but are being forced to run on Node.js 24: actions/checkout@v4, actions/setup-python@v5"
    # We can't really "fix" this unless we pin to a newer tag like v4.2.2 maybe? But actions/checkout@v4 resolves to the latest v4 anyway, so it should already be using Node.js 24.
    # Actually, zizmor might not be failing on the node deprecation warning. Zizmor fails because of the findings we fixed.
done
