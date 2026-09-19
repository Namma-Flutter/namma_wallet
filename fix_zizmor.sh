#!/bin/bash
# Zizmor is failing the build with exit code 14 because there are findings in the workflows.
# Some of these are "credential persistence" warnings (low confidence, but failing the build maybe?).
# And some are "template injection" via github context fields in `run` sections.

echo "Let's check the exit code of zizmor locally:"
zizmor .github/workflows/deploy_github_pages.yml
echo "Exit code: $?"

zizmor .github/workflows/post-comment.yml
echo "Exit code: $?"

zizmor .github/workflows/pr-labeler.yml
echo "Exit code: $?"
