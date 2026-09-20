#!/usr/bin/env bash
set -eo pipefail

echo "=================================================="
echo "Checking for forbidden fallback/default values..."
echo "Rule: Never use fallback/default values when parsing fails."
echo "      Explicit failure is better than implicit incorrect data."
echo "=================================================="

VIOLATIONS=0

while IFS= read -r -d '' file; do
  # 1. Check for fallback to DateTime.now() on parsing failure (e.g., ?? DateTime.now())
  FALLBACK_DATE=$(grep -nE '\?\?\s*DateTime\.now\(\)' "$file" || true)
  if [ -n "$FALLBACK_DATE" ]; then
    echo "❌ Forbidden '?? DateTime.now()' fallback in $file:"
    echo "$FALLBACK_DATE"
    echo ""
    VIOLATIONS=$((VIOLATIONS + 1))
  fi

  # 2. Check for catch block returning DateTime.now()
  CATCH_DATE=$(grep -n -C 2 "return DateTime.now()" "$file" | grep -B 2 -E "catch" || true)
  if [ -n "$CATCH_DATE" ]; then
    echo "❌ Forbidden catch-fallback to DateTime.now() in $file:"
    echo "$CATCH_DATE"
    echo ""
    VIOLATIONS=$((VIOLATIONS + 1))
  fi

  # 3. Check for fallback placeholders like ?? "Unknown", ?? "N/A", or ?? ""
  PLACEHOLDERS=$(grep -nE '\?\?\s*["\x27](Unknown|N/A|NA|unknown|)["\x27]' "$file" || true)
  if [ -n "$PLACEHOLDERS" ]; then
    echo "❌ Forbidden fallback placeholder in $file (parsers must return null):"
    echo "$PLACEHOLDERS"
    echo ""
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
done < <(find lib/src/features -type f -name "*parser*.dart" -print0)

if [ "$VIOLATIONS" -gt 0 ]; then
  echo "❌ Data policy check failed with $VIOLATIONS violation(s)."
  echo "Review AGENTS.md: Never use fallback/default values when parsing fails."
  exit 1
else
  echo "✅ Data policy check passed: No fallback defaults found across all parser files."
  exit 0
fi
