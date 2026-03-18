#!/usr/bin/env bash
# Validate all Observer skills have required files and consistent metadata
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(cd "$SCRIPT_DIR/../skills" && pwd)"
MANIFEST="$(cd "$SCRIPT_DIR/.." && pwd)/construct.yaml"

errors=0
warnings=0
checked=0

for skill_dir in "$SKILLS_DIR"/*/; do
  slug="$(basename "$skill_dir")"
  checked=$((checked + 1))

  # Every skill must have SKILL.md
  if [ ! -f "$skill_dir/SKILL.md" ]; then
    echo "ERROR: $slug — missing SKILL.md"
    errors=$((errors + 1))
    continue
  fi

  # Check if skill is declared in construct.yaml
  if ! grep -q "slug: $slug" "$MANIFEST" 2>/dev/null; then
    echo "ERROR: $slug — not declared in construct.yaml"
    errors=$((errors + 1))
  fi

  # Skills with index.yaml: verify required fields
  if [ -f "$skill_dir/index.yaml" ]; then
    if ! grep -q "capabilities:" "$skill_dir/index.yaml" 2>/dev/null; then
      echo "WARNING: $slug — index.yaml missing capabilities stanza"
      warnings=$((warnings + 1))
    fi
  fi
done

# Check manifest doesn't declare skills that don't exist on disk
if command -v yq &>/dev/null; then
  yq -r '.skills[].slug' "$MANIFEST" 2>/dev/null | while read -r declared; do
    if [ ! -d "$SKILLS_DIR/$declared" ]; then
      echo "ERROR: construct.yaml declares '$declared' but directory missing"
      errors=$((errors + 1))
    fi
  done
fi

echo ""
echo "Checked $checked skills: $errors errors, $warnings warnings"
exit "$errors"
