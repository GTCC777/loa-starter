---
name: postmortem
description: "Create a structured Postmortem Record from an incident, mining git history and issues for timeline and blast radius."
user-invocable: true
allowed-tools: Read, Write, Glob, Grep, Bash, Edit
---

# Postmortem

Create a structured Postmortem Record (PMR) from an incident by reconstructing the timeline from git history, classifying the root cause, mapping the blast radius through every data consumer, and identifying signal gaps that allowed the failure to persist undetected. The PMR is a living artifact — its hardening actions table tracks defensive measures from proposal through verification.

---

## Triggers

```
/postmortem <incident-ref>
/postmortem <incident-ref> --github <issue-url>
```

**Examples:**
```bash
/postmortem "loan repayment broken after Envio migration"
/postmortem "activity timestamps show 56 years ago" --github https://github.com/0xHoneyJar/mibera-interface/issues/58
/postmortem "BigInt parse failure in repay-loan component"
```

**Arguments:**
- `<incident-ref>` — Free-text description, pasted issue body, or error stack trace (required)
- `--github <url>` — GitHub issue URL for enriched context via `gh` CLI (optional)

---

## When to Use

- After a bug is fixed and you need to understand what failed and why
- When a user reports a regression and you want structured analysis
- After a data source migration to audit what broke downstream
- When you need to generate hardening actions for sprint planning
- To create an auditable record of an incident for cross-session learning

---

## Workflow

### Step 1: Gather Context

Read the incident reference provided by the user. Parse it to identify:
- **Symptom description**: What the user or system reported
- **Affected feature**: Which product capability broke
- **Date range**: When the incident occurred (approximate)
- **Affected files**: If mentioned (stack traces, error messages)

Search local git log for related commits:
```bash
git log --oneline --since="<start_date>" --until="<end_date>" -- <affected_paths>
```

**GitHub enrichment (optional)**: If the user provides a GitHub issue URL via `--github`, use `Bash` with `gh` CLI:
```bash
gh issue view <number> --json title,body,comments,labels,createdAt
gh pr list --search "linked:<number>" --json number,title,mergedAt,files
```

This is strictly optional — the construct MUST produce a complete minimum-viable PMR from local git history + user-provided text alone. Record `provenance_sources: [git]` or `provenance_sources: [git, github]` in PMR metadata.

### Step 2: Reconstruct Timeline

Build a timestamped event sequence from all available sources:

1. **Introduction point**: The commit or PR that introduced the bug
2. **Detection event**: User report, monitoring alert, or test failure that surfaced it
3. **Fix commits**: All commits that resolved the issue
4. **Deploy timestamps**: When fixes reached production (if determinable)

Order all events chronologically. Each timeline entry includes:
- Timestamp (ISO 8601 or best available precision)
- Event description
- Reference (commit hash, issue number, PR number)

Calculate `time_to_detection` (introduction → detection) and `time_to_fix` (detection → last fix commit).

### Step 3: Classify Root Cause

Apply the root cause taxonomy to identify the primary category and contributing factors:

| Category | Description |
|----------|-------------|
| `data-format-mismatch` | ID format, timestamp unit, encoding difference |
| `type-coercion-failure` | Implicit cast, BigInt parse, Number overflow |
| `missing-validation` | No input check, no schema validation, no assertion |
| `stale-assumption` | Code comment, test fixture, or logic assumes old behavior |
| `boundary-crossing` | Data changes meaning when crossing API/frontend/contract boundary |
| `infrastructure-dependency` | RPC expiry, indexer lag, service unavailability |
| `missing-error-handling` | Unhandled exception, silent failure, swallowed error |
| `configuration-drift` | Env var, chain ID, endpoint URL mismatch |

Trace the data flow from the introduction point through every consumer. Write a narrative explaining the causation chain — how the root cause propagated from source to symptom.

### Step 4: Map Blast Radius

Use Grep/Glob to find all files that consumed the broken data path:

1. Identify the changed export, type, or data shape at the source
2. Find every import and usage site with Grep
3. For each consumer, classify impact severity:
   - **CRITICAL**: Financial loss, data corruption, contract call failure
   - **HIGH**: Core functionality broken, no workaround
   - **MEDIUM**: Functionality degraded, workaround exists
   - **LOW**: Cosmetic or minor UX issue

Quantify user/financial impact from issue reports, Discord threads, or on-chain evidence.

### Step 5: Identify Signal Gaps

For each stage of the data flow path, check whether a signal existed that could have caught the failure earlier:

| Signal Type | Check |
|-------------|-------|
| **Test** | Does a test cover this code path with realistic data? |
| **Type** | Does the type system enforce the data shape at this boundary? |
| **Error boundary** | Is there a try/catch, error boundary, or .catch() handler? |
| **Monitoring** | Is there Sentry, logging, or a health check? |
| **Comment** | Is there a code comment — is it accurate? |

