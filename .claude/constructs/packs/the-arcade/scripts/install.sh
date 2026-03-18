#!/usr/bin/env bash
# Post-install hook for The Arcade construct
set -euo pipefail

CONSTRUCT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="$(pwd)"

# Create grimoire directories for project state
GRIMOIRE_DIR="${PROJECT_ROOT}/grimoires/the-arcade"
mkdir -p "${GRIMOIRE_DIR}"/{references,progressions,prototypes,systems,playtests,feel}

echo ""
echo "  The Arcade construct installed"
echo ""
echo "  Three axes:"
echo "    Arcade    — progressive disclosure, entry ramps"
echo "    Forum     — trust markets, consequence"
echo "    Organism  — living systems, adaptation"
echo ""
echo "  Skills:"
echo "    /reference     Find structural game design parallels"
echo "    /progression   Design progressive disclosure systems"
echo "    /prototype     Rapid mechanic prototyping with feel"
echo "    /systems       Design economic/social systems with core loops"
echo "    /playtest      Structure playtests for learning validation"
echo "    /feel          Tune the phenomenology of an interaction"
echo ""
echo "  State directory: ${GRIMOIRE_DIR}/"
echo ""
