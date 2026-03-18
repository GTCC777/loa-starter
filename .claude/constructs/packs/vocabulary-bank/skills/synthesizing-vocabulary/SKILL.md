---
name: synthesizing-vocabulary
description: "Extract vocabulary from existing product copy and organize into a tiered vocabulary bank."
user-invocable: true
aliases:
  - synthesize-vocabulary
  - synthesize-vocab
  - extract-vocabulary
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# Synthesize Vocabulary

Scan existing product copy. Extract terms. Classify into tiers. Generate a vocabulary bank.

## Trigger

```
/synthesize-vocabulary [target]
/extract-vocabulary [target]
```

Target can be:
- A directory (e.g., `app/` or `components/`)
- A specific feature area (e.g., "the vault UI" or "the chat system")
- No argument = scan the full application

## Prerequisites

Load these before running:

1. **Anchor-Space-Gravity**: `contexts/base/anchor-space-gravity.md` -- understand the philosophy
2. **Resolution rules**: `contexts/base/resolution-rules.md` -- understand the classification system
3. **Vocabulary bank template**: `templates/vocabulary-bank-template.md` -- output structure
4. **Existing bank** (if any): Check `grimoires/*/vocabulary-bank.md` for prior work

## Workflow

### Phase 1: Scan for User-Facing Copy

Scan the target for all user-facing strings. Prioritize:

```bash
# Find UI component files
find {target} -name "*.tsx" -o -name "*.jsx" | head -100

# Find copy in common patterns
# - JSX text: <Button>Deposit</Button>
# - Toast messages: toast.success("..."), toast.error("...")
# - Constants: const LABEL = "..."
# - Alt text: alt="..."
# - Placeholders: placeholder="..."
# - Error messages: message: "..."
# - Tooltip content: title="...", content="..."
```

Also scan:
- Error boundary components
- Loading/empty states
- Modal titles and descriptions
- Form labels and validation messages
- Navigation labels
- Metadata (OG tags, page titles)

### Phase 2: Extract Unique Terms

From all collected copy, extract unique terms that fall into categories:

**Candidate Tier 1 (Chain-Standard)**:
Terms that match common industry/platform vocabulary. In DeFi: deposit, withdraw, approve, wallet, connect, sign, confirm, fail. In social: send, reply, react, share, follow. In scoring: score, rank, tier, badge.

Test: Would a user from ANY similar product recognize this term immediately?

**Candidate Tier 2 (World Vocabulary)**:
Terms specific to this product's identity. Not industry-standard. Carry the product's archetype.

Test: Is this a word only YOUR product uses for this concept? Does it have both a world meaning and an operational meaning?

**Candidate Tier 3 (Reserved)**:
Terms from the product's worldbuilding, design docs, or lore that are NOT yet in the UI.

Test: Does this word exist in design docs, archetype files, or team vocabulary but NOT in production copy?

### Phase 3: Classify and Validate

For each extracted term, determine:

1. **Tier**: T1, T2, or T3
2. **Status** (T2 only): Established (used in 3+ contexts), Emerging (used in 1-2 contexts), Candidate (proposed but not yet deployed)
3. **Register**: Where does this term currently fire? (L1 only, L2 only, hybrid)
4. **Moment types**: Which moment types currently use this term?
5. **Gravity assessment**: Has this term accumulated meaning beyond its definition?

Apply the Anchor test: Is it grounded in something material?
Apply the Space test: Does it leave room for the user to build meaning?
Apply the Gravity test: Has it been used consistently enough to earn its place?

### Phase 4: Map UI Zones

For each significant UI area, classify:

| Zone | Moment type | Current register | Vocabulary used |
|------|------------|-----------------|-----------------|

This becomes the UI Zone Map in the vocabulary bank.

### Phase 5: Generate the Bank

Using the vocabulary bank template, generate the full bank:

1. Populate Tier 1, Tier 2, Tier 3 tables
2. Fill in moment type sections with actual UI zones
3. Create the UI Zone Map
4. Initialize the Community Vocabulary section (empty or seeded from Discord/community observations)
5. Initialize the Audit Log

Write to `grimoires/{product-slug}/vocabulary-bank.md`.

If no channel registry exists, generate one from the channel registry template at `grimoires/{product-slug}/channel-registry.md`.

### Phase 6: Report

Present findings:

```markdown
## Vocabulary Synthesis Report

**Product**: {name}
**Scanned**: {file_count} files, {copy_count} unique strings
**Date**: {date}

### Term Counts
- Tier 1 (Chain-Standard): {count}
- Tier 2 (Earned): {count} ({established} established, {emerging} emerging, {candidate} candidate)
- Tier 3 (Reserved): {count}

### Observations
- {Notable patterns, register inconsistencies, gravity assessments}

### Recommendations
- {Terms that should be promoted/demoted, register violations to fix, gaps in vocabulary}

### Files Generated
- `grimoires/{slug}/vocabulary-bank.md`
- `grimoires/{slug}/channel-registry.md` (if new)
```

## Counterfactuals

**Q: What if the product has no world vocabulary at all?**
A: That's valid. Some products are pure L1. The bank will have a full Tier 1 and empty Tier 2/3. The value is in documenting what terms are chain-standard so they're never accidentally renamed.

**Q: What if there's an existing archetype or design doc with vocabulary?**
A: Check for `archetype.md`, `taste.md`, design docs, or any worldbuilding files. Terms mentioned there but not in the UI are Tier 3 candidates.

**Q: Should I look at Discord/community channels for vocabulary?**
A: If accessible, yes. Community vocabulary goes in the Community Vocabulary section. But the primary source is the codebase.
