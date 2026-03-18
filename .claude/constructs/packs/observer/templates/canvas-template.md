---
type: user_canvas_template
schema_version: 2
user: "{{username}}"
wallet: "{{wallet}}"
lifecycle_state: onboarding
last_enriched: "{{timestamp}}"
enrichment_trigger: manual
score_snapshot:
  captured_at: "{{snapshot_timestamp}}"
  wallet: "{{wallet}}"
  rank: null                 # from mv_wallet_tiers.overall_rank
  combined_score: null       # from mv_wallet_tiers.combined_score
  og_score: null             # from mv_wallet_profiles
  nft_score: null
  onchain_score: null
  og_rank: null              # from mv_dimension_leaderboard
  nft_rank: null
  onchain_rank: null
  trust_filter: null         # from mv_wallet_profiles
  trust_classification: null
  og_breadth: null
  nft_breadth: null
  onchain_breadth: null
  crowd_tier: null           # from mv_wallet_tiers
  elite_tier: null
  total_badges: null         # from mv_wallet_badge_summary.badge_count
  model_version: null
hivemind:
  artifact: user_truth_canvas
  workstream: discovery
  product: []
  jtbd: []
  source: dm_to_team_member
  learning_status: smol_evidence
chronicle_refs: []
created: "{{timestamp}}"
updated: "{{timestamp}}"
linked_journeys: []
linked_observations: []
pfp_url: null
---

<!-- midi:pfp -->
![{{username}}]({{pfp_url}}?w=200)
<!-- /midi:pfp -->

# {{username}} Canvas

## User Profile

| Field | Value |
|-------|-------|
| **Signals Observed** | |
| **Theories** | |
| **Confidence** | |
| **Unknown** | |
| **Stakes** | |

---

## Score Context

| Field | Value |
|-------|-------|
| **Wallet** | `{{wallet}}` |
| **Rank** | **#{{rank}}** |
| **Combined Score** | **{{combined_score}}** |
| **OG** | {{og_score}} / rank #{{og_rank}} / breadth {{og_breadth}} |
| **NFT** | {{nft_score}} / rank #{{nft_rank}} / breadth {{nft_breadth}} |
| **Onchain** | {{onchain_score}} / rank #{{onchain_rank}} / breadth {{onchain_breadth}} |
| **Trust** | {{trust_filter}} ({{trust_classification}}) |
| **Crowd Tier** | **{{crowd_tier}}** |
| **Elite Tier** | {{elite_tier}} |
| **Badges** | {{total_badges}} earned |
| **Signal Weight** | **{{signal_weight}}** ({{crowd_tier}} tier, rank #{{rank}}) |
| **Model Version** | {{model_version}} |
| **Captured At** | {{snapshot_timestamp}} |

---

## Level 3 Hypotheses

### H-1: {{hypothesis_title}}
<!-- hivemind:product:PLACEHOLDER -->

- **Evidence**: [prov:PLACEHOLDER]
- **Confidence**: Low
- **What would validate**:
- **What would invalidate**:

---

## Future Promises (Unvalidated)

| Promise | Date | Follow-up Trigger | Status |
|---------|------|-------------------|--------|

---

## Journey Fragments

| Trigger | Action | Expected | Actual | Emotion |
|---------|--------|----------|--------|---------|

---

## Expectation Gaps (Code-Grounded)

### GAP-{{username}}-1: {{gap_title}}
| Field | Value |
|-------|-------|
| **Type** | |
| **Severity** | |
| **Status** | OPEN |
| **Source** | |

---

## Feedback Entries (from UI)

| Date | Type | Note | Source | Signal | Weight | Model |
|------|------|------|--------|--------|--------|-------|

---

## Conversation Frameworks

When {{username}} returns, anchor on their words:

**If they mention {{topic}}:**
- Opener:
- Dig deeper:
- Past behavior:
- Watch for:

---

## Quotes Library

> "{{quote_text}}"
> — {{source}}, {{date}}
<!-- prov:sha256:PLACEHOLDER -->

---

## Linked Artifacts

### Journeys
- [[journeys/{{journey_name}}|{{journey_display}}]]

### Related Canvases
