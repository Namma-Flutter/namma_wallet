#!/bin/bash
sed -i 's/uses: actions\/setup-python@42375524e23c412d93fb67b49958b491fce71c38 # v5.4.0/uses: actions\/setup-python@v5/g' .github/workflows/security-audit.yml
sed -i 's/uses: actions\/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2/uses: actions\/checkout@v4/g' .github/workflows/security-audit.yml
