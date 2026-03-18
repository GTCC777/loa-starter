# Capturing Results

## Purpose

Annotate visual generation results with vocabulary terms and quality assessments. Creates a structured record of what worked, what didn't, and which vocabulary terms were most effective.

## When to Use

- After receiving image generation results
- When reviewing design artifacts against vocabulary
- Building a pattern library of effective prompt-to-result mappings

## Workflow

1. **Review results**: Examine the generated or designed artifacts
2. **Match vocabulary**: Identify which vocabulary terms are present in the result
3. **Assess quality**: Evaluate against quality gates (if defined)
4. **Annotate**: Create a structured annotation with terms, scores, and observations
5. **Save**: Write the capture to `{{grimoire_path}}/captures/`

## Context Slots

| Slot | Default | Description |
|------|---------|-------------|
| `{{grimoire_path}}` | `grimoires/the-easel/` | Root path for this construct's project state |
| `{{vocabulary_path}}` | `{{grimoire_path}}/vocabulary/atlas.md` | Path to the vocabulary atlas |

## Capture Format

Each capture includes:
- **Source**: What was evaluated (generation prompt, design file, screenshot)
- **Vocabulary match**: Which terms are visible/present, which are missing
- **Quality assessment**: Pass/partial/fail against quality gates
- **Observations**: What surprised, what confirmed expectations
- **Recommendation**: Keep, iterate, or discard

## Outputs

- Structured capture file in `{{grimoire_path}}/captures/`
- Updated vocabulary effectiveness notes (which terms translate well to visuals)

## Acceptance Criteria

- Capture references specific vocabulary terms
- Quality assessment uses defined gates (not subjective preference)
- Observations distinguish between term effectiveness and execution quality
- Recommendation includes rationale
