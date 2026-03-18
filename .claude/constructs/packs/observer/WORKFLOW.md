# Observer — Workflow Guide

> v1.4.0 | User truth capture through hypothesis-first research

## Quick Start

> Get value in 30 seconds.

1. Capture feedback: `/observe @username "their quote" --wallet 0x...`
2. Review canvas: `grimoires/observer/canvas/{username}-canvas.md`
3. Check freshness: `/stale` to see which artifacts need updating

## Prerequisites

| Requirement | Check | Required |
|-------------|-------|----------|
| Supabase CLI | `supabase --version` | For enrichment |
| Score API access | `scripts/observer/score-api-query.sh profile <wallet>` | For enrichment |
| jq | `jq --version` | For validation script |
| Wrapper scripts | `ls scripts/observer/` | For DM import & synthesis |

## Skill Reference

| Command | What It Does | When to Use |
|---------|-------------|-------------|
| `/observe @user "quote"` | Capture feedback as Level 3 diagnostic | User reports issue or request |
| `/observe --enrich @user --wallet 0x` | Retroactive Score API enrichment | Wallet becomes available for existing canvas |
| `/ingest-dm <path>` | Import Discord DM export into canvas | New beta user with DM conversation |
| `/daily-synthesis` | Pull new Supabase feedback, enrich, route | Daily automated pipeline |
| `/batch-observe` | Parallel multi-user processing | Batch DM imports |
| `/shape` | Synthesize canvases into journey definitions | After 3+ canvases accumulated |
| `/level-3-diagnostic` | Diagnostic questioning framework | Refine hypotheses to Level 3 |
| `/follow-up` | Generate follow-up messages from canvases | Re-engage users |
| `/analyze-gap` | Compare expectations with code reality | Before building features |
| `/gap-to-issues` | File gap analysis as GitHub issues | After gap analysis |
| `/file-gap` | File individual gap as issue | Single gap → issue |
| `/import-research` | Bulk convert legacy profiles to UTC | Migration from old format |
| `/feedback-observe` | Detect patterns in agent logs | Periodic agent health check |
| `/stale` | Scan artifact confidence scores | Periodic freshness check |
| `/drift <path>` | Show changes since last validation | Investigate specific artifact |
| `/refresh <path>` | Re-validate and boost confidence | Refresh stale artifacts |

## Grimoire Structure

```
grimoires/observer/
├── canvas/                   # User Truth Canvases (one per user)
│   ├── xabbu.md
│   └── elcapitan-canvas.md
├── journeys/                 # Synthesized journey definitions
├── reality/                  # Code reality extractions
├── synthesis/                # Daily synthesis reports + state
│   ├── feedback-{date}.md
│   └── last-run.json
├── agent-logs/               # Skill invocation logs (JSONL)
│   └── {YYYY-MM-DD}.jsonl
├── agent-feedback/           # Agent feedback reports
│   ├── report-{date}.md
│   └── report-latest.md
├── wallets.yaml              # Wallet cache
├── state.yaml                # Lab state
└── PIPELINE.md               # Pipeline documentation
```

## Common Workflows

**New user feedback**:
`/observe @user "quote"` → review canvas → `/shape` when 3+ canvases

**Daily pipeline**:
`/daily-synthesis` → review report → `/follow-up` for high-weight users

**Freshness audit**:
`/stale` → `/drift <path>` for warnings → `/refresh <path>` for stale

## Tips

- Always provide `--wallet` when available for Score API enrichment
- Hypotheses start at Low confidence — never classify users from single quotes
- `/stale` is the fastest way to find what needs attention
- Agent logs power `/feedback-observe` — run it weekly for operational insights
