#!/usr/bin/env bash
# Validates all skill index.yaml files have required fields.
# Exit code 0 = all valid, 1 = validation errors found.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONSTRUCT_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$CONSTRUCT_DIR/skills"

ERRORS=0
CHECKED=0

REQUIRED_FIELDS=("name" "slug" "version" "description" "entry" "triggers" "allowed-tools")
REQUIRED_CAPABILITIES=("model_tier" "danger_level" "effort_hint" "downgrade_allowed")

echo "Validating skills in $SKILLS_DIR"
echo ""

for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name="$(basename "$skill_dir")"
  index_file="$skill_dir/index.yaml"
  skill_file="$skill_dir/SKILL.md"

  # Check SKILL.md exists for all skills
  if [[ ! -f "$skill_file" ]]; then
    echo "  ERROR: $skill_name — missing SKILL.md"
    ERRORS=$((ERRORS + 1))
  fi

  # Inner processes don't need index.yaml
  if [[ ! -f "$index_file" ]]; then
    # Check if SKILL.md marks this as non-user-invocable
    if [[ -f "$skill_file" ]]; then
      echo "  OK:    $skill_name — inner process (SKILL.md only)"
    else
      echo "  ERROR: $skill_name — missing both index.yaml and SKILL.md"
      ERRORS=$((ERRORS + 1))
    fi
    continue
  fi

  CHECKED=$((CHECKED + 1))

  # Validate required fields in index.yaml
  for field in "${REQUIRED_FIELDS[@]}"; do
    if ! grep -q "^${field}:" "$index_file" 2>/dev/null; then
      echo "  ERROR: $skill_name — missing required field '$field' in index.yaml"
      ERRORS=$((ERRORS + 1))
    fi
  done

  # Validate capabilities stanza
  if grep -q "^capabilities:" "$index_file" 2>/dev/null; then
    for cap_field in "${REQUIRED_CAPABILITIES[@]}"; do
      if ! grep -q "  ${cap_field}:" "$index_file" 2>/dev/null; then
        echo "  ERROR: $skill_name — missing capability '$cap_field' in index.yaml"
        ERRORS=$((ERRORS + 1))
      fi
    done
  else
    echo "  ERROR: $skill_name — missing 'capabilities' stanza in index.yaml"
    ERRORS=$((ERRORS + 1))
  fi

  if [[ $ERRORS -eq 0 ]]; then
    echo "  OK:    $skill_name"
  fi
done

echo ""
echo "Checked $CHECKED user-facing skills"

if [[ $ERRORS -gt 0 ]]; then
  echo "FAILED: $ERRORS validation errors found"
  exit 1
else
  echo "PASSED: all skills valid"
  exit 0
fi
