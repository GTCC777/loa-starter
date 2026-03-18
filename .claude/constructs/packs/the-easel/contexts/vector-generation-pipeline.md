# Vector Generation Pipeline — Research-Backed Best Practices

> **Version**: 2.0.0
> **Date**: 2026-03-14
> **Status**: Decided — grounded in Recraft V4 official documentation
> **Supersedes**: 3x3 grid approach from rektdrop-interface/grimoires/the-easel/

---

## Model: Recraft V4 Pro

| Attribute | Value |
|-----------|-------|
| Endpoint | `recraft/v4/pro/text-vector` on Fal.ai |
| Output | Vector illustration (rasterized in vector aesthetic) |
| Cost | ~$0.08 per generation (vector styles cost 2x) |
| Best sub-styles | `line_art`, `sharp_contrast`, `bold_stroke` |
| API | One image per request — no native grid support |

---

## Critical Finding: Single-Focus > Grids

The Recraft API generates **one image per request**. The "3x3 grid" technique asks the model to compose 9 concepts within a single image — this is an undocumented hack that splits model attention.

Recraft's composition documentation covers only single-subject layouts: centered, rule of thirds, tight crop. There is **zero mention** of grid layouts in any official docs.

**Revised approach**: Run 3-7 separate single-focus generations per construct. Each gets 100% model attention at $0.08 per generation. Total cost for 7 concepts: $0.56 — negligible vs. quality loss from grids.

---

## Prompt Engineering (from Recraft V4 docs)

### For Logos, Icons, Emblems

Define:
1. **Graphic type** — logo, icon, symbol, emblem, insignia
2. **Shape logic** — geometry, symmetry, silhouette
3. **Strict palette** — exact colors
4. **Line discipline** — "consistent stroke width, no texture"
5. **Hard constraints** — "no gradients, no shadows, no text"
6. **Scale intent** — "works at small sizes"

### Prompt Length

Short prompts trigger **interpretive mode** — the model designs WITH you. Good for exploration.

Long structured prompts give **architectural control** — the model executes YOUR spec. Good for refinement.

> "Short prompts → model designs *with* you. Long prompts → model executes *your* architecture." — Recraft V4 docs

### Prompt Ordering

Element order affects priority. Earlier elements have stronger influence.

Two valid patterns:
- **Subject → Style → Constraints** (prioritizes the concept)
- **Style → Subject → Constraints** (prioritizes the aesthetic)

### What NOT To Do

| Anti-Pattern | Why It Fails | Do Instead |
|-------------|-------------|------------|
| Stack dramatic adjectives | Precision outperforms exaggeration | Be specific: "6-8 angular strokes" not "incredibly detailed" |
| Texture/material language for vectors | Counterproductive — model tries to render material | Describe shape and structure only |
| Text baked into the design | Splits model attention between shapes and letterforms | Generate shapes only, add text in code/Figma |
| Assume verbosity = quality | More words ≠ better output | Match detail level to intent |
| 3x3 grids within one image | Splits attention ~11% per cell | Run separate generations |

---

## The Pipeline

```
1. EXPLORE  — Recraft V4 Pro, single-focus, 3-7 generations per construct
               Short precise prompts. 100% model attention each.
               Output: 3-7 separate vector concepts.

2. SELECT   — Human picks the concept with the most weight.
               Not the prettiest — the one with the most meaning.

3. DIAL-IN  — Recraft V4 Pro, single-focus, refined prompt.
               Reference what specifically worked about the winner.
               80-90% canvas fill. Maximum fidelity.

4. ITERATE  — "Keep/Change" refinement.
               Explicit about what works (KEEP) and what to adjust (CHANGE).
               One change category at a time.

5. CONVERT  — Code-mode LLM (Claude or Gemini) traces to production SVG.
               Strict spec: stroke="currentColor", viewBox="0 0 128 128",
               integer coordinates, simplest primitives.

6. POLISH   — Manual cleanup in code editor.
               Snap coordinates, remove cruft, test at target sizes.

7. WIRE     — Drop into codebase as React component.
               Test at 24px, 64px, 128px, and display scale.
```

### Phase Timing

| Phase | Time | Model |
|-------|------|-------|
| Explore | 5-10 min | Recraft V4 Pro |
| Select | 2 min | Human |
| Dial-In | 5 min | Recraft V4 Pro |
| Iterate | 5-10 min | Recraft V4 Pro |
| Convert | 5 min | Claude / Gemini code mode |
| Polish | 5 min | Human |
| Wire | 5 min | Developer |

---

## Prompt Templates

### Exploration (short, interpretive)

```
A single emblem centered on pure black background. Flat vector logo,
bone white on black. [ONE SENTENCE describing the concept and its
symbolic meaning]. Angular geometry, no gradients, no shadows, no text.
Military insignia style, works at small sizes. Consistent stroke width,
clean vector paths.
```

### Dial-In (structured, architectural)

```
A single emblem centered on pure black background. This is a refinement
of [CONCEPT NAME].

The exact mark: [DESCRIBE what worked — shape, proportions, stroke
weight, what makes it work. Be specific about what to KEEP.]

Render at maximum fidelity. The emblem occupies 80-90% of the canvas.
Bone white on pure black. Angular, geometric, consistent stroke width.
No gradients, no shadows, no text, no background elements.
```

### Iteration (keep/change)

```
A single emblem centered on pure black background. This mark is 80%
correct.

KEEP: [what works — proportions, stroke weight, overall shape]

CHANGE: [specific adjustments — "reduce to fewer strokes," "make the
central element larger," "increase spacing between elements"]

Same style. Bone white on black. One mark, centered, large.
```

### SVG Conversion (for Claude/Gemini code mode)

```
Convert this emblem EXACTLY to clean SVG. Trace the geometry precisely
— do not redesign.

Output requirements:
- <svg> with viewBox="0 0 128 128"
- stroke="currentColor" stroke-width="2"
- stroke-linecap="square" stroke-linejoin="miter"
- Stroke only, fill="none" unless solid area (then fill="currentColor")
- All coordinates snapped to nearest integer
- Simplest SVG primitives (line, polygon, rect, circle, path)
- No comments, no metadata
- Every straight line stays straight

Output ONLY raw SVG code.
```

---

## Style Recommendations

For logo/emblem work, use these Recraft sub-styles:

| Sub-style | Best For |
|-----------|----------|
| `line_art` | Cleanest strokes, most SVG-convertible |
| `sharp_contrast` | Bold marks with strong silhouettes |
| `bold_stroke` | Heavier weight marks, emblem-scale |
| `engraving` | Technical illustration feel |
| `line_circuit` | Technical/digital marks |

Avoid: `colored_stencil`, `mosaic`, `vivid_shapes` — too busy for insignia work.

---

## Color Control

The Fal.ai API accepts RGB color arrays:

```json
"colors": [{"r": 245, "g": 240, "b": 232}]
```

For bone-on-black work, pass the bone color to constrain the palette.

---

## Sources

- Recraft V4 Prompt Engineering Guide: prompting-with-recraft-v4
- Recraft Logos & Icons Guide: visual-formats/logos-and-icons
- Recraft Vector Art Guide: visual-formats/vector-art
- Recraft Composition Guide: core-principles/composition
- Recraft Level of Detail Guide: depth-and-control/level-of-detail
- Fal.ai Recraft V3 API Reference: fal.ai/models/fal-ai/recraft-v3/api
