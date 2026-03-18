---
name: auditing-vocabulary
description: "Audit copy against the vocabulary bank. Flags register violations, cold-deployed terms, tonal gaps, and anthropomorphism."
user-invocable: true
aliases:
  - audit-vocabulary
  - audit-vocab
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# Audit Vocabulary

Scan copy against the installed vocabulary bank. Find violations. Report them.

## Trigger

```
/audit-vocabulary [target]
/audit-vocab [target]
```

Target can be:
- A file path (e.g., `app/components/toast.tsx`)
- A directory (e.g., `app/`)
- A pasted block of copy (inline audit)
- No argument = audit all UI-facing copy

## Prerequisites

Load these before running:

1. **Vocabulary bank**: `grimoires/*/vocabulary-bank.md` (or the product-specific bank)
2. **Channel registry**: `grimoires/*/channel-registry.md` (optional, defaults to base rules)
3. **Resolution rules**: Load from construct contexts (`contexts/base/resolution-rules.md`)
4. **Anchor-Space-Gravity**: Load from construct contexts (`contexts/base/anchor-space-gravity.md`)

If no vocabulary bank exists, halt and suggest running `/synthesize-vocabulary` first.

## Workflow

### Phase 1: Load the Vocabulary Bank

```bash
# Find the vocabulary bank
VOCAB_BANK=$(find grimoires -name "vocabulary-bank.md" -not -path "*/templates/*" | head -1)
CHANNEL_REG=$(find grimoires -name "channel-registry.md" | head -1)
```

Read the vocabulary bank. Extract:
- All Tier 1 terms (chain-standard)
- All Tier 2 terms (earned) with their status (Established / Emerging / Candidate)
- All Tier 3 terms (reserved -- should NOT appear in production copy)
- Community vocabulary entries

### Phase 2: Identify Target Copy

If target is a file/directory, scan for user-facing strings:
- JSX text content
- Toast messages
- Error messages
- Button labels
- Tooltip content
- Alt text
- Placeholder text
- ARIA labels

If target is inline copy (pasted text), audit directly.

### Phase 3: Run Violation Checks

Check each piece of copy against these violation types:

#### V1: Cold-Deployed Terms (Severity: HIGH)
A Tier 3 (reserved) term appearing in production copy. The word hasn't been earned through discovery-moment exposure.

**Detection**: Grep for all Tier 3 terms in the target.

#### V2: Register Violation (Severity: HIGH)
Layer 2 vocabulary in a confirmation or error moment where it hasn't been established.

**Detection**: Classify each copy instance by moment type (confirmation/error/action/discovery/idle). Check if L2 terms used in confirmation/error are marked "Established" in the vocabulary bank.

#### V3: Anthropomorphism (Severity: MEDIUM)
The system is given feelings, wants, or personality. Systems activate and deactivate; they don't think or feel.

**Detection**: Look for feeling verbs (appreciates, thanks, loves, wants, hopes, believes, thinks) applied to system/product nouns.

#### V4: Tonal Gap (Severity: MEDIUM)
Bug/error messaging uses a significantly colder register than feature/success messaging in the same product surface.

**Detection**: Compare the vocabulary ceiling of error-moment copy against discovery-moment copy in the same component tree.

#### V5: Chekhov's Gun (Severity: LOW)
An evocative word used in a confirmation that could mean something contradictory in another operational context.

**Detection**: Check if any L2 term in a confirmation has a potential conflicting meaning.

#### V6: Bazaar Baseline Collision (Severity: LOW)
A Tier 2 world term replacing a Tier 1 chain-standard term where the T1 term would be clearer.

**Detection**: Check if any T2 term is used where a T1 synonym exists and would be more immediately understood.

#### V7: Space Violation (Severity: LOW)
Copy that fills every gap between anchors -- over-explained, nothing left for the user to build.

**Detection**: Count qualifiers, adverbs, and filler words relative to anchor words. Flag copy where the ratio exceeds 2:1.

### Phase 4: Report

Generate a report sorted by severity:

```markdown
## Vocabulary Audit Report
**Target**: {target}
**Date**: {date}
**Vocabulary Bank**: {bank_path}

### Summary
- HIGH: {count} violations
- MEDIUM: {count} violations
- LOW: {count} violations

### Violations

#### HIGH
| # | Type | Location | Copy | Violation | Suggested Fix |
|---|------|----------|------|-----------|---------------|

#### MEDIUM
...

#### LOW
...

### Passing
{List of audit checks that passed cleanly}
```

### Phase 5: Update Audit Log

Append results to the Audit Log section of the vocabulary bank:

```markdown
| {date} | {summary} | {max_severity} | {resolution_status} |
```

## Counterfactuals

**Q: What if there's no vocabulary bank?**
A: Halt. Suggest `/synthesize-vocabulary` to bootstrap one from existing copy. Auditing without a bank is meaningless.

**Q: What about copy that isn't in the codebase (Discord messages, tweets)?**
A: Accept inline copy via the pasted-text path. The same rules apply.

**Q: What about copy in languages other than English?**
A: The vocabulary bank should have per-language term entries if the product is localized. Audit each language against its own bank.
