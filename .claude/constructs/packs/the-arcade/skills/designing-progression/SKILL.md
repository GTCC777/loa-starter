# Designing Progression

## Purpose

Design progressive disclosure systems that teach complex mechanics through play. No tooltips. No documentation. No "click here to learn about liquidity pools." The system teaches by consequence, spatial design, and paced revelation.

## When to Use

- Building onboarding for a complex product (DeFi, trading platform, multi-step process)
- Designing the first 5 minutes of a user experience
- Structuring how information is revealed over time
- Converting a documentation-heavy flow into a learn-by-doing flow
- Staging complexity so users aren't overwhelmed

## Workflow

1. **Inventory the complexity**: List every concept, mechanic, and decision the user needs to understand. Don't filter yet.
2. **Dependency map**: Which concepts depend on which? What must be understood before what? Draw the learning graph.
3. **Identify the core loop**: What is the one action the user will do most? That's the seed. Everything grows from there.
4. **Stage the disclosure**: Layer concepts from simplest to most complex. Each layer should be learnable through DOING, not reading.
5. **Design the teaching moments**: For each concept, how does the system teach it? Options:
   - **Spatial containment** (BotW Shrine of Resurrection — walled area forces discovery)
   - **Forced ability use** (Mega Man X — gap you can only cross by wall-jumping)
   - **Failure feedback** (Dark Souls — die, learn, adapt)
   - **Constraint removal** (Portal — new mechanic unlocked per chamber)
   - **Narrative consequence** (Dungeon Keeper — narrator reacts to your choices)
   - **Social observation** (Journey — see what other players are doing)
6. **Define the pacing**: How fast do new concepts arrive? Where are the breathing spaces?
7. **Document the progression map**: Output to `{{grimoire_path}}/progressions/`

## Context Slots

| Slot | Default | Description |
|------|---------|-------------|
| `{{grimoire_path}}` | `grimoires/the-arcade/` | Root path for this construct's project state |

## Progression Map Format

```markdown
## Progression: [Name]

### Core Loop
[The one action that seeds everything]

### Stages
| Stage | Concepts Introduced | Teaching Mechanism | Prerequisite |
|-------|--------------------|--------------------|-------------|
| 1     | ...                | Spatial containment | None        |
| 2     | ...                | Forced ability use  | Stage 1     |

### Breathing Spaces
[Where does the system give the user room to process?]

### Failure Points
[Where will users most likely fail? What does the system do when they fail?]

### Mastery Signals
[How does the user know they've understood? Not a badge — a capability they can exercise.]
```

## Anti-Patterns

- **Tooltip cascade**: "Click here! Now click here! Great, now click here!" — the user learns nothing
- **Front-loaded complexity**: showing everything at once because "users need to know"
- **No failure allowed**: systems that prevent mistakes prevent learning
- **Progress bars as teaching**: knowing you're 60% done doesn't mean you understand anything
- **Documentation as onboarding**: if the answer is "read the docs", the product failed

## Acceptance Criteria

- Core loop is identified and stated in one sentence
- Dependency map shows concept ordering
- Each concept has a specific teaching mechanism (not "we'll explain it")
- Breathing spaces are designed, not accidental
- Failure points are identified with system response
