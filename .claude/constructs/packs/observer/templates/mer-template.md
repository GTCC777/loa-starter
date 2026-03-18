---
id: "{{MER_ID}}"
type: mer
schema_version: 1
title: "{{TITLE}}"
event_date: "{{EVENT_DATE}}"
date_recorded: "{{DATE_RECORDED}}"
model_version: "{{MODEL_VERSION}}"
owner: "{{OWNER}}"
trigger: "{{TRIGGER}}"
signal_weight: "{{SIGNAL_WEIGHT}}"
status: draft
wallets:
  - address: "{{WALLET_ADDRESS}}"
    alias: "{{WALLET_ALIAS}}"
    local_cache_path: "{{LOCAL_CACHE_PATH}}"
    visual_snapshots:
      profile: "{{SCREENSHOT_URL}}"
era: "{{ERA}}"
tags: []
related_issues: []
related_mers: []
core_conviction: "{{CORE_CONVICTION}}"
capture_env:
  base_url: "{{CAPTURE_BASE_URL}}"
  environment: "{{CAPTURE_ENVIRONMENT}}"
  app_commit: "{{CAPTURE_APP_COMMIT}}"
  viewport: "{{CAPTURE_VIEWPORT}}"
  captured_at: "{{CAPTURE_TIMESTAMP}}"
---

# {{TITLE}}

## Context

{{CONTEXT_DESCRIPTION}}

## Data State

| Metric | Value |
|--------|-------|
| Combined Score | {{COMBINED_SCORE}} |
| OG Score | {{OG_SCORE}} |
| NFT Score | {{NFT_SCORE}} |
| Onchain Score | {{ONCHAIN_SCORE}} |
| Overall Rank | {{OVERALL_RANK}} |
| Crowd Tier | {{CROWD_TIER}} |
| Elite Tier | {{ELITE_TIER}} |

## Visual Evidence

{{#IF_VISUAL}}
![Profile snapshot]({{SCREENSHOT_URL}})

*Captured: {{CAPTURE_TIMESTAMP}} | Environment: {{CAPTURE_ENVIRONMENT}} | Commit: {{CAPTURE_APP_COMMIT}} | Viewport: {{CAPTURE_VIEWPORT}}*
{{/IF_VISUAL}}
{{#IF_NO_VISUAL}}
*Visual capture unavailable for this record.*
{{/IF_NO_VISUAL}}

## User Signals

> {{USER_QUOTE}}

*Source: {{QUOTE_SOURCE}}* [QUOTED]

## Perception vs Reality

| What user expected | What system showed | Gap type |
|--------------------|--------------------|----------|
| {{EXPECTED}} | {{ACTUAL}} | {{GAP_TYPE}} |

## Four Questions (Eileen Framework)

1. **Core Conviction**: {{CORE_CONVICTION_ANSWER}}
2. **Target Audience**: {{TARGET_AUDIENCE}}
3. **Community Pulse**: {{COMMUNITY_PULSE}}
4. **One Lesson**: {{ONE_LESSON}}

## Decisions Made

- [ ] Issue filed
- [ ] Model adjusted
- [ ] Factor reweighted
- [ ] Exception documented

## State Diagram

```mermaid
{{STATE_DIAGRAM}}
```
