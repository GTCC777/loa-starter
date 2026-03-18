# Herald

A Loa construct for grounded product communication. Converts product changes into community announcements built from code evidence, not vibes.

## What it does

Herald researches your git history, reads your actual code, and writes announcements that are verifiable. Every date comes from a commit. Every feature description comes from reading the component. Things that never shipped get called out honestly.

## Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| grounding-announcements | `/announce` | Draft announcements from product changes |
| synthesizing-voice | `/synthesize-voice` | Extract voice profile from existing content |
| chronicling-changes | `/chronicle` | Research git history into structured timelines |

## Artifacts

| File | Purpose | Customizable |
|------|---------|-------------|
| `contexts/voice/voice.md` | Tone, vocabulary, register, rhythm | Yes — per repo |
| `contexts/voice/principles.md` | Non-negotiable communication constraints | Yes — per repo |
| `grimoires/herald/chronicles/` | Structured change timelines from git | Generated |
| `grimoires/herald/announcements/` | Archived announcements with evidence | Generated |

## Quick Start

```
/announce [what changed]
```

Herald loads your voice profile and communication principles, researches the relevant git history, drafts the announcement, validates it against your constraints, and copies it to your clipboard.

## Setup

```
/synthesize-voice [paste some existing announcements]
```

This extracts your team's communication voice from real content and generates `voice.md`. Edit it to refine. The defaults work if you skip this step.

## Principles

Herald is built on one idea: **announcements should be built from code evidence, not promises.**

- Dates come from `git log`, not memory
- Feature descriptions come from reading components, not roadmaps
- Things that never shipped are labeled "never shipped"
- External reasons are named concretely
- The future earns its own announcement when it ships
