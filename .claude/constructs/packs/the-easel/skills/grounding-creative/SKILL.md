# Grounding Creative

## Purpose

Review and establish the aesthetic vocabulary for a design area. Reads the vocabulary atlas and existing TDRs, identifies gaps, and prepares the creative context for exploration.

## When to Use

- Starting a new design area with no vocabulary
- Reviewing vocabulary before a visual exploration session
- Identifying vocabulary gaps after seeing new reference material

## Workflow

1. **Read vocabulary**: Load `{{vocabulary_path}}` (default: `{{grimoire_path}}/vocabulary/atlas.md`)
2. **Scan TDRs**: List existing records in `{{tdr_path}}` (default: `{{grimoire_path}}/tdr/`)
3. **Identify gaps**: Map which vocabulary domains have terms vs which are empty
4. **Report**: Present the current vocabulary state with clear gap indicators

## Context Slots

| Slot | Default | Description |
|------|---------|-------------|
| `{{grimoire_path}}` | `grimoires/the-easel/` | Root path for this construct's project state |
| `{{vocabulary_path}}` | `{{grimoire_path}}/vocabulary/atlas.md` | Path to the vocabulary atlas |
| `{{tdr_path}}` | `{{grimoire_path}}/tdr/` | Directory containing Taste Decision Records |

## Outputs

- Vocabulary coverage report (which domains have terms, which are empty)
- List of existing TDRs with their status
- Recommended next steps (explore a gap, refine existing terms, record a decision)

## Acceptance Criteria

- Reads vocabulary atlas without errors
- Correctly identifies populated vs empty domains
- Lists all TDRs with title and status
- Suggests actionable next steps
