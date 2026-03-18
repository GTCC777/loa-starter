# Referencing Games

## Purpose

Find structural game design parallels for the problem at hand. Not surface-level "this is like a game" — deep structural mapping between a game design pattern and the non-game domain you're building in.

## When to Use

- Facing a UX/system design problem and want to see how games solved the structural equivalent
- Need to communicate a design direction using concrete game references that the team has played
- Building a financial product and want to identify which game economy patterns apply
- Designing onboarding and want to study how specific games teach their systems

## Workflow

1. **Understand the problem**: What is the actual design challenge? (Not "make it fun" — the specific structural problem: "users don't understand AMM mechanics", "trust bootstrapping in a new marketplace", "information overload on first session")
2. **Map to game design patterns**: Identify which game design domain this maps to (progressive disclosure? economy balancing? trust signaling? feel?)
3. **Find references**: Pull specific games, specific designers, specific moments where this pattern was solved — or deliberately broken
4. **Analyze the parallel**: Explain WHY the game reference maps structurally, not just aesthetically. What mechanism did the game use? What was the player's emotional/cognitive journey?
5. **Extract the principle**: Distill the transferable principle — not "do what Zelda did" but the underlying design rule that Zelda exemplifies
6. **Document the reference**: Record in `{{grimoire_path}}/references/` for future use

## Context Slots

| Slot | Default | Description |
|------|---------|-------------|
| `{{grimoire_path}}` | `grimoires/the-arcade/` | Root path for this construct's project state |

## Reference Format

```markdown
## Reference: [Name]

**Problem**: [The design challenge this addresses]
**Game**: [Specific game and moment]
**Designer**: [Who made this decision]
**Mechanism**: [What the game actually does — be specific]
**Why it works**: [The structural reason, not "it's cool"]
**Transferable principle**: [The rule you can apply elsewhere]
**Anti-pattern**: [What happens when you do this badly]
```

## Quality Standards

- References must be specific: a game, a moment, a mechanic — not "games do this well"
- The parallel must be structural, not aesthetic — why does the mechanism transfer?
- Include the anti-pattern: what does the bad version of this look like?
- Practitioner attribution: who designed this? Name them.
- The user probably played the game. Don't over-explain. If they haven't, they'll ask.

## Acceptance Criteria

- Problem is clearly stated in non-game terms
- At least 2 game references with structural analysis
- Each reference includes designer attribution
- Transferable principle is stated independently of the specific game
- Anti-pattern is identified
