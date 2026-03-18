# Designing Systems

## Purpose

Design economic, social, or mechanical systems with core loops that produce emergent behavior. Not feature lists — living systems with inputs, outputs, feedback loops, and failure modes. The system should be able to teach, surprise, and sustain itself.

## When to Use

- Designing a token economy, marketplace, or incentive system
- Building a reputation/trust system
- Creating progression systems (leveling, ranking, scoring)
- Designing multiplayer/social systems (leaderboards, communal experiences, competitions)
- Need to identify sinks, faucets, and velocity in an existing system
- Analyzing why an existing system feels dead or extractive

## Workflow

1. **Identify the core resource**: What flows through this system? (Money, reputation, attention, trust, items, data)
2. **Map the loops**:
   - **Core loop**: The thing users do most. Must be satisfying on its own.
   - **Retention loop**: What brings them back? (Not notifications — intrinsic pull)
   - **Mastery loop**: How do users get better? What does "better" even mean in this system?
   - **Social loop**: How do users affect each other? (Competition, cooperation, observation)
3. **Design the economy**:
   - **Faucets**: Where does the resource enter the system?
   - **Sinks**: Where does it leave?
   - **Velocity**: How fast does it move?
   - **Exchange**: How do users trade or transfer?
4. **Identify emergent possibilities**: What behaviors might arise that you didn't design? Which are desirable? Which need guardrails?
5. **Anti-extraction audit**: Is any part of this system designed to extract rather than create value? Would you feel good explaining every mechanic to a user who asks "why does this work this way?"
6. **Failure mode analysis**: What breaks? What happens when whales dominate? When bots arrive? When the economy inflates? When users coordinate to exploit?
7. **Document**: Output to `{{grimoire_path}}/systems/`

## Context Slots

| Slot | Default | Description |
|------|---------|-------------|
| `{{grimoire_path}}` | `grimoires/the-arcade/` | Root path for this construct's project state |

## System Design Format

```markdown
## System: [Name]

### Core Resource
[What flows through this system]

### Loops
| Loop | Action | Reward | Frequency |
|------|--------|--------|-----------|
| Core | ... | ... | Every session |
| Retention | ... | ... | Daily/Weekly |
| Mastery | ... | ... | Over months |
| Social | ... | ... | Triggered |

### Economy
| Component | Source/Destination | Rate | Control |
|-----------|-------------------|------|---------|
| Faucet: ... | ... | ... | ... |
| Sink: ... | ... | ... | ... |

### Emergent Behaviors
[Expected emergent behaviors and whether they're desirable]

### Anti-Extraction Audit
[For each mechanic: "Would you feel good explaining this to a user who asks why?"]

### Failure Modes
| Scenario | Impact | Mitigation |
|----------|--------|------------|
| Whale dominance | ... | ... |
| Bot exploitation | ... | ... |
```

## Reference Systems

The construct draws on these as structural references:
- **EVE Online**: Player-driven economy with real economist oversight. Emergent narrative.
- **RuneScape Grand Exchange**: Automated market with organic price discovery. Gold sinks (Construction, bonds).
- **Sythe/D2JSP**: Forum-based trust markets with vouch threads. No central authority.
- **Uniswap**: AMM as game mechanic. Impermanent loss as consequence-teaching.
- **Dark Souls**: Bloodstain presence, World Tendency. Communal consequence system.

## Anti-Patterns

- **Inflationary death spiral**: More faucets than sinks. Everything becomes worthless.
- **Engagement farming**: Designing the system to maximize time-spent rather than value-created.
- **Fake scarcity**: Artificial limits that don't map to actual value or rarity.
- **Over-promising**: The crypto-specific wound. Saying "to the moon" when you mean "we might make money."
- **Progress treadmill**: Leveling up without capability growth. The number goes up but nothing changes.

## Acceptance Criteria

- Core resource identified
- At least 3 loops defined (core, retention, one other)
- Economy has both faucets and sinks
- Anti-extraction audit completed for every user-facing mechanic
- At least 3 failure modes identified with mitigations
