# Hardening

> Every scar becomes armor — incidents compound into defenses.

Hardening is a [Loa Framework](https://github.com/0xHoneyJar/loa) construct that transforms production incidents into compounding defensive artifacts. It produces structured postmortem records, blast radius maps, hardening action specs, and regression checks that prevent the same failure from recurring.

## Why This Exists

### The Envio Incident

In February 2026, a migration from Goldsky to Envio indexer in [mibera-interface](https://github.com/0xHoneyJar/mibera-interface) introduced a silent regression that went undetected for 8 days. Three distinct bugs — a loan ID format mismatch, a timestamp unit confusion (seconds vs milliseconds), and a BigInt parsing failure — cascaded through the lending interface, causing contract calls to silently fail with incorrect parameters.

No test caught the regression. No type guard prevented the format mismatch. No error boundary surfaced the silent failures. Users reported the issue on Discord before any automated signal detected it.

The Hardening construct exists so that every incident like this produces artifacts that prevent recurrence — not just a fix, but tests, types, error boundaries, and regression checks that compound over time.

### Relationship to Loa and Observer

- **Loa** fixes bugs (`/bug`) and implements code (`/implement`). Hardening analyzes *why* bugs happened and specifies *what defenses* to build — but never writes application code.
- **Observer** captures user feedback and surfaces gaps. Hardening consumes Observer's signals to auto-triage user reports against known vulnerability surfaces.
- **Hardening** sits between detection and prevention: it transforms incident data into defensive specifications that Loa implements.

## Quick Start

```bash
# 1. Clone into your constructs directory
git clone https://github.com/0xHoneyJar/construct-hardening.git

# 2. Run the install script to initialize the grimoire
cd construct-hardening
bash scripts/install.sh

# 3. Create your first postmortem
/postmortem "Describe the incident or paste an error/issue URL"
```

## Skills

| Command | Description | Model | Effort |
|---------|-------------|-------|--------|
| `/postmortem` | Create a structured PMR from an incident | Opus | Large |
| `/triage` | Quick severity assessment from user reports | Sonnet | Medium |
| `/blast-radius` | Map impact surface of a change or regression | Sonnet | Large |
| `/harden` | Generate defensive measure specs from a PMR | Opus | Large |
| `/regression-check` | Verify past hardening measures still hold | Sonnet | Medium |
| `/signal-audit` | Audit test/type/error/monitoring coverage | Sonnet | Large |

## Workflow

```
Signal ──► /triage ──► /bug (Loa) ──► /postmortem ──► /harden ──► /regression-check
                                                         │
                                                         ▼
                                                   Sprint tasks (Loa)
```

1. **Triage** — Assess severity, connect the report to affected code
2. **Fix** — Hand off to Loa `/bug` for the actual fix
3. **Postmortem** — Reconstruct timeline, root cause, and blast radius
4. **Harden** — Generate defensive measure specifications
5. **Verify** — Check that hardening holds over time

## Artifact: Postmortem Record (PMR)

The PMR is the core artifact. Each incident produces one PMR containing:

- **Timeline** — Timestamped event sequence from introduction to fix
- **Root Cause** — Classified using an 8-category taxonomy
- **Blast Radius** — Every file affected, with impact severity
- **Signal Gaps** — What monitoring/tests/types were missing
- **Hardening Actions** — Concrete defensive measures with lifecycle tracking
- **Regression Checks** — Ongoing verification that defenses hold

## Installation

Requires the [Loa Framework](https://github.com/0xHoneyJar/loa). Optional integration with [Observer](https://github.com/0xHoneyJar/construct-observer) for auto-triage from user feedback.

```bash
git clone https://github.com/0xHoneyJar/construct-hardening.git
bash construct-hardening/scripts/install.sh
```

The install script creates `grimoires/hardening/` with the required directory structure and initial state.

## License

MIT - 0xHoneyJar
