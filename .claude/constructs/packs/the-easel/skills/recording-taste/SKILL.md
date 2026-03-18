# Recording Taste

## Purpose

Create and manage Taste Decision Records (TDRs) — structured documents that capture design decisions with context, rationale, alternatives considered, and the vocabulary terms that anchor the decision.

## When to Use

- After making a design decision that should be remembered
- When a visual exploration produces a clear direction
- When resolving a design disagreement with evidence
- When updating an existing TDR with new context

## Workflow

1. **Identify the decision**: What design question was answered?
2. **Gather context**: What vocabulary terms, captures, and references informed it?
3. **Document alternatives**: What other directions were considered?
4. **Record the decision**: Write the TDR to `{{tdr_path}}`
5. **Link vocabulary**: Connect the TDR to relevant vocabulary terms

## Context Slots

| Slot | Default | Description |
|------|---------|-------------|
| `{{grimoire_path}}` | `grimoires/the-easel/` | Root path for this construct's project state |
| `{{tdr_path}}` | `{{grimoire_path}}/tdr/` | Directory containing Taste Decision Records |
| `{{vocabulary_path}}` | `{{grimoire_path}}/vocabulary/atlas.md` | Path to the vocabulary atlas |

## TDR Format

Each TDR follows the template at `contexts/tdr-template.md`:
- **Title**: Short descriptive name
- **Status**: Proposed | Accepted | Superseded | Deprecated
- **Context**: What prompted this decision
- **Decision**: The choice made, grounded in vocabulary terms
- **Alternatives**: Other options considered with vocabulary-grounded reasoning
- **Consequences**: Expected impact on future design decisions
- **References**: Links to captures, vocabulary entries, external references

## Operations

| Operation | Description |
|-----------|-------------|
| Create | New TDR from a design decision |
| Update | Add context or change status |
| List | Show all TDRs with status |
| Supersede | Mark old TDR as superseded, link to replacement |

## Outputs

- TDR file in `{{tdr_path}}/TDR-NNN-title.md`
- Updated vocabulary atlas (if new terms emerge from the decision)

## Acceptance Criteria

- TDR follows template structure
- Decision section references vocabulary terms
- Alternatives section explains why they were rejected
- Status is set correctly
- File naming follows `TDR-NNN-slug.md` convention
