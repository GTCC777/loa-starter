---
type: blast_radius_template
schema_version: 1
---

# Blast Radius: {{scope}}

## Summary

| Dimension | Value |
|-----------|-------|
| **Scope** | {{scope}} |
| **Scope Type** | {{scope_type}} |
| **Analyzed At** | {{analyzed_at}} |
| **Total Files Affected** | {{total_affected_files}} |
| **Terminal Consumers** | {{terminal_consumer_count}} |

### Severity Distribution

| Severity | Count |
|----------|-------|
| CRITICAL | {{severity_critical}} |
| HIGH | {{severity_high}} |
| MEDIUM | {{severity_medium}} |
| LOW | {{severity_low}} |

---

## Affected Files

| # | File | Impact Type | Severity | Operations on Changed Data |
|---|------|-------------|----------|---------------------------|
{{#affected_files}}
| {{number}} | `{{file_path}}` | {{impact_type}} | {{severity}} | {{operations}} |
{{/affected_files}}

**Impact types**: `direct-consumer` | `transitive-consumer` | `terminal-consumer` | `type-dependent` | `display-only`

---

## Terminal Consumers

Points where changed data reaches users or external systems.

| # | File | Consumer Type | What Reaches User/External |
|---|------|---------------|---------------------------|
{{#terminal_consumers}}
| {{number}} | `{{file_path}}` | {{consumer_type}} | {{description}} |
{{/terminal_consumers}}

**Consumer types**: `ui-display` | `contract-call` | `api-request` | `database-write` | `log-output`

---

## Data Flow

{{data_flow_description}}

```
{{data_flow_diagram}}
```

---

## Change Surface

### Changed Exports/Types

| Export | File | Type | Consumers |
|--------|------|------|-----------|
{{#changed_exports}}
| `{{name}}` | `{{file_path}}` | {{type}} | {{consumer_count}} |
{{/changed_exports}}

### Dependency Graph

```
{{dependency_graph}}
```

---

## Type-Sensitive Operations

Operations on changed data that involve type-sensitive logic (BigInt, Date, JSON.parse, contract encoding).

| File | Operation | Risk | Notes |
|------|-----------|------|-------|
{{#type_sensitive_ops}}
| `{{file_path}}` | {{operation}} | {{risk}} | {{notes}} |
{{/type_sensitive_ops}}

---

## PMR Cross-Reference

{{#has_pmr_overlap}}
Historical PMRs with overlapping blast radius:

| PMR | Overlap Files | Root Cause | Status |
|-----|---------------|------------|--------|
{{#pmr_overlaps}}
| {{pmr_id}} | {{overlap_count}} files | {{root_cause}} | {{status}} |
{{/pmr_overlaps}}
{{/has_pmr_overlap}}
{{#no_pmr_overlap}}
No historical PMRs overlap with this blast radius.
{{/no_pmr_overlap}}
