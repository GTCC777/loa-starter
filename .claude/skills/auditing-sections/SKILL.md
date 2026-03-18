---
name: auditing-sections
description: Audit landing page sections against Showcase visual communication patterns
user-invocable: true
allowed-tools: Read, Write, Glob, Grep, Edit, Bash
---

# Auditing Sections

Review a landing page section against all accumulated Showcase patterns. Produces a scored audit with specific findings and fixes.

## Trigger

/showcase-audit
/showcase-audit app/impact/page.tsx

## Workflow

### Step 1: Read the Page
Read the target file. Identify all sections, cards, and content items.

### Step 2: Pattern-by-Pattern Audit
Score each pattern as PASS / PARTIAL / FAIL:

1. **Comparative Framing** — Does every metric have an anchor?
2. **Narrative Hierarchy** — Is there clear tiered prominence?
3. **Layout Variance** — Do consecutive sections use different layouts?
4. **Visual Metaphor Match** — Do visuals communicate the right concept?
5. **Data Encoding** — Are numbers formatted appropriately?
6. **Readability** — Is all text large enough? (minimum text-xs md:text-sm)
7. **Card Affordance** — Are display cards styled differently from interactive ones?
8. **Section Flow** — Does the page tell a coherent story?

### Step 3: Write Audit Report
Save to `grimoires/the-easel/constructs/showcase/audits/` with findings and fixes.

## Knowledge

Load all patterns from `grimoires/the-easel/constructs/showcase/` subdirectories.

## Boundaries

- Does NOT fix the issues (that's implementation work)
- DOES identify issues, score them, and propose specific fixes
