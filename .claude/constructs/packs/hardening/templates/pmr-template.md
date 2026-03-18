---
type: pmr_template
schema_version: 1
id: "{{pmr_id}}"
title: "{{title}}"
severity: "{{severity}}"
status: "{{status}}"
detection_method: "{{detection_method}}"
created: "{{created}}"
updated: "{{updated}}"
---

# {{title}}

## Metadata

| Field | Value |
|-------|-------|
| **ID** | {{pmr_id}} |
| **Severity** | {{severity}} |
| **Status** | {{status}} |
| **Detection Method** | {{detection_method}} |
| **Time to Detection** | {{time_to_detection}} |
| **Time to Fix** | {{time_to_fix}} |
| **Financial Impact** | {{financial_impact}} |
| **Users Affected** | {{users_affected}} |

---

## Timeline

| Timestamp | Event | Reference |
|-----------|-------|-----------|
{{#timeline_entries}}
| {{timestamp}} | {{event}} | {{reference}} |
{{/timeline_entries}}

---

## Root Cause

### Classification

| Dimension | Value |
|-----------|-------|
| **Category** | {{root_cause_category}} |
| **Subcategory** | {{root_cause_subcategory}} |
| **Trigger** | {{root_cause_trigger}} |
| **Contributing Factors** | {{contributing_factors}} |

### Root Cause Taxonomy

Categories (pick one primary, zero or more contributing):

- `data-format-mismatch` — ID format, timestamp unit, encoding difference
- `type-coercion-failure` — implicit cast, BigInt parse, Number overflow
- `missing-validation` — no input check, no schema validation, no assertion
- `stale-assumption` — code comment, test fixture, or logic assumes old behavior
- `boundary-crossing` — data changes meaning when crossing API/frontend/contract boundary
- `infrastructure-dependency` — RPC expiry, indexer lag, service unavailability
- `missing-error-handling` — unhandled exception, silent failure, swallowed error
- `configuration-drift` — env var, chain ID, endpoint URL mismatch

### Narrative

{{root_cause_narrative}}

---

## Blast Radius

### Files Affected

| File | Bug | Impact | Severity |
|------|-----|--------|----------|
{{#affected_files}}
| `{{file_path}}` | {{bug_description}} | {{impact}} | {{severity}} |
{{/affected_files}}

### User/Financial Impact

{{user_financial_impact}}

### Data Flow Path

{{data_flow_description}}

```
{{data_flow_diagram}}
```

---

## Signal Gaps

For each gap: what signal was missing, what it would have caught, and how hard it is to add.

| # | Signal Gap | Would Have Caught | Effort |
|---|-----------|-------------------|--------|
{{#signal_gaps}}
| {{number}} | {{description}} | {{would_have_caught}} | {{effort}} |
{{/signal_gaps}}

---

## Fix Summary

{{#fix_commits}}
### Commit `{{hash}}` — {{title}}

{{description}}

{{/fix_commits}}

---

## Hardening Actions

Track defensive measures from proposal through verification.

| ID | Action | Status | Priority | Sprint | Verification |
|----|--------|--------|----------|--------|-------------|
{{#hardening_actions}}
| {{action_id}} | {{description}} | {{status}} | {{priority}} | {{sprint}} | {{verification_method}} |
{{/hardening_actions}}

**Hardening Action lifecycle**: `proposed` → `accepted` → `implemented` → `verified` → `regressed`

> **Status separation**: The Hardening Actions table tracks the _action lifecycle_ (is the defense built?).
> The Regression Checks table (below) tracks _ongoing verification_ (is the defense still working?).
> `/regression-check` updates the Regression Checks table. It only changes a Hardening Action
> status to `regressed` when a previously `verified` action's regression check transitions to `failing`.

---

## Provenance

### Commits

| Hash | Date | Description |
|------|------|-------------|
{{#provenance_commits}}
| `{{hash}}` | {{date}} | {{description}} |
{{/provenance_commits}}

### Issues & PRs

{{#provenance_issues}}
- **{{type}} #{{number}}**: {{title}}
{{/provenance_issues}}

### External References

{{#provenance_external}}
- {{source}}: {{description}}
{{/provenance_external}}

---

## Regression Checks

Automated checks that verify hardening holds over time.

| Check | Hardening Action | Method | Last Verified | Status |
|-------|-----------------|--------|---------------|--------|
{{#regression_checks}}
| {{check_id}} | {{action_id}} | {{method}} | {{last_verified}} | {{status}} |
{{/regression_checks}}

**Status values**: `passing` | `failing` | `untested` | `stale`

---

## Structural Insight

{{structural_insight}}
