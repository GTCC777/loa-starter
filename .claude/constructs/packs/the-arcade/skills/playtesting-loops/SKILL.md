# Playtesting Loops

## Purpose

Structure a playtest to answer specific questions about feel, learning, and system behavior. Not user testing (surveys, NPS, task completion). Playtesting — watching someone interact with a system and observing what the system teaches them without being told.

## When to Use

- A mechanic prototype is ready to test
- Need to validate that progressive disclosure actually teaches
- Testing whether a system feels right before shipping
- Observing where users get stuck, confused, or disengaged
- Comparing two mechanic variations to pick the one that feels better
- After a "it works but something feels off" observation

## Workflow

1. **State the playtest question**: What specific thing are you trying to learn? Not "is it good?" — a specific, answerable question.
2. **Define the observation protocol**:
   - **What to watch for**: Specific behaviors that answer your question
   - **What NOT to intervene on**: Let them struggle. The struggle IS the data.
   - **Duration**: How long is enough to see the pattern?
3. **Set up the environment**:
   - Strip chrome — remove anything that isn't the mechanic being tested
   - Define starting state — what does the tester see/know/have at the start?
   - No preamble — don't explain what they're about to do. If you need to explain, the design hasn't spoken yet.
4. **Run the playtest**:
   - Observe in silence. No hints. No "try clicking that."
   - Note: where do they hesitate? Where do they smile? Where do they quit?
   - Note: what do they try that you didn't expect?
5. **Analyze observations**:
   - **Learning moments**: Did the system teach what you intended?
   - **Friction points**: Where did the system fail to communicate?
   - **Surprise behaviors**: What did the tester do that you didn't predict?
   - **Feel assessment**: Did the tester's emotional journey match your design intent?
6. **Document findings**: Output to `{{grimoire_path}}/playtests/`

## Context Slots

| Slot | Default | Description |
|------|---------|-------------|
| `{{grimoire_path}}` | `grimoires/the-arcade/` | Root path for this construct's project state |

## Playtest Report Format

```markdown
## Playtest: [Name]

### Question
[Specific question this playtest answers]

### Setup
- Starting state: ...
- Duration: ...
- Tester context: [What they know/don't know going in]

### Observations
| Timestamp | Behavior | Category | Note |
|-----------|----------|----------|------|
| 0:00 | ... | learning/friction/surprise | ... |

### Findings
**Did the system teach?** [Yes/No + what specifically]
**Where did it fail?** [Specific friction points]
**Surprises?** [Unexpected behaviors]
**Feel match?** [Did emotional journey match design intent?]

### Verdict
[Ship / Iterate / Kill — with specific reasoning]
```

## Observation Categories

- **Learning**: The user understood something without being told
- **Friction**: The user was blocked, confused, or frustrated
- **Surprise**: The user did something unexpected — might be emergent behavior worth preserving
- **Flow**: The user entered a focused, uninterrupted state
- **Exit**: The user disengaged — why? Boredom? Frustration? Completion?

## Anti-Patterns

- **Leading questions**: "Did you notice the button?" teaches nothing. Watch where they look.
- **Explaining before testing**: If you need to explain, the test already failed. That's the finding.
- **Averaging feedback**: "3 out of 5 liked it" is useless. What did each person DO?
- **Testing features, not feel**: Task completion is QA. Playtesting is about the quality of the experience.
- **One playtest**: Systems need iteration. One round tells you what's wrong. Three rounds tell you if you fixed it.

## Acceptance Criteria

- Playtest question is specific and answerable
- Observation protocol defined (what to watch, what not to intervene on)
- No explanation given to tester before the playtest
- Observations categorized (learning, friction, surprise, flow, exit)
- Verdict given with specific reasoning
