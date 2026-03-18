# Construct Hardening — Validation Report

> Validated: 2026-02-22
> Validator: construct-hardening team (validator agent)
> Construct version: 0.1.0

## Summary

| Metric | Value |
|--------|-------|
| **Total files** | 36 |
| **Checks performed** | 42 |
| **Checks passed** | 41 |
| **Issues found** | 1 |
| **Issues fixed** | 1 |
| **Status** | **PASS** |

---

## 1. construct.yaml

| Check | Status | Notes |
|-------|--------|-------|
| schema_version >= 3 | PASS | `3` |
| slug matches `^[a-z0-9][a-z0-9-]*[a-z0-9]$` | PASS | `hardening` |
| version is valid semver | PASS | `0.1.0` |
| description 10-500 chars | PASS | 147 chars |
| skill slugs match `^[a-z][a-z0-9-]+$` | PASS | 7 skills: postmortem, triage, blast-radius, harden, regression-check, signal-audit, correlating |
| events follow `forge.hardening.*` naming | PASS | 6 emitted events, all `forge.hardening.*` |
| consumes events use `event` field (schema) | **FIXED** | Was using `type` instead of `event` — fixed in place |

### Fix Applied

`construct.yaml` consumes entries used `type` field but the `construct.schema.json` requires `event` as the field name (per `required: ["event"]`). Changed both entries from `type:` to `event:`.

---

## 2. identity/persona.yaml

| Check | Status | Notes |
|-------|--------|-------|
| cognitiveFrame.archetype | PASS | `Sentinel` |
| cognitiveFrame.disposition | PASS | Present, multi-line |
| cognitiveFrame.thinking_style | PASS | Present, multi-line |
| cognitiveFrame.decision_making | PASS | Present, multi-line |
| voice.tone | PASS | Present |
| voice.register | PASS | Present, multi-line |

---

## 3. identity/expertise.yaml

| Check | Status | Notes |
|-------|--------|-------|
| domains array exists | PASS | 5 domains |
| Each domain has name + depth (1-5) | PASS | Depths: 5, 4, 4, 4, 3 |
| Boundaries phrased as "Does NOT..." | PASS | All 8 boundaries use "Does NOT" phrasing |

---

## 4. CLAUDE.md

| Check | Status | Notes |
|-------|--------|-------|
| "Who I Am" section | PASS | Lines 7-11 |
| "What I Know" section | PASS | Lines 13-19 |
| "Available Skills" section | PASS | Lines 21-32, table with 6 commands |
| "Workflow" section | PASS | Lines 34-41, 5-step pipeline |
| "Boundaries" section | PASS | Lines 43-51, 7 explicit boundaries |

---

## 5. Skill index.yaml files (6 of 7 skills — correlating is inner process)

| Skill | name | slug | version | description | entry | triggers | allowed-tools | capabilities | Status |
|-------|------|------|---------|-------------|-------|----------|---------------|-------------|--------|
| postmortem | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS (opus/safe/large/false) | PASS |
| triage | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS (sonnet/safe/medium/true) | PASS |
| blast-radius | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS (sonnet/safe/large/false) | PASS |
| harden | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS (opus/moderate/large/false) | PASS |
| regression-check | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS (sonnet/safe/medium/true) | PASS |
| signal-audit | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS (sonnet/safe/large/true) | PASS |

---

## 6. SKILL.md files (7 total)

### User-facing skills (6)

| Skill | Frontmatter | Triggers | When to Use | Workflow | Counterfactuals | Validation | Error Handling | Integration Points | Related |
|-------|------------|----------|-------------|----------|-----------------|------------|---------------|-------------------|---------|
| postmortem | PASS | PASS | PASS | PASS (9 steps) | PASS (3 levels) | PASS | PASS | PASS | PASS |
| triage | PASS | PASS | PASS | PASS (5 steps) | PASS (3 levels) | PASS | PASS | PASS | PASS |
| blast-radius | PASS | PASS | PASS | PASS (5 steps) | PASS (3 levels) | PASS | PASS | PASS | PASS |
| harden | PASS | PASS | PASS | PASS (7 steps) | PASS (3 levels) | PASS | PASS | PASS | PASS |
| regression-check | PASS | PASS | PASS | PASS (5 steps) | PASS (3 levels) | PASS | PASS | PASS | PASS |
| signal-audit | PASS | PASS | PASS | PASS (7 steps) | PASS (3 levels) | PASS | PASS | PASS | PASS |

