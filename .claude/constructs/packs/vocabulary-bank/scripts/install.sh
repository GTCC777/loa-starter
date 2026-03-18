#!/usr/bin/env bash
set -euo pipefail

# construct-vocabulary-bank install script
# Creates grimoire directories and default files if they don't exist

SLUG="${1:-vocabulary-bank}"
GRIMOIRE_DIR="grimoires/${SLUG}"

echo "[vocabulary-bank] Installing vocabulary bank construct..."

# Create grimoire directories
mkdir -p "${GRIMOIRE_DIR}"

# Write default vocabulary bank if it doesn't exist
if [ ! -f "${GRIMOIRE_DIR}/vocabulary-bank.md" ]; then
  echo "[vocabulary-bank] Creating default vocabulary bank at ${GRIMOIRE_DIR}/vocabulary-bank.md"
  cp "$(dirname "$0")/../templates/vocabulary-bank-template.md" "${GRIMOIRE_DIR}/vocabulary-bank.md"
  echo "[vocabulary-bank] Run /synthesize-vocabulary to populate it from your codebase"
else
  echo "[vocabulary-bank] Vocabulary bank already exists at ${GRIMOIRE_DIR}/vocabulary-bank.md"
fi

# Write default channel registry if it doesn't exist
if [ ! -f "${GRIMOIRE_DIR}/channel-registry.md" ]; then
  echo "[vocabulary-bank] Creating default channel registry at ${GRIMOIRE_DIR}/channel-registry.md"
  cp "$(dirname "$0")/../templates/channel-registry-template.md" "${GRIMOIRE_DIR}/channel-registry.md"
  echo "[vocabulary-bank] Customize the channel map for your product"
else
  echo "[vocabulary-bank] Channel registry already exists at ${GRIMOIRE_DIR}/channel-registry.md"
fi

echo "[vocabulary-bank] Install complete. Next steps:"
echo "  1. Run /synthesize-vocabulary to extract terms from your codebase"
echo "  2. Review and populate the vocabulary bank"
echo "  3. Customize the channel registry for your Discord/comms channels"
echo "  4. Run /audit-vocabulary to check existing copy"
