# Exploring Visuals

## Purpose

Generate single-focus image generation prompts grounded in the project's aesthetic vocabulary. Produces structured prompts for vector-native AI models (Recraft V4 Pro via Fal.ai is the current primary).

## When to Use

- Exploring visual directions for a new design area
- Generating logo marks, emblems, or insignia
- Testing vocabulary terms as visual prompt components
- Creating concept variations for selection

## Workflow

1. **Load vocabulary**: Read `{{vocabulary_path}}` for active terms
2. **Review intent**: Understand what aspect of the design needs exploration
3. **Review pipeline**: Read `contexts/vector-generation-pipeline.md` for current best practices
4. **Compose prompts**: Build **single-focus** generation prompts (one concept per prompt)
5. **Structure output**: Format with shape logic, palette constraints, and hard negatives

## Context Slots

| Slot | Default | Description |
|------|---------|-------------|
| `{{grimoire_path}}` | `grimoires/the-easel/` | Root path for this construct's project state |
| `{{vocabulary_path}}` | `{{grimoire_path}}/vocabulary/atlas.md` | Path to the vocabulary atlas |
| `{{generation_tool}}` | Recraft V4 Pro via Fal.ai | Vector-native generation model |
| `{{generation_style}}` | `vector_illustration/line_art` | Recraft style for cleanest vector output |

## Prompt Structure (Research-Backed)

Each prompt is a **single-focus generation** — one concept, one image, 100% model attention.

### Required Elements

| Element | Purpose |
|---------|---------|
| **Graphic type** | logo, emblem, insignia, icon |
| **Shape logic** | geometry, symmetry, silhouette description |
| **Palette** | exact colors (e.g., "bone white on pure black") |
| **Line discipline** | "consistent stroke width, clean vector paths" |
| **Hard constraints** | "no gradients, no shadows, no text" |
| **Scale intent** | "works at small sizes" |

### Anti-Patterns (Grounded in Recraft V4 Docs)

| Do NOT | Why | Do Instead |
|--------|-----|-----------|
| Request grids (3x3, 2x2) | Splits model attention, not a supported feature | Run separate generations |
| Stack adjectives | Precision outperforms exaggeration | Be specific about strokes and geometry |
| Include text in design | Degrades both text and shape quality | Add text in code/Figma |
| Use texture/material language | Counterproductive for vector work | Describe shape and structure |
| Write verbose prompts for exploration | Short prompts let the model design WITH you | Match detail to phase |

### Prompt Phases

**Exploration** (short, ~40 words): Let the model interpret. Run 3-7 per construct.

**Dial-in** (structured, ~80 words): Describe what worked about the winner. Single focus, 80-90% canvas.

**Iteration** (keep/change, ~60 words): Explicit about what works and what to adjust.

## Outputs

- 3-7 single-focus generation prompts per design task
- Vocabulary term mapping (which terms from the atlas were used)
- Recommended Recraft sub-style for the task
- Cost estimate ($0.08 per vector generation)

## Acceptance Criteria

- Each prompt targets ONE concept (no grids, no multi-concept compositions)
- Prompts include hard constraints (no gradients, no shadows, no text)
- Scale intent is specified ("works at small sizes")
- Vocabulary terms anchor the concept description
- Output format is compatible with Recraft V4 Pro via Fal.ai
