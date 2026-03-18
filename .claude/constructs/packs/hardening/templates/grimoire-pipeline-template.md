# Hardening Pipeline

> Incident → Postmortem → Hardening → Regression Check

## Pipeline Stages

```
Signal (user report / error / CI failure)
    │
    ▼
/triage ── severity assessment
    │
    ├── CRITICAL/HIGH ──► /bug (Loa) ──► fix commits
    │                                        │
    │                                        ▼
    └── ALL severities ──► /postmortem ──► PMR document
                                             │
                                             ▼
                                        /harden ──► action specs
                                             │
                                             ▼
                                        /sprint-plan (Loa) ──► implementation
                                             │
                                             ▼
                                        /regression-check ──► ongoing verification
```

## Artifact Locations

| Artifact | Path | Created By |
|----------|------|------------|
| Postmortem Records | `grimoires/hardening/pmr/` | `/postmortem` |
| Hardening Actions | `grimoires/hardening/actions/` | `/harden` |
| Triage Cards | `grimoires/hardening/triage/` | `/triage` |
| Signal Audits | `grimoires/hardening/signals/` | `/signal-audit` |
| Correlation Reports | `grimoires/hardening/correlations/` | `correlating` |
| Checklists | `grimoires/hardening/checklists/` | `/harden` |

## State Tracking

State is maintained in `grimoires/hardening/state.yaml`. Updated by each skill invocation.

## Integration with Loa

- `/triage` feeds → Loa `/bug` (triage card informs bug fix)
- `/harden` feeds → Loa `/sprint-plan` (actions become sprint tasks)
- `/regression-check` feeds → Loa `/postmortem` (regressions trigger new incidents)

## Integration with Observer

- Observer `forge.observer.canvas_created` → `/triage` (auto-triage from user feedback)
- Observer `forge.observer.gap_filed` → `correlating` (cross-reference gaps with PMR blast radii)