For each missing signal, document:
- What signal was absent
- What it would have caught (be specific)
- Estimated effort to add (small / medium / large)

### Step 6: Generate Hardening Actions

For each signal gap, propose a concrete defensive measure:

- **Test spec**: What to test, with what fixtures, what assertion proves the gap closed
- **Type spec**: What branded type to introduce, where the conversion boundary is
- **Error boundary**: Where to place it, what to catch, how to surface the error
- **Checklist**: Reusable protocol for similar future operations
- **Monitor**: What runtime signal to add

Each hardening action gets:
- ID: `H{N}` (sequential within the PMR)
- Priority: CRITICAL / HIGH / MEDIUM / LOW
- Status: `proposed` (initial)
- Verification method: How to confirm the action was effective

### Step 7: Write PMR

Render the PMR using the template at `templates/pmr-template.md`. Write to:
```
grimoires/hardening/pmr/PMR-{YYYY}-{NNN}.md
```

Where `{NNN}` is the next sequential number (check existing PMRs in directory).

Emit event:
```bash
source .claude/scripts/lib/event-bus.sh
emit_event "forge.hardening.pmr_created" \
  '{
    "pmr_id": "PMR-{YYYY}-{NNN}",
    "title": "{title}",
    "severity": "{severity}",
    "root_cause_category": "{category}",
    "affected_file_count": {N},
    "signal_gap_count": {N},
    "hardening_action_count": {N},
    "pmr_path": "grimoires/hardening/pmr/PMR-{YYYY}-{NNN}.md"
  }' \
  "hardening/postmortem"
```

### Step 8: Invoke Correlating

If other PMRs exist in `grimoires/hardening/pmr/`, invoke the `correlating` inner process to detect cross-incident patterns. Append any correlations to the PMR's Structural Insight section.

### Step 9: Report Output

Display summary to user:

```
PMR Created: grimoires/hardening/pmr/PMR-{YYYY}-{NNN}.md

Incident: {title}
Severity: {severity}
Root Cause: {category} — {one-line narrative}
Time to Detection: {duration}
Time to Fix: {duration}

Blast Radius:
  - {N} files affected
  - {critical_count} CRITICAL / {high_count} HIGH / {medium_count} MEDIUM / {low_count} LOW

Signal Gaps: {N} identified
Hardening Actions: {N} proposed

Next Steps:
  - Generate defensive specs: /harden PMR-{YYYY}-{NNN}
  - Deep blast radius analysis: /blast-radius <commit>
  - Audit signal coverage: /signal-audit <scope>
```

---

## Counterfactuals — Timeline Reconstruction & Root Cause Classification

Postmortem analysis requires reconstructing what happened from incomplete evidence — git commits, issue comments, and user reports are fragments of a larger story. The failure modes center on mistaking fragments for the complete picture, or classifying the root cause at the wrong level of abstraction.

### Target (Correct Behavior)

