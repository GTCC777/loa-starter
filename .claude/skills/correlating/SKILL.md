---
name: correlating
description: "Detect patterns across multiple PMRs — recurring root causes, repeat blast radius files, persistent signal gaps."
user-invocable: false
allowed-tools: []
---

# Correlating — Cross-Incident Pattern Detection

An inner process invoked by `/postmortem` and `/regression-check` to detect patterns across multiple Postmortem Records. Runs as a prompt-only subagent — no tool access, pure analytical reasoning over PMR metadata provided by the parent skill.

---

## Input Contract

The parent skill provides an array of PMR metadata objects:

```yaml
pmrs:
  - id: "PMR-2026-001"
    title: "Envio Migration Regression"
    severity: "HIGH"
    status: "resolved"
    root_cause_category: "boundary-crossing"
    contributing_factors:
      - "data-format-mismatch"
      - "stale-assumption"
    detection_method: "user-report"
    time_to_detection: "8 days"
    affected_files:
      - path: "components/loan/repay-loan.tsx"
        impact: "CRITICAL"
      - path: "components/activity/Activity.tsx"
        impact: "MEDIUM"
      - path: "components/marketplace/expired-loans-counter.tsx"
        impact: "CRITICAL"
      - path: "components/loan/loan-parameter-form.tsx"
        impact: "HIGH"
      - path: "components/loan/receive-loan.tsx"
        impact: "HIGH"
      - path: "components/loan/redemption-dialog.tsx"
        impact: "HIGH"
      - path: "components/marketplace/purchase-dialog.tsx"
        impact: "HIGH"
      - path: "components/backing-page.tsx"
        impact: "HIGH"
    signal_gaps:
      - description: "No frontend component tests for contract interaction"
        effort: "large"
      - description: "Test fixtures used unrealistic IDs"
        effort: "small"
      - description: "No integration test: API → frontend → contract"
        effort: "large"
      - description: "Misleading code comment"
        effort: "small"
      - description: "No runtime error monitoring"
        effort: "medium"
      - description: "No smoke test against live data"
        effort: "medium"
      - description: "Type system gap — no branded ID types"
        effort: "medium"
    hardening_actions:
      - id: "H1"
        type: "test-spec"
        status: "proposed"
        priority: "CRITICAL"
      - id: "H2"
        type: "type-spec"
        status: "proposed"
        priority: "HIGH"
      - id: "H3"
        type: "error-boundary"
        status: "proposed"
        priority: "HIGH"
      - id: "H4"
        type: "checklist"
        status: "proposed"
        priority: "HIGH"
      - id: "H5"
        type: "test-spec"
        status: "proposed"
        priority: "MEDIUM"
      - id: "H6"
        type: "monitor"
        status: "proposed"
        priority: "MEDIUM"
      - id: "H7"
        type: "checklist"
        status: "proposed"
        priority: "LOW"
    fix_commits:
      - hash: "48a6ce01"
        date: "2026-02-22"
      - hash: "72a84748"
        date: "2026-02-22"
      - hash: "65efc2f9"
        date: "2026-02-22"
    introduction_commits:
      - hash: "26ee6fa3"
        date: "2026-02-14"
```

Minimum input: 2 or more PMR metadata objects. With a single PMR, the process returns "insufficient data for correlation — minimum 2 PMRs required."

---

## Output Contract

A correlation report in markdown format with four sections:

```yaml
correlation_report:
  generated_at: "{ISO 8601 timestamp}"
  pmr_count: {N}

  hot_spots:
    - file: "{path}"
      pmr_count: {N}
      pmr_ids: ["{id1}", "{id2}"]
      max_impact: "{CRITICAL|HIGH|MEDIUM|LOW}"
      pattern: "{description of recurring vulnerability}"

  root_cause_trends:
    - category: "{taxonomy category}"
      count: {N}
      percentage: "{N}%"
      pmr_ids: ["{id1}", "{id2}"]
      pattern: "{description of why this category recurs}"

  persistent_gaps:
    - description: "{signal gap description}"
      first_identified: "{pmr_id}"
      still_open_in: ["{pmr_id1}", "{pmr_id2}"]
      action_status: "{proposed|accepted — never implemented}"
      risk: "{description of what remains vulnerable}"

  fix_introduced_patterns:
    - trigger_pmr: "{pmr_id_A}"
      caused_pmr: "{pmr_id_B}"
      fix_commit: "{hash}"
      introduction_commit: "{hash}"
      pattern: "{description — e.g., fix for Phase 1 introduced Phase 2}"
```

---

## Algorithm

### 1. Build File Frequency Map

For each file across all PMR blast radii, count how many PMRs include it:

```
file_frequency = {}
for pmr in pmrs:
  for file in pmr.affected_files:
    file_frequency[file.path] += 1
    file_frequency[file.path].pmr_ids.add(pmr.id)
    file_frequency[file.path].max_impact = max(current, file.impact)
```

**Hot spots** = files appearing in 2+ PMR blast radii. These are structurally fragile — they break across unrelated incidents, suggesting they sit at a high-traffic data boundary with insufficient defenses.

