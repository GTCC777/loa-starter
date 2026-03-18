---
type: signal_audit_template
schema_version: 1
---

# Signal Audit: {{scope}}

## Summary

| Field | Value |
|-------|-------|
| **Scope** | {{scope}} |
| **Audited At** | {{audited_at}} |
| **Files Audited** | {{files_audited}} |
| **Gaps Found** | {{gaps_found}} |
| **PMR Overlaps** | {{pmr_overlap_count}} |

---

## Coverage Matrix

| File | Tests | Types | Error Handling | Monitoring | Overall |
|------|-------|-------|----------------|------------|---------|
{{#coverage_rows}}
| `{{file_path}}` | {{test_coverage}} | {{type_coverage}} | {{error_coverage}} | {{monitor_coverage}} | {{overall}} |
{{/coverage_rows}}

**Coverage levels**: `strong` | `partial` | `weak` | `none`

---

## Test Coverage

### By Type

| Test Type | Files Covered | Files Missing | Coverage |
|-----------|---------------|---------------|----------|
| Unit | {{unit_covered}} | {{unit_missing}} | {{unit_pct}} |
| Integration | {{integration_covered}} | {{integration_missing}} | {{integration_pct}} |
| E2E | {{e2e_covered}} | {{e2e_missing}} | {{e2e_pct}} |
| Smoke | {{smoke_covered}} | {{smoke_missing}} | {{smoke_pct}} |

### Fixture Realism

| Test File | Uses Production Data Shapes | Notes |
|-----------|:---------------------------:|-------|
{{#fixture_realism}}
| `{{test_file}}` | {{realistic}} | {{notes}} |
{{/fixture_realism}}

---

## Type Coverage

### Loose Types Found

| File | Line | Pattern | Risk |
|------|------|---------|------|
{{#loose_types}}
| `{{file_path}}` | {{line}} | `{{pattern}}` | {{risk}} |
{{/loose_types}}

**Patterns**: `any` | `unknown` | `untyped-param` | `as-cast` | `implicit-coercion`

### Branded Types at Boundaries

| Boundary | Has Branded Type | Type Guard | Notes |
|----------|:----------------:|:----------:|-------|
{{#boundary_types}}
| {{boundary}} | {{has_branded}} | {{has_guard}} | {{notes}} |
{{/boundary_types}}

---

## Error Handling Coverage

| File | Try/Catch | Error Boundary | Promise Catch | Unhandled Risks |
|------|:---------:|:--------------:|:-------------:|-----------------|
{{#error_handling}}
| `{{file_path}}` | {{try_catch}} | {{error_boundary}} | {{promise_catch}} | {{unhandled_risks}} |
{{/error_handling}}

---

## Monitoring Coverage

| Area | Sentry | Health Check | CI Workflow | Runtime Capture |
|------|:------:|:------------:|:-----------:|:---------------:|
{{#monitoring}}
| {{area}} | {{sentry}} | {{health_check}} | {{ci_workflow}} | {{runtime_capture}} |
{{/monitoring}}

---

## Historical PMR Overlap

{{#has_pmr_overlap}}
Areas where past incidents occurred within this scope:

| PMR | Blast Radius Overlap | Root Cause | Signal Coverage Now |
|-----|---------------------|------------|---------------------|
{{#pmr_overlaps}}
| {{pmr_id}} | {{overlap_files}} | {{root_cause}} | {{current_coverage}} |
{{/pmr_overlaps}}
{{/has_pmr_overlap}}
{{#no_pmr_overlap}}
No historical PMRs overlap with this audit scope.
{{/no_pmr_overlap}}

---

## Gap Summary

| # | Gap Type | Description | Affected Files | Recommended Action |
|---|----------|-------------|----------------|-------------------|
{{#gaps}}
| {{number}} | {{type}} | {{description}} | {{affected_count}} | {{recommendation}} |
{{/gaps}}

**Gap types**: `missing-test` | `loose-type` | `unhandled-error` | `no-monitoring` | `stale-fixture` | `missing-boundary-type`
