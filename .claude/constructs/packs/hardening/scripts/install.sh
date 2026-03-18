#!/usr/bin/env bash
# Hardening construct — post-install hook
# Creates grimoires/hardening/ directory tree and initializes state files.
# Idempotent: does NOT overwrite existing state.

set -euo pipefail

# Resolve paths relative to the project root (where grimoires/ lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONSTRUCT_DIR="$(dirname "$SCRIPT_DIR")"

# Find project root by looking for grimoires/ directory
# Walk up from current working directory
PROJECT_ROOT="$(pwd)"
while [[ "$PROJECT_ROOT" != "/" ]]; do
  if [[ -d "$PROJECT_ROOT/grimoires" ]]; then
    break
  fi
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done

if [[ "$PROJECT_ROOT" == "/" ]]; then
  # No grimoires/ found — create at current working directory
  PROJECT_ROOT="$(pwd)"
fi

GRIMOIRE_DIR="$PROJECT_ROOT/grimoires/hardening"

echo "Hardening construct — post-install"
echo "  Construct: $CONSTRUCT_DIR"
echo "  Grimoire:  $GRIMOIRE_DIR"

# Create directory structure
DIRS=(
  "$GRIMOIRE_DIR/pmr"
  "$GRIMOIRE_DIR/actions"
  "$GRIMOIRE_DIR/triage"
  "$GRIMOIRE_DIR/signals"
  "$GRIMOIRE_DIR/correlations"
  "$GRIMOIRE_DIR/checklists"
)

for dir in "${DIRS[@]}"; do
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
    echo "  Created: $dir"
  else
    echo "  Exists:  $dir"
  fi
done

# Initialize state.yaml from template (do NOT overwrite existing)
STATE_FILE="$GRIMOIRE_DIR/state.yaml"
STATE_TEMPLATE="$CONSTRUCT_DIR/templates/grimoire-state-template.yaml"

if [[ ! -f "$STATE_FILE" ]]; then
  if [[ -f "$STATE_TEMPLATE" ]]; then
    cp "$STATE_TEMPLATE" "$STATE_FILE"
    echo "  Created: $STATE_FILE (from template)"
  else
    echo "  Warning: state template not found at $STATE_TEMPLATE"
  fi
else
  echo "  Exists:  $STATE_FILE (preserved)"
fi

# Initialize PIPELINE.md from template (do NOT overwrite existing)
PIPELINE_FILE="$GRIMOIRE_DIR/PIPELINE.md"
PIPELINE_TEMPLATE="$CONSTRUCT_DIR/templates/grimoire-pipeline-template.md"

if [[ ! -f "$PIPELINE_FILE" ]]; then
  if [[ -f "$PIPELINE_TEMPLATE" ]]; then
    cp "$PIPELINE_TEMPLATE" "$PIPELINE_FILE"
    echo "  Created: $PIPELINE_FILE (from template)"
  else
    echo "  Warning: pipeline template not found at $PIPELINE_TEMPLATE"
  fi
else
  echo "  Exists:  $PIPELINE_FILE (preserved)"
fi

echo ""
echo "Hardening construct installed successfully."
echo "  Grimoire: $GRIMOIRE_DIR"
echo "  Quick start: /postmortem \"describe your incident\""
