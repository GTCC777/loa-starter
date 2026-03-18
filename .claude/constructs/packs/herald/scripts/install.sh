#!/bin/bash
#
# install.sh - Install Herald construct for a project
#
# Usage:
#   ./install.sh [PROJECT_ROOT]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(dirname "$SCRIPT_DIR")"

PROJECT_ROOT="${1:-.}"

echo "╭───────────────────────────────────────────────────────╮"
echo "│  HERALD CONSTRUCT INSTALLER                           │"
echo "╰───────────────────────────────────────────────────────╯"
echo ""

# Create grimoire structure
GRIMOIRE_DIR="$PROJECT_ROOT/grimoires/herald"
mkdir -p "$GRIMOIRE_DIR/announcements"
mkdir -p "$GRIMOIRE_DIR/chronicles"
mkdir -p "$GRIMOIRE_DIR/feedback"

echo "✓ Created grimoire structure at $GRIMOIRE_DIR"

# Create voice context directory
VOICE_DIR="$PROJECT_ROOT/contexts/voice"
mkdir -p "$VOICE_DIR"

# Initialize voice.md from template if not exists
if [ ! -f "$VOICE_DIR/voice.md" ]; then
    if [ -f "$PACK_DIR/templates/voice-template.md" ]; then
        # Copy template as starting point (user customizes)
        cat > "$VOICE_DIR/voice.md" << 'VOICE'
# Voice Profile

Configure this file to control announcement tone, vocabulary, and register.
Run `/synthesize-voice` with existing content to auto-generate, or edit directly.

## Register

- style: lowercase
- formality: casual-direct
- perspective: first-person-plural
- fragments: closers-only

## Vocabulary

### Preferred Terms
| Instead of | Use |
|-----------|-----|
| unfortunately | (omit — lead with the action) |
| sunset / deprecate | remove / cut |
| exciting | (omit — let the work speak) |
| users | people / holders / community |

### Banned Words
- game-changing
- incredible
- massive
- revolutionary
- stay tuned
- something big
- you're not ready

## Tone

- emotional_range: neutral
- humor: dry, occasional, never forced
- confidence: matter-of-fact, not boastful
- on_bad_news: direct, no hedging
- on_good_news: brief, no hype

## Rhythm

- sentences: short by default, vary for emphasis
- paragraphs: 2-4 sentences max
- structure: action first, context second, philosophy last
- lists: preferred for itemized changes
- closer: philosophical or none

## Audience

- primary: community
- assumed_knowledge: medium
- context_level: moderate
- action_items: embedded
VOICE
    echo "✓ Initialized default voice.md"
else
    echo "✓ Preserved existing voice.md"
fi

# Initialize principles.md if not exists
if [ ! -f "$VOICE_DIR/principles.md" ]; then
    cat > "$VOICE_DIR/principles.md" << 'PRINCIPLES'
# Communication Principles

Non-negotiable constraints for all outbound communication.
Herald validates every draft against these rules.

## We Say

| Principle | Example |
|-----------|---------|
| What shipped, in past tense | "vault earned BGT rewards through AquaBera LP" |
| Concrete external reasons | "berachain's POL update removed the reward flows" |
| What was never built, honestly | "incineraffle never left the lobby" |
| Practical action items | "if you have funds in vault — withdraw before then" |
| Dates from git, not memory | "these shipped with the arcade in september" |

## We Never Say

| Anti-pattern | Why |
|-------------|-----|
| Forward-looking promises | People screenshot and hold you to every word months later |
| Internal feature names | Reveals roadmap, creates expectations for unshipped work |
| Hype language to manage sentiment | Converts neutral updates into future obligations |
| Apologies or hedges | "Unfortunately" frames curation as failure |
| Timelines for unshipped work | Becomes a commitment the moment it's public |
| Screenshots of WIP | Community treats previews as promises |

## Truth Hierarchy

```
CODE (git history, commits, PRs) > Published artifacts > Team context > Memory
```

Every claim in an announcement must be traceable to code evidence.
If it can't be verified, it doesn't go in the announcement.
PRINCIPLES
    echo "✓ Initialized default principles.md"
else
    echo "✓ Preserved existing principles.md"
fi

# Initialize state
STATE_FILE="$GRIMOIRE_DIR/state.yaml"
if [ ! -f "$STATE_FILE" ]; then
    cat > "$STATE_FILE" << YAML
# Herald State
# Tracks announcement and chronicle activity

version: 1
created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
last_updated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

metrics:
  total_announcements: 0
  total_chronicles: 0
  voice_refinements: 0
YAML
    echo "✓ Initialized state.yaml"
else
    echo "✓ Preserved existing state.yaml"
fi

echo ""
echo "╭───────────────────────────────────────────────────────╮"
echo "│  INSTALLATION COMPLETE                                │"
echo "╰───────────────────────────────────────────────────────╯"
echo ""
echo "Available commands:"
echo "  /announce {what changed}        - Draft grounded announcement"
echo "  /synthesize-voice {content}     - Extract voice from existing content"
echo "  /chronicle {feature or scope}   - Research git history into timeline"
echo ""
echo "Artifacts:"
echo "  $VOICE_DIR/voice.md         - Edit to customize tone"
echo "  $VOICE_DIR/principles.md    - Edit to set constraints"
echo "  $GRIMOIRE_DIR/              - Generated output"
echo ""
