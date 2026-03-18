---
name: visual-metaphor
description: Visual metaphor selection for landing page cards — what visual communicates this concept
user-invocable: true
allowed-tools: Read, Write, Glob, Grep, Edit, Bash
---

# Visual Metaphor

Decide what visual goes inside each card on a landing page. Not decoration — communication. Every visual is a visual argument for the content it accompanies.

## Trigger

/showcase-visual
/showcase-visual "security feature card"

## Workflow

### Step 1: Identify the Concept
What is this card communicating? A product? A stat? A feature? An offering? Name the core concept in one word: "security", "scale", "speed", "coverage", "dominance".

### Step 2: Map Concept to Visual Family
Use the Information Intent framework:
- **Scale/Magnitude** → vertical comparison, particle density, area fills
- **Security/Protection** → concentric rings, shields, enclosure
- **Speed/Performance** → motion blur, trajectories, streamlines
- **Network/Connection** → constellation, node graphs, webs
- **Growth/Progress** → upward trajectories, accumulation, terrain
- **Rank/Position** → podium, position markers, comparative bars
- **Commitment/Accumulation** → accretion, flow, gravitational pull

### Step 3: Select Treatment Level
Based on card importance (from storytelling-layout):
- **Hero cards** → full 3D scene, complex visual, bleeding to edges
- **Evidence cards** → contained visual with clear negative space
- **Credential cards** → no visual or minimal texture accent

### Step 4: Validate Communication
Ask: if I showed this visual without ANY text, would someone guess what domain this card covers? If not, the metaphor is too abstract.

## Knowledge

Load patterns from `grimoires/the-easel/constructs/showcase/visual-metaphor/`

## Status

This skill needs deep research to fill its knowledge base. Run `/showcase-research "visual metaphor selection"` to build the foundation. Current knowledge is minimal — the Mercury/Stripe/Linear patterns are the primary references.

## Boundaries

- Does NOT implement the visual (use VFX Playbook, WebGL Particles, or Artisan)
- Does NOT decide card layout or sizing (use storytelling-layout)
- DOES decide what visual concept goes in each card and why
