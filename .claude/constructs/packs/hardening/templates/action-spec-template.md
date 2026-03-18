---
type: action_spec_template
schema_version: 1
action_id: "{{action_id}}"
pmr_id: "{{pmr_id}}"
action_type: "{{action_type}}"
priority: "{{priority}}"
status: "{{status}}"
created: "{{created}}"
---

# {{action_id}}: {{title}}

## Overview

| Field | Value |
|-------|-------|
| **Action ID** | {{action_id}} |
| **PMR Reference** | {{pmr_id}} |
| **Action Type** | {{action_type}} |
| **Priority** | {{priority}} |
| **Status** | {{status}} |
| **Signal Gap** | #{{signal_gap_number}} |

**Action types**: `test-spec` | `type-spec` | `error-boundary` | `checklist` | `monitor`

---

## Description

{{description}}

---

## Implementation Spec

### What to Build

{{implementation_what}}

### Where to Build It

| File | Action |
|------|--------|
{{#target_files}}
| `{{file_path}}` | {{action}} |
{{/target_files}}

### Constraints

{{#constraints}}
- {{constraint}}
{{/constraints}}

---

## Verification Method

| Method | Description |
|--------|-------------|
| **Type** | {{verification_type}} |
| **Check** | {{verification_check}} |
| **Automated** | {{verification_automated}} |

**Verification types**: `test-exists` | `type-check` | `grep-pattern` | `ci-pass` | `manual`

---

## Acceptance Criteria

{{#acceptance_criteria}}
- [ ] {{criterion}}
{{/acceptance_criteria}}

---

## Sprint Assignment

| Field | Value |
|-------|-------|
| **Target Sprint** | {{target_sprint}} |
| **Effort Estimate** | {{effort_estimate}} |
| **Dependencies** | {{dependencies}} |

---

## Provenance

- **Signal Gap**: {{signal_gap_description}}
- **Root Cause**: {{root_cause_category}} — {{root_cause_trigger}}
- **PMR**: [{{pmr_id}}](../pmr/{{pmr_id}}.md)
