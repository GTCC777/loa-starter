---
name: audit-data-privacy
description: "Scan for PII exposure in API responses, committed files, grimoires, and data flow paths."
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Agent
triggers:
  - "audit data privacy"
  - "scan for pii"
  - "check personal data"
capabilities:
  model_tier: opus
  danger_level: safe
  effort_hint: medium
---

# Data Privacy Audit

Trace where personal data flows and where it might leak.

## What Is PII in This Context

- Wallet addresses (0x...)
- Email addresses
- User IDs (UUIDs that can be correlated)
- Usernames / display names
- IP addresses
- Session tokens / refresh tokens
- DM content / conversation transcripts
- User research canvases with real user data

## Workflow

### Phase 1: API Response Audit

For each public API endpoint (no auth required, or optionalAuth):

1. Read the endpoint handler
2. Check the SELECT query — does it use `.select()` (all columns) or explicit column list?
3. Flag any response that includes: `submittedBy`, `userId`, `user_id`, `email`, `walletAddress`, `wallet_address`, `ipAddress`
4. For endpoints behind auth: check if they return OTHER users' data (not just the caller's own)

### Phase 2: Committed File Scan

Search the entire repo (excluding node_modules, .next, dist):

1. **Wallet addresses**: Pattern `0x[0-9a-fA-F]{40}` in any non-test, non-fixture file
2. **Email addresses**: Pattern `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}` excluding config patterns
3. **API keys/tokens**: Patterns `sk_`, `pk_`, `key_`, `token_`, `secret_` with actual values (not template refs)
4. **DM content**: Files matching `*dm*`, `*import*`, `*canvas*` in grimoires — check for real user names/content

### Phase 3: Data Flow Tracing

For systems that sync data between repos (construct sync, git-sync):

1. What directories are included in the sync? (Check sync config)
2. Do any synced directories contain user research, canvases, or PII?
3. Does the construct package (what gets installed) include any grimoire data?

Specifically check:
- `grimoires/observer/` — canvases, cognition profiles, synthesis reports
- `grimoires/laboratory/` — user research
- `grimoires/*/imports/` — DM imports
- Any `.jsonl` files that might contain user event data

### Phase 4: Cookie and Token Audit

1. Which cookies are set? Check `Set-Cookie` calls and `response.cookies.set()`
2. Are auth tokens in httpOnly cookies? Or JS-accessible?
3. Are tokens in URL query strings? (OAuth callbacks)
4. Are tokens logged? Check logger calls near auth flows.

### Output

```markdown
## Data Privacy Audit

### PII Exposure
| Location | Data Type | Severity | Current State |
|----------|-----------|----------|---------------|

### Data Flow
| Path | Contains PII | Synced? | Risk |
|------|-------------|---------|------|

### Recommendations
1. [action items]
```

## The Observer Problem

The Observer construct captures real user feedback — names, conversations, behavioral patterns. This data is valuable for product development but is PII. The key question: **does any user research data leave the consumer repo?**

Check:
- Construct sync excludes `grimoires/` → ✓ Safe
- Construct package only includes `skills/`, `commands/`, `identity/` → ✓ Safe
- But: if someone commits grimoires to a public repo → ✗ Leak

The skill should flag when observer canvases exist in a public repo.
