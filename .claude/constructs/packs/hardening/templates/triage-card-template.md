---
type: triage_card_template
schema_version: 1
---

# Triage Card: {{title}}

## Assessment

| Field | Value |
|-------|-------|
| **Severity** | {{severity}} |
| **Signal Source** | {{signal_source}} |
| **Assessed At** | {{assessed_at}} |
| **Assessor** | Hardening `/triage` |

---

## Signal Summary

{{signal_summary}}

### Original Report

> {{original_report}}

*Source: {{report_source}}*

---

## Affected Code Paths

| # | File | Function/Component | Confidence |
|---|------|--------------------|------------|
{{#affected_paths}}
| {{number}} | `{{file_path}}` | {{function}} | {{confidence}} |
{{/affected_paths}}

---

## Blast Radius Estimate

| Dimension | Estimate |
|-----------|----------|
| **Files Likely Affected** | {{affected_file_count}} |
| **Terminal Consumers** | {{terminal_consumer_count}} |
| **Financial Risk** | {{financial_risk}} |
| **Users at Risk** | {{users_at_risk}} |
| **Data Integrity Risk** | {{data_integrity_risk}} |

---

## Recent Changes

| Commit | Date | Author | Files Changed |
|--------|------|--------|---------------|
{{#recent_commits}}
| `{{hash}}` | {{date}} | {{author}} | {{files_changed}} |
{{/recent_commits}}

---

## Severity Justification

{{severity_justification}}

---

## Recommended Action

| Action | Command | Rationale |
|--------|---------|-----------|
| {{recommended_action}} | `{{recommended_command}}` | {{rationale}} |

**Decision options**:
- `/bug` — Fix immediately (CRITICAL/HIGH severity)
- `/postmortem` — Deep analysis required (complex root cause)
- `/blast-radius` — Map full impact before deciding (unclear scope)
- Monitor — Low severity, no immediate action needed

---

## Evidence

{{#evidence_items}}
- **{{type}}**: {{description}} (`{{reference}}`)
{{/evidence_items}}
