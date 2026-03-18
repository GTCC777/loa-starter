---
type: announcement-template
name: announcement
version: 1.0.0
description: Template for grounded product announcements
---

# Announcement Template

## Metadata (frontmatter for archived announcements)

```yaml
---
date: {ISO date}
scope: {what changed}
type: {removal|release|structural|update}
channel: {discord|twitter|changelog}
voice: {voice.md hash or "defaults"}
principles: {principles.md hash or "defaults"}
evidence:
  commits: [{hashes}]
  files_read: [{paths}]
  dates_verified: {true|false}
---
```

## Structure: Removal / Sunset

```
{action statement — what is being removed, from where}

{grounded history — what these were, when they shipped, what they did. dates from git.}

{concrete reason — named external event or factual cause}

{deadline + user action — what people need to do, by when}

{survivors — what changes but stays, what moves}

{closer — brief, from voice.md rhythm.closer}

{itemized list — one line per item, descriptions from code}

{other changes — items that moved/changed but weren't removed}
```

## Structure: Release / New Feature

```
{what shipped — present tense, name the feature}

{what it does — from reading the code, not the roadmap}

{how to access — URL, route, or path}

{known limitations — honest, if any}
```

## Structure: Structural Change

```
{what moved or changed}

{what it means for users — practical impact}

{what stays the same — reassurance from reality}
```

## Validation Checklist

```
[ ] Every feature description matches code
[ ] Every date from git log
[ ] Zero forward-looking statements
[ ] Zero banned vocabulary (voice.md)
[ ] Zero apologies or hedging
[ ] Practical action items are clear
[ ] Unshipped items labeled honestly
[ ] External reasons named concretely
[ ] Tone matches voice.md register
[ ] Defensible if screenshot'd in 6 months
```
