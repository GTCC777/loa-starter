---
name: data-encoding
description: Number formatting and data presentation patterns for landing page metrics
user-invocable: true
allowed-tools: Read, Write, Glob, Grep, Edit, Bash
---

# Data Encoding

How to format and present numbers, stats, and data on landing pages. Numbers are not just values — they're trust signals. The format IS the message.

## Trigger

/showcase-data
/showcase-data "304812 community members"

## Core Patterns

### Value-Scaled Precision
| Format | When | Example |
|--------|------|---------|
| Full precision | Trust signal, "Ugly Number" effect | 304,812 |
| Compact magnitude | Scale matters more than exactness | 1.2M |
| Tabular numerals | Always (prevents jitter) | `tabular-nums` |

### The Comparative Framing Rule
Every number needs an anchor: "out of X", "Top N in Y", "Largest on Z". The number alone is a fact. The anchor makes it evidence.

### The 3-Digit Rule (Andreas Nieder)
Cognitive load jumps 20% past 3 significant figures. Use full precision in hero/sidecar contexts with breathing room. Use compact notation in dense strips.

## Knowledge

Load patterns from `grimoires/the-easel/constructs/showcase/data-encoding/`

## Boundaries

- Does NOT decide layout (use storytelling-layout)
- Does NOT decide visuals (use visual-metaphor)
- DOES decide number format, precision, anchoring, and temporal context
