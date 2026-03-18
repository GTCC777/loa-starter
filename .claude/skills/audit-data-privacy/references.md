# Data Privacy Engineering — Reference

Distilled from K-Hole depth research (2026-03-14, 3 digs, 124+ sources surveyed).

## The Platform Privacy Stack

```
Layer 1: Detection     → PII classification (Meta PAI, Airbnb Inspekt, Google DLP)
Layer 2: Flow Mapping  → Data lineage tracking (Privado, Fides)
Layer 3: Minimization  → API response filtering, log scrubbing
Layer 4: Deletion      → Right to be forgotten pipelines
Layer 5: Analytics     → Privacy-preserving measurement (differential privacy)
Layer 6: Audit         → Access logging, compliance verification
```

## How Platforms Solve It

### Google Cloud — Data Deletion Pipeline
Multi-stage process for "right to be forgotten":
1. Immediate: Mark for deletion (user sees "deleted")
2. 30 days: Recovery window (can undelete)
3. 2 months: Logical deletion from active storage
4. 6 months: Purged from backups and replicas

Key insight: deletion at scale is NOT instant. It's a state machine with multiple stages. The hardening construct should verify that deletion is a PROCESS, not a single DELETE query.

### Cloudflare — Privacy Edge
- "Cooperative Analytics": measures visits by analyzing request sources, no cookies, no IP tracking
- Multi-party computation for distributed aggregation
- Privacy Gateway: data residency enforcement at the edge

### TikTok — Privacy as Code
- Mateus Guzzo advocates open-source PETs (Privacy-Enhancing Technologies)
- "Project Texas": Oracle-hosted US data to address residency concerns
- Engineering implementation > policy documents

### Meta — PII Detection (PAI System)
- Automated PII classification across all data types
- AI/ML models trained on PII patterns
- Static analysis + runtime instrumentation

### Airbnb — Inspekt
- Data flow scanner for PII in codebases
- Integrates with CI/CD to catch PII exposure in PRs

### Riot Games / Roblox — User Research Data
- Participant data siloed from production data
- Research sessions require explicit consent tracking
- Data retention limits enforced by tooling, not policy
- Research artifacts anonymized before team-wide sharing

## The Observer Problem (Construct-Specific)

User research constructs (Observer, level-3-diagnostic) capture real user data:
- Names, wallet addresses, DM content, behavioral patterns
- Stored in `grimoires/observer/canvas/`, `grimoires/laboratory/`

Protection model:
1. **Construct sync excludes grimoires** — git-sync only packages `skills/`, `commands/`, `identity/`
2. **Grimoires are local** — they stay in the consumer repo, never enter the registry
3. **Public repos risk** — if consumer repo is public, grimoire PII is exposed
4. **No automated PII scrubbing** — canvases contain raw user data

Recommendations for `/audit-data-privacy`:
- Flag when observer canvases exist in a public repo
- Check `.gitignore` covers `grimoires/observer/imports/` (DM imports)
- Verify construct package doesn't include grimoire paths
- Recommend canvas anonymization before committing

## API Data Minimization Patterns

### Select Only What You Need
```typescript
// BAD — leaks submittedBy (user ID), internal fields
const rows = await db.select().from(table);

// GOOD — explicit public-safe columns
const rows = await db.select({
  id: table.id,
  title: table.title,
  url: table.url,
  // submittedBy intentionally excluded
}).from(table);
```

### Response Shaping
```typescript
// Strip internal fields before sending
function toPublicResponse(row) {
  const { submittedBy, internalNotes, ...public } = row;
  return public;
}
```

### Log Scrubbing
```typescript
// Redact PII before logging
function redactPII(obj) {
  const redacted = { ...obj };
  if (redacted.email) redacted.email = '***@***';
  if (redacted.walletAddress) redacted.walletAddress = redacted.walletAddress.slice(0, 6) + '...';
  return redacted;
}
```

## Open-Source Tools for the Construct

| Tool | Purpose | Integration Point |
|------|---------|-------------------|
| Fides (ethyca/fides) | Privacy metadata annotation + risk assessment | CI/CD policy check |
| Privado (Privado-Inc/privado) | Data flow PII mapping | Pre-PR scan |
| Google Cloud DLP | PII detection API (150+ infoTypes) | Runtime log scrubbing |
| presidio (Microsoft) | PII detection + anonymization library | Canvas anonymization |

## What This Means for the Hardening Construct

The `/audit-data-privacy` skill should check for:
1. API endpoints using `.select()` without explicit column lists
2. Observer/research grimoires in public repos
3. DM imports or canvas files with real user names
4. Logs that might contain PII (check logger calls near auth flows)
5. Error responses that include user data
6. Data deletion capability (can a user's data actually be removed?)
7. Data retention policy implemented in code (not just documented)
