# Crafting Feel

## Purpose

Analyze and tune the phenomenology of an interaction — how it FEELS to use, not what it does. Juice, weight, silence, restraint, timing. The gap between "this works" and "this feels right."

This skill bridges two traditions:
- **Juice maximalism** (Vlambeer's screenshake, Vlambeer's 'more effects') — adding feedback until the interaction sings
- **Restraint as intensity** (Ueda's subtraction design, Miyazaki's silence) — removing until only the essential remains

Both are valid. The question is which serves the moment.

## When to Use

- An interaction works functionally but feels flat, laggy, or lifeless
- Need to decide between adding feedback (juice) or removing noise (restraint)
- Tuning timing parameters (delays, holds, transitions, reveals)
- Designing emotional pacing across a multi-step experience
- The CRT/analog feel vocabulary needs translation to specific CSS/animation parameters
- After someone says "it feels off" and you need to diagnose what "off" means

## Workflow

1. **Name the current feel**: What does this interaction feel like RIGHT NOW? Use sensory language. Heavy? Brittle? Rushed? Dead? Floaty?
2. **Name the target feel**: What should it feel like? Not "good" — specific. "Deliberate." "Inevitable." "Like dropping a coin into a slot." "Like breathing out."
3. **Diagnose the gap**: What's causing the difference between current and target? Categories:
   - **Timing**: Too fast? Too slow? No breathing space? No commitment window?
   - **Weight**: Too light? Too heavy? No momentum? No snap?
   - **Feedback**: Too much? Too little? Wrong channel (visual when it should be audio)?
   - **Pacing**: Monotone? No contrast? Climax without setup? Setup without payoff?
   - **Silence**: Is there enough empty space? Or too much — does it feel abandoned?
4. **Identify the feel parameters**: What dials need turning?
   - Transition duration, easing curve, delay
   - Opacity, scale, blur, color shift
   - Sound (attack, sustain, decay)
   - Spacing, padding, breathing room
   - Hold time (kaironic hold — how long does the system pause before the next thing?)
5. **Apply the dialectic**: For this moment, is the answer juice or restraint?
   - **Violence** (EvaFlash, screen shake, glitch burst) — used ONCE for maximum impact
   - **Silence** (dark passage, void overlay, held emptiness) — the system holding space
   - **Stillness** (kaironic hold, static text prompt, the exhale) — not empty, just present
6. **Document**: Output to `{{grimoire_path}}/feel/`

## Context Slots

| Slot | Default | Description |
|------|---------|-------------|
| `{{grimoire_path}}` | `grimoires/the-arcade/` | Root path for this construct's project state |

## Feel Analysis Format

```markdown
## Feel: [Interaction Name]

### Current Feel
[Sensory description of how it feels now]

### Target Feel
[Sensory description of how it should feel]

### Diagnosis
| Dimension | Current | Target | Gap |
|-----------|---------|--------|-----|
| Timing | ... | ... | ... |
| Weight | ... | ... | ... |
| Feedback | ... | ... | ... |
| Pacing | ... | ... | ... |
| Silence | ... | ... | ... |

### Prescription
| Parameter | Current Value | Target Value | Reasoning |
|-----------|--------------|--------------|-----------|
| transition-duration | 200ms | 400ms | needs more weight |
| opacity hold | 0ms | 800ms | kaironic hold before reveal |

### Register
[Violence / Silence / Stillness — which register serves this moment?]
```

## Silence Taxonomy

Five levels of silence in interaction design (from Keogh/Ueda tradition):

1. **Micro-silence**: Input delay, hitstop — the breath between action and consequence
2. **Breathing room**: Padding between UI elements, paragraph spacing — room to process
3. **Kaironic hold**: System-imposed pause — the interface holding space before the next beat
4. **Void**: Dark passage, pure emptiness between states — nothing to read, nothing to do
5. **Abandonment**: Too much silence — the system feels dead, not contemplative

Levels 1-4 are tools. Level 5 is failure.

## Practitioner References

- **Steve Swink**: "Game Feel" — the canonical text on input-to-output phenomenology
- **Fumito Ueda**: Subtraction design — keep removing until only the essential feeling remains
- **Jan Willem Nijman**: "The Art of Screenshake" — systematic juice application
- **Bennett Foddy**: Deliberate friction as meaning-making
- **Miyazaki**: Weight and commitment — every input costs something, every output lands

## Acceptance Criteria

- Current and target feel described in sensory language (not "bad" and "good")
- Diagnosis identifies specific dimensions causing the gap
- Prescription includes concrete parameter values, not just "make it heavier"
- Register choice (violence/silence/stillness) justified for the specific moment
- Silence level identified and justified
