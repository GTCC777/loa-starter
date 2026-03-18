# The Easel

Creative studio construct for aesthetic direction — vocabulary grounding, visual exploration, result capture, and taste decisions.

## What It Does

The Easel provides a structured creative workflow:

1. **Ground** — Review your vocabulary atlas and existing taste decisions
2. **Explore** — Generate prompts grounded in your project's vocabulary
3. **Capture** — Annotate results with vocabulary terms and quality assessments
4. **Record** — Document design decisions as Taste Decision Records

## Domain-Agnostic

The Easel ships with empty templates. Your project fills them in through the skills. Whether you're designing cyberpunk interfaces, minimalist dashboards, or cozy mobile apps — the process is the same.

## Skills

| Skill | Description |
|-------|-------------|
| `grounding-creative` | Review vocabulary and TDRs for a design area |
| `exploring-visuals` | Generate vocabulary-grounded prompts for visual exploration |
| `capturing-results` | Annotate generation results with vocabulary terms |
| `recording-taste` | Create and manage Taste Decision Records |

## Install

```bash
/constructs install the-easel
```

## Context Slots

Configure paths for your project:

| Slot | Default | Description |
|------|---------|-------------|
| `{{grimoire_path}}` | `grimoires/the-easel/` | Root path for project state |
| `{{vocabulary_path}}` | `{{grimoire_path}}/vocabulary/atlas.md` | Vocabulary atlas |
| `{{tdr_path}}` | `{{grimoire_path}}/tdr/` | Taste Decision Records |
| `{{generation_tool}}` | `your preferred image generation tool` | Image generation tool |

## Composability

- **With Artisan**: Easel TDRs inform Artisan's taste token inscription
- **With Observer**: User feedback about visual design can ground new vocabulary

## License

MIT