### 2. Build Root Cause Category Histogram

Count root cause categories across all PMRs (primary + contributing):

```
category_counts = {}
for pmr in pmrs:
  category_counts[pmr.root_cause_category] += 1  # primary
  for factor in pmr.contributing_factors:
    category_counts[factor] += 0.5  # contributing factors count half
```

Sort by frequency. The most common category reveals the systemic vulnerability class — e.g., if 60% of incidents are `boundary-crossing`, the codebase has weak data boundaries.

### 3. Cross-Reference Hardening Actions

For each signal gap across all PMRs, check if a hardening action was proposed but never implemented:

```
for pmr in pmrs:
  for action in pmr.hardening_actions:
    if action.status in ['proposed', 'accepted']:
      # This action was identified but never built
      persistent_gaps.add({
        description: find_matching_gap(action, pmr.signal_gaps),
        first_identified: pmr.id,
        action_status: action.status
      })
```

**Persistent gaps** = signal gaps identified in past PMRs that remain unaddressed. These represent known vulnerabilities that the team has acknowledged but not fixed — they are the highest-priority items for sprint planning.

### 4. Detect Temporal Chains (Fix-Introduced Patterns)

Check if any PMR's fix commits appear in another PMR's introduction timeline:

```
for pmr_a in pmrs:
  for fix_commit in pmr_a.fix_commits:
    for pmr_b in pmrs:
      if fix_commit.hash in [c.hash for c in pmr_b.introduction_commits]:
        fix_introduced_patterns.add({
          trigger_pmr: pmr_a.id,
          caused_pmr: pmr_b.id,
          fix_commit: fix_commit.hash,
          introduction_commit: fix_commit.hash
        })
```

**Fix-introduced patterns** = the two-phase failure pattern from the Envio incident. The fix for PMR-A (subsquid failure) was the migration commit that introduced PMR-B (Envio regression). Detecting this pattern reveals when urgency to fix one incident introduces another — a signal that the fix process needs a consumer-tracing step.

---

## Validation Rules

The parent orchestrator checks the output against these rules:

1. **Hot spots must cite 2+ PMR IDs** — a file in only one PMR is not a hot spot
2. **Root cause percentages must sum to 100%** (with rounding tolerance of ±1%)
3. **Persistent gaps must reference a real hardening action ID** from the source PMR
4. **Fix-introduced patterns must have matching commit hashes** — the fix commit in PMR-A must exactly match an introduction commit in PMR-B
5. **No fabricated PMR IDs** — every PMR ID in the output must appear in the input
6. **Minimum output**: if 2+ PMRs provided, at least one section must have content (hot spots, trends, gaps, or patterns)

---

## Output Example

```markdown
# Cross-Incident Correlation Report

Generated: 2026-02-22T16:00:00Z
PMRs Analyzed: 2

## Hot Spots

| File | PMR Count | PMR IDs | Max Impact | Pattern |
|------|-----------|---------|------------|---------|
| `components/loan/repay-loan.tsx` | 2 | PMR-2026-001, PMR-2026-002 | CRITICAL | Sits at API→contract boundary — format-sensitive BigInt conversion |
| `components/marketplace/purchase-dialog.tsx` | 2 | PMR-2026-001, PMR-2026-002 | HIGH | Shared contract interaction pattern with repay-loan |

## Root Cause Trends

| Category | Count | % | PMR IDs | Pattern |
|----------|-------|---|---------|---------|
| `boundary-crossing` | 1.0 | 40% | PMR-2026-001 | Data format changes at API boundaries propagate undetected to contract calls |
| `data-format-mismatch` | 0.5 | 20% | PMR-2026-001 | ID and timestamp formats differ between indexers |
| `stale-assumption` | 0.5 | 20% | PMR-2026-001 | Code comments and logic assume old data source behavior |
| `infrastructure-dependency` | 0.5 | 20% | PMR-2026-001 | RPC expiry without monitoring or failover |

## Persistent Gaps

| Gap | First Identified | Status | Risk |
|-----|-----------------|--------|------|
| No frontend integration tests for contract calls | PMR-2026-001 | H1: proposed | Contract call path untested — same class of bug can recur with any data format change |
| No branded types for entity IDs | PMR-2026-001 | H2: proposed | Raw strings flow from API to BigInt() without type enforcement |

## Fix-Introduced Patterns

| Trigger PMR | Caused PMR | Pattern |
|-------------|-----------|---------|
| (subsquid failure) | PMR-2026-001 | Infrastructure fix (Envio migration) introduced 3 new regressions because consumer layer was not traced during migration |

## Structural Insight

The correlation reveals a single systemic vulnerability: **the API→frontend→contract data flow path has no type enforcement or integration testing**. Every incident in this correlation set involves data format changes propagating undetected through this path. The hot spot files (`repay-loan.tsx`, `purchase-dialog.tsx`) sit at the terminal boundary where format errors become contract call failures.

Recommended systemic fix: branded types at the API response boundary + integration tests at the contract call boundary. These two defenses cover the entire vulnerable path.
```