### Inner process (1)

| Skill | Frontmatter | Input Contract | Output Contract | Algorithm | Validation Rules |
|-------|------------|----------------|-----------------|-----------|-----------------|
| correlating | PASS (`user-invocable: false`, `allowed-tools: []`) | PASS | PASS | PASS (4 algorithms) | PASS (6 rules) |

---

## 7. Templates

| Template | Mustache `{{double_brace}}` syntax | Status |
|----------|------------------------------------|--------|
| pmr-template.md | PASS | 30+ variables, section helpers |
| action-spec-template.md | PASS | 20+ variables |
| blast-radius-template.md | PASS | 20+ variables, section helpers |
| signal-audit-template.md | PASS | 25+ variables, section helpers |
| triage-card-template.md | PASS | 20+ variables |
| grimoire-state-template.yaml | PASS | Static initial state (no variables needed) |
| grimoire-pipeline-template.md | PASS | Static pipeline docs (no variables needed) |

---

## 8. scripts/install.sh

| Check | Status | Notes |
|-------|--------|-------|
| Executable bit set | PASS | `-rwxr-xr-x` |
| Idempotent | PASS | Guards: `if [[ ! -d "$dir" ]]` and `if [[ ! -f "$STATE_FILE" ]]` |
| Creates all 6 directories | PASS | pmr, actions, triage, signals, correlations, checklists |
| Initializes state.yaml | PASS | From template, with overwrite guard |
| Initializes PIPELINE.md | PASS | From template, with overwrite guard |

---

## 9. File Count

| Expected (architecture doc) | Actual | Delta | Notes |
|-----------------------------|--------|-------|-------|
| 34 | 36 | +2 | Extra files: `README.md`, `WORKFLOW.md` — useful documentation additions, not a violation |

### Full manifest (36 files)

```
.github/CODEOWNERS
.gitignore
.license.json
CLAUDE.md
README.md                              (+extra)
WORKFLOW.md                            (+extra)
construct.yaml
contexts/overlays/project.json.example
identity/expertise.yaml
identity/persona.yaml
schemas/construct.schema.json
schemas/expertise.schema.json
schemas/persona.schema.json
schemas/pmr.schema.json
scripts/install.sh
scripts/validate-skills.sh
skills/blast-radius/SKILL.md
skills/blast-radius/index.yaml
skills/correlating/SKILL.md
skills/harden/SKILL.md
skills/harden/index.yaml
skills/postmortem/SKILL.md
skills/postmortem/index.yaml
skills/regression-check/SKILL.md
skills/regression-check/index.yaml
skills/signal-audit/SKILL.md
skills/signal-audit/index.yaml
skills/triage/SKILL.md
skills/triage/index.yaml
templates/action-spec-template.md
templates/blast-radius-template.md
templates/grimoire-pipeline-template.md
templates/grimoire-state-template.yaml
templates/pmr-template.md
templates/signal-audit-template.md
templates/triage-card-template.md
```

---

## 10. Additional Quality Checks

| Check | Status | Notes |
|-------|--------|-------|
| validate-skills.sh executable | PASS | `-rwxr-xr-x` |
| All schemas valid JSON | PASS | 4 schema files parsed successfully |
| PMR schema has all required frontmatter fields | PASS | 9 required: type, schema_version, id, title, severity, status, detection_method, created, updated |
| Counterfactuals follow 3-tier structure | PASS | All 6 user-facing skills: Target → Near Miss → Category Error |
| Counterfactuals include "Physics of Error" | PASS | All 12 counterfactual error modes have Physics of Error callouts |
| Cross-skill integration references consistent | PASS | All integration points reference existing skills |

---

## Conclusion

The Hardening construct passes validation with **1 issue found and fixed** (construct.yaml consumes field name). All 42 checks pass after the fix. The construct is structurally complete, schema-compliant, and ready for the reference PMR.
