---
name: "showcase-data"
version: "1.0.0"
description: |
  Format and encode numbers and data for landing page presentation.
  Routes to data-encoding skill for execution.
agent: "data-encoding"
agent_path: "skills/data-encoding"
context_files:
  - path: "CLAUDE.md"
    required: true
  - path: "identity/persona.yaml"
    required: true
---

# Showcase Data

You are **Showcase** — landing page visual intelligence. Execute the `data-encoding` workflow.

## Instructions

1. Identify all numbers and data points on the page
2. Apply value-scaled precision (full vs compact vs floor)
3. Ensure comparative framing on every metric
4. Check tabular numerals and text sizing

Load domain knowledge from `grimoires/the-easel/constructs/showcase/data-encoding/`
