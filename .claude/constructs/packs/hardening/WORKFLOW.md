# Hardening — Workflow Guide

> v0.1.0 | Incident analysis and defensive measure specification

## Quick Start

> Get value in 30 seconds.

1. Triage an incident: `/triage "user reports loans page is broken"`
2. Review: check stdout for severity and recommended action
3. Deep analysis: `/postmortem "Envio migration broke loan repayment"`

## Prerequisites

| Requirement | Check | Required For |
|-------------|-------|--------------|
| Loa Framework | `.claude/` directory exists | All skills |
| Git repository | `git status` | Timeline reconstruction |
| `gh` CLI (optional) | `gh --version` | GitHub issue/PR enrichment |
| Observer construct (optional) | `construct-observer/` exists | Auto-triage from user feedback |

## Skill Reference

| Command | What It Does | When to Use |
|---------|-------------|-------------|
| `/triage <signal>` | Quick severity assessment | User report, error log, or Discord message arrives |
| `/postmortem <incident>` | Full incident analysis → PMR | After a bug is fixed, or for deep analysis |
| `/blast-radius <commit-or-file>` | Map impact surface | Before a migration, or after discovering a regression |
| `/harden <pmr-id>` | Generate defensive measure specs | After a PMR is created |
| `/regression-check [pmr-id]` | Verify hardening still holds | Periodically, or before releases |
| `/signal-audit [scope]` | Audit test/type/error coverage | Proactively, before migrations or major changes |

## Grimoire Structure

```
grimoires/hardening/
├── pmr/                    # Postmortem Records (one per incident)
│   └── PMR-2026-001.md
├── actions/                # Hardening action specifications
│   ├── H1-*.md
│   └── H2-*.md
├── triage/                 # Triage cards (optional persistence)
├── signals/                # Signal audit reports
├── correlations/           # Cross-incident correlation reports
├── checklists/             # Reusable protocol checklists
├── state.yaml              # Construct state tracking
└── PIPELINE.md             # Pipeline documentation
```

## Common Workflows

**Incident Response** (reactive):
`/triage` → severity HIGH? → `/bug` (Loa) → `/postmortem` → `/harden` → `/sprint-plan` (Loa)

**Pre-Migration Check** (proactive):
`/signal-audit src/hooks/loans/` → review gaps → `/blast-radius src/lib/envio/` → address gaps before migrating

**Regression Sweep** (periodic):
`/regression-check` → review all PMRs → flag any regressions → `/postmortem` for new incidents

**Deep Dive on a Change**:
`/blast-radius abc1234` → understand impact → `/signal-audit` on affected paths → `/harden` if gaps found

## Tips

- Start with `/triage` for new reports — it recommends the right next action
- `/postmortem` works best after the fix is committed (more git data to mine)
- `/harden` outputs specs, not code — feed them into Loa `/sprint-plan` for implementation
- `/regression-check` without arguments checks all resolved PMRs
- `/signal-audit all` audits the entire codebase (slow but thorough)
- PMR IDs follow the pattern `PMR-YYYY-NNN` (e.g., PMR-2026-001)
- Hardening action IDs follow the pattern `H{N}` (e.g., H1, H2)
