# Prototyping Mechanics

## Purpose

Rapid mechanic prototyping — define a game mechanic or interaction pattern, spec its parameters, and prototype it fast enough to feel. The prototype is not the product. The prototype answers one question: does this mechanic feel right?

## When to Use

- Testing whether a core loop works before building the full system
- Exploring multiple mechanic variations quickly
- Need to feel an interaction before committing to implementation
- Converting a system design into something playable/testable
- Designing micro-interactions with game feel (button feedback, state transitions, reveals)

## Workflow

1. **State the hypothesis**: "This mechanic will feel [X] because [Y]." One sentence. If you can't state it, you're not ready to prototype.
2. **Define the mechanic**:
   - **Input**: What does the user do?
   - **Process**: What does the system do in response?
   - **Output**: What does the user see/hear/feel?
   - **Loop**: How does this connect back to the next input?
3. **Identify feel parameters**: What variables control how this feels?
   - Timing (response delay, animation duration, hold time)
   - Weight (resistance, momentum, snap)
   - Feedback (visual, audio, haptic)
   - Stakes (what's at risk? what's gained?)
4. **Build the minimum testable version**: Strip everything that isn't the mechanic itself. No UI chrome. No error handling. No edge cases. Just the loop.
5. **Define the playtest question**: What specific thing are you testing? "Does this feel satisfying?" is not specific enough. "Does the 200ms delay between input and response feel deliberate or laggy?" is.
6. **Document**: Output mechanic spec to `{{grimoire_path}}/prototypes/`

## Context Slots

| Slot | Default | Description |
|------|---------|-------------|
| `{{grimoire_path}}` | `grimoires/the-arcade/` | Root path for this construct's project state |

## Mechanic Spec Format

```markdown
## Mechanic: [Name]

### Hypothesis
[One sentence: what this mechanic should feel like and why]

### Loop
Input → Process → Output → [next Input]

### Feel Parameters
| Parameter | Value | Range | Why |
|-----------|-------|-------|-----|
| response_delay | 150ms | 50-300ms | ... |

### Playtest Question
[Specific question this prototype answers]

### Variations
[2-3 parameter variations to test against each other]
```

## Principles

- **Prototype the feel, not the feature** — you're testing sensation, not functionality
- **One mechanic per prototype** — composing mechanics comes later
- **Parameters over polish** — expose the dials, don't hide them behind beautiful UI
- **Speed over quality** — a prototype that ships in an hour teaches more than a perfect one that ships next week
- **Kill fast** — if it doesn't feel right in 3 variations, the mechanic might be wrong, not the parameters

## Acceptance Criteria

- Hypothesis stated in one sentence
- Mechanic loop defined (input → process → output)
- At least 3 feel parameters identified with ranges
- Playtest question is specific and answerable
- At least 2 variations defined for comparison
