---
name: storytelling-layout
description: Narrative hierarchy, comparative framing, and layout variance for landing page sections
user-invocable: true
allowed-tools: Read, Write, Glob, Grep, Edit, Bash
---

# Storytelling Layout

Design the narrative flow and layout of landing page sections. Every page tells a story — this skill decides the chapter order, what gets hero treatment, and how cards are arranged.

## Trigger

/showcase-layout
/showcase-layout app/impact/page.tsx

## Workflow

### Step 1: Inventory the Content
Read the page or section. List every piece of content (products, stats, features, offerings) that needs to be displayed.

### Step 2: Classify by Rhetorical Role
Group content by what argument it makes:
- **Scale** — How big/wide is this? (community size, partner count, reach)
- **Authority** — Why should I trust this? (rankings, achievements, recognition)
- **Commitment** — How invested/sticky is this? (financial commitment, longevity, skin in the game)

### Step 3: Apply Narrative Hierarchy
Assign visual weight by importance:
- **Tier 1 (Hero)**: 1-2 items, full-width or oversized. The "moat number."
- **Tier 2 (Evidence)**: 3-4 items, medium cards or sidecars. Operational proof.
- **Tier 3 (Credentials)**: 2-3 items, compact strip. Trust signals.

### Step 4: Design Layout Variance
Never repeat the same layout in consecutive sections:
- Fused hero block → alternating sidecars → compact strip → featured + strip
- 120px+ whitespace between groups (logical delimiter, not breathing room)
- Each layout shift is a "mental reset"

### Step 5: Apply Comparative Framing
Every metric must be framed relative to something the audience understands:
- "#8 out of 60+ validators" not just "#8"
- "Largest on Berachain" not just "304,812"
- "Top 10 recipient" not just "1,242,812"

**Litmus test**: Can someone outside your ecosystem immediately understand whether this is impressive?

## Knowledge

Load patterns from `grimoires/the-easel/constructs/showcase/storytelling/`

## Boundaries

- Does NOT choose the visual for each card (use visual-metaphor skill)
- Does NOT format numbers (use data-encoding skill)
- DOES decide layout, ordering, sizing, and narrative flow
