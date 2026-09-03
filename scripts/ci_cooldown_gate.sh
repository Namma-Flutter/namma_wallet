#!/usr/bin/env bash
set -eo pipefail

WORKFLOW_FILE="${1:-ci.yml}"
COOLDOWN_SECONDS="${2:-600}" # 600s = 10 minutes
HEAD_BRANCH="${3:-${GITHUB_HEAD_REF:-$(git rev-parse --abbrev-ref HEAD)}}"
REPO="${4:-${GITHUB_REPOSITORY:-Namma-Flutter/namma_wallet}}"
PR_NUMBER="${5:-${PR_NUMBER}}"

echo "=================================================="
echo "⏳ CI Cooldown & Debounce Gate"
echo "Workflow: $WORKFLOW_FILE"
echo "Branch:   $HEAD_BRANCH"
echo "PR:       ${PR_NUMBER:-N/A}"
echo "Cooldown: $COOLDOWN_SECONDS seconds ($((COOLDOWN_SECONDS / 60)) minutes)"
echo "=================================================="

# Check for commit message bypass
LAST_COMMIT_MSG=$(git log -1 --pretty=%B 2>/dev/null || echo "")
if echo "$LAST_COMMIT_MSG" | grep -iqE '\[(force-ci|skip-cooldown|skip cooldown|run-ci)\]'; then
  echo "⚡ Bypass flag detected in commit message ('$LAST_COMMIT_MSG'). Proceeding immediately without cooldown."
  exit 0
fi

# Check for PR label bypass if PR number is available
if [ -n "$PR_NUMBER" ] && [ -n "$REPO" ]; then
  PR_LABELS=$(gh api "repos/${REPO}/issues/${PR_NUMBER}/labels" --jq '.[].name' 2>/dev/null || echo "")
  if echo "$PR_LABELS" | grep -iqE '(ci:\s*run-now|run-now|force-ci)'; then
    echo "⚡ Bypass label detected on PR #$PR_NUMBER. Proceeding immediately without cooldown."
    exit 0
  fi
fi

# Check if branch or repo is missing
if [ -z "$HEAD_BRANCH" ] || [ -z "$REPO" ]; then
  echo "Missing branch or repository information. Proceeding immediately."
  exit 0
fi

# Fetch the last completed run timestamp for this workflow and branch
LAST_COMPLETED=$(gh api "repos/${REPO}/actions/workflows/${WORKFLOW_FILE}/runs?event=pull_request&branch=${HEAD_BRANCH}&status=completed&per_page=1" --jq '.workflow_runs[0].updated_at' 2>/dev/null || echo "")

if [ -z "$LAST_COMPLETED" ] || [ "$LAST_COMPLETED" == "null" ]; then
  echo "No previous completed run found for this branch. Proceeding immediately."
  exit 0
fi

echo "Last completed run timestamp: $LAST_COMPLETED"

# Calculate elapsed time
LAST_EPOCH=$(date -d "$LAST_COMPLETED" +%s 2>/dev/null || date -jf "%Y-%m-%dT%H:%M:%SZ" "$LAST_COMPLETED" +%s 2>/dev/null || echo "0")
NOW_EPOCH=$(date +%s)

if [ "$LAST_EPOCH" -eq 0 ]; then
  echo "Could not parse timestamp ($LAST_COMPLETED). Proceeding immediately."
  exit 0
fi

ELAPSED=$((NOW_EPOCH - LAST_EPOCH))
echo "Elapsed since last completed run: $ELAPSED seconds ($((ELAPSED / 60)) minutes)"

if [ "$ELAPSED" -lt "$COOLDOWN_SECONDS" ]; then
  REMAINING=$((COOLDOWN_SECONDS - ELAPSED))
  echo "⏳ Cooldown active: A run completed $ELAPSED seconds ago (< $COOLDOWN_SECONDS s)."
  echo "Sleeping for remaining $REMAINING seconds ($((REMAINING / 60)) min $((REMAINING % 60)) s)..."
  echo "Note: If you push new commits during this window, this run will be cancelled and reset."
  sleep "$REMAINING"
  echo "✅ Cooldown elapsed. Proceeding with workflow execution."
else
  echo "✅ More than $((COOLDOWN_SECONDS / 60)) minutes elapsed ($ELAPSED seconds). Proceeding immediately."
fi
