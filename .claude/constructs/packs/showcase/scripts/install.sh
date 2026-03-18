#!/usr/bin/env bash
set -euo pipefail

GRIMOIRE_DIR="grimoires/the-easel/constructs/showcase"

# Create knowledge directories
mkdir -p "$GRIMOIRE_DIR/storytelling"
mkdir -p "$GRIMOIRE_DIR/visual-metaphor"
mkdir -p "$GRIMOIRE_DIR/data-encoding"
mkdir -p "$GRIMOIRE_DIR/visual-semiotics"
mkdir -p "$GRIMOIRE_DIR/audits"

echo "✓ Showcase installed successfully"
echo ""
echo "Knowledge base: $GRIMOIRE_DIR"
echo "Quick start: /showcase-audit"