The skill reconstructs the Envio migration incident (INC-2026-001) by tracing the full two-phase failure pattern. Phase 1: subsquid RPC expired on ~Feb 8, indexer lagged, loans became invisible in the UI, a user lost 24 NFTs to liquidation (Issue #58). Phase 2: the migration to Envio on Feb 14 (`26ee6fa3`) introduced three new regressions — compound loan IDs broke `BigInt()` parsing, timestamp units changed from milliseconds to seconds, and missing `chainId` parameters sent contract calls to the wrong chain.

The timeline includes both phases because the Phase 2 bugs were *caused by* the urgency to fix Phase 1. The root cause is classified as `boundary-crossing` (primary) with `data-format-mismatch` and `stale-assumption` as contributing factors — not merely "the migration had bugs." The blast radius maps 8 affected files across 3 distinct bug categories. The 7 signal gaps span the full data flow: no frontend component tests, unrealistic test fixtures, no integration tests from API to contract call, a misleading code comment, no runtime error monitoring, no live smoke test, and no branded types for loan IDs.

The PMR's provenance section cites specific commit hashes (`48a6ce01`, `72a84748`, `65efc2f9`) for the fixes, links to Issue #58 and PR #63, and references ADR-048 which predicted the "higher blast radius" that materialized. Every claim is grounded in a commit, timestamp, or user report.

### Near Miss — Incomplete Causation Chain (Seductively Close, But Wrong)

The seductively wrong approach: reconstructing only Phase 2 (the Envio regression) and omitting Phase 1 (the subsquid failure). This produces a technically accurate but causally incomplete postmortem.

A PMR that starts at "Feb 14: migration merged, introduced compound ID bug" misses the critical insight that the migration was driven by an infrastructure failure that had already caused user harm. The urgency of Phase 1 explains why Phase 2's test coverage was insufficient — the team was racing to fix a production incident, not executing a planned migration. Without Phase 1, the hardening actions focus narrowly on "test Envio IDs" rather than the structural lesson: data source migrations under time pressure require a consumer-tracing checklist regardless of urgency.

The near miss looks right because the Phase 2 timeline is technically complete — it has the introduction commit, the detection event (Feb 22), and the fix commits. All timestamps are accurate. The root cause classification (`data-format-mismatch`) is correct for the specific bug. But by treating the migration as an isolated event rather than a response to a prior failure, the postmortem loses the two-phase pattern that makes this incident structurally interesting and that `correlating` needs to detect fix-introduced regressions.

The detection signal: a PMR whose timeline starts at the introduction commit but doesn't investigate *why* that commit was made. Every introduction commit has a motivating context — feature request, bug fix, dependency update. If that context is another incident, the PMR must capture both phases.

**Physics of Error:** Concept Impermanence — treating the migration commit as the starting point of the incident rather than a consequence of a prior failure. The git log shows the "what" (merge commit) but not the "why" (infrastructure failure that forced the migration). The commit is a snapshot of an action, not the full causal chain.

### Category Error — Single-Point Blame (Fundamentally Wrong)

The fundamentally wrong approach: classifying the root cause as "developer error" or "insufficient code review" rather than tracing the systemic signal gaps.

A postmortem that concludes "the developer should have tested with realistic IDs" is correct in the narrowest sense but fundamentally misunderstands what a PMR is for. The question isn't "who should have caught this?" but "what *system* would have caught this automatically?" The Envio incident persisted for 8 days not because of one person's oversight but because of 7 independent signal gaps — any one of which, if closed, would have detected the regression.

This category error manifests as:
- Root cause: "developer didn't update the BigInt call" → should be `boundary-crossing`
- Hardening: "be more careful during migrations" → should be test specs, type specs, checklists
- Timeline: only the fix commits → should include the full causation chain
- Signal gaps: empty or generic ("add more tests") → should enumerate specific missing signals

The fundamental confusion is between blame (who) and causation (what system). Blame produces one-time vigilance ("I'll be more careful"). Causation produces compounding defenses ("the type system now prevents this class of error"). The entire construct exists because vigilance doesn't compound but systems do.

A postmortem that assigns blame is not just suboptimal — it actively damages the culture that makes incident analysis productive. Teams that fear blame stop reporting incidents, which means the construct never learns about failures, which means hardening never compounds. The PMR template deliberately has no "responsible party" field for this reason.

**Physics of Error:** Semantic Collapse — reducing a multi-dimensional failure (7 signal gaps across test, type, error handling, monitoring, and documentation dimensions) to a single dimension (individual responsibility). The collapse destroys the information that makes hardening actions specific and actionable.

---

## Validation

After PMR creation:
- [ ] PMR frontmatter is valid YAML with all required fields
- [ ] Timeline entries are chronologically ordered with timestamps
- [ ] Root cause category is from the taxonomy (not free-text only)
- [ ] Blast radius table has file paths, bug descriptions, impact, and severity
- [ ] Each signal gap has: what was missing, what it would have caught, effort estimate
- [ ] Each hardening action has: ID, description, status (`proposed`), priority, verification method
- [ ] Provenance section cites specific commit hashes, issue numbers, or PR numbers
- [ ] PMR file is written to `grimoires/hardening/pmr/PMR-{YYYY}-{NNN}.md`
- [ ] `provenance_sources` field reflects actual data sources used (`[git]` or `[git, github]`)
- [ ] Event `forge.hardening.pmr_created` emitted with correct data schema

---

## Error Handling

| Error | Resolution |
|-------|------------|
| No incident reference provided | Prompt for description, issue URL, or stack trace |
| Git log returns no relevant commits | Widen date range, ask user for commit hashes or file paths |
| GitHub issue URL provided but `gh` CLI not available | Proceed with git-only analysis, set `provenance_sources: [git]` |
| GitHub issue URL returns 404 or auth error | Warn user, proceed with git-only analysis |
| No existing PMRs in grimoire directory | Create `grimoires/hardening/pmr/` directory, start at PMR-{YYYY}-001 |
| Root cause doesn't fit taxonomy categories | Use closest match as primary, describe specific cause in narrative |
| Cannot determine financial/user impact | Note "impact unquantified" in blast radius section, proceed |

---

## Integration Points

- **Loa `/bug`**: Consumes fix commits and affected files from bug triage output
- **`/harden`**: PMR feeds into defensive measure specification generation
- **`/blast-radius`**: Can invoke for deeper impact analysis of specific commits
- **Sprint planning**: Hardening actions become sprint tasks via `/sprint-plan`
- **`correlating`**: Cross-references new PMR against historical incidents

---

## Related

- `/harden` — Generate defensive measure specs from a PMR
- `/triage` — Quick severity assessment (often precedes `/postmortem`)
- `/blast-radius` — Deep impact surface mapping for specific changes
- `/signal-audit` — Broader monitoring and test coverage audit
