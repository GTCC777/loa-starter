---
type: chronicle-template
name: chronicle
version: 1.0.0
description: Template for structured change timelines from git evidence
---

# Chronicle Template

## Output Format

```markdown
# Chronicle: {Scope}

Generated: {ISO date}
Evidence: {N} commits across {date range}

## Timeline

| Date | Feature | Event | Evidence |
|------|---------|-------|----------|
| {YYYY-MM-DD} | {feature} | {what happened} | commit {short hash} |

## Features

### {feature-name}
**Shipped:** {date from git}
**Status:** {active|sunset|moved|never-shipped}
**Description:** {what the code does, one paragraph}
**Integrations:** {contracts, APIs, external services}
**Key files:** {main component, hooks, routes}
**Evidence:** {commit hashes}

## External Factors

| Factor | Impact | Evidence |
|--------|--------|----------|
| {named event} | {what it changed} | {link, PR, or reference} |

## Unshipped Items

| Item | Evidence of Absence |
|------|---------------------|
| {feature} | {isLocked: true, no component, placeholder only, etc.} |
```
