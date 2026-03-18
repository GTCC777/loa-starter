---
type: voice-template
name: voice
version: 1.0.0
description: Template for per-repo voice profiles
---

# Voice Template

## Output Format

```markdown
# Voice Profile

Generated: {date}
Source: {N} samples analyzed
Confidence: {HIGH|MEDIUM|LOW per dimension}

## Register

- style: {lowercase|title-case|mixed}
- formality: {formal|casual-direct|slang}
- perspective: {first-person-plural|impersonal|direct-address}
- fragments: {yes|no|closers-only}

## Vocabulary

### Preferred Terms
| Instead of | Use | Source |
|-----------|-----|--------|
| {formal/generic} | {preferred} | {sample ref} |

### Banned Words
- {word} — {reason}

### Domain Terms
- {term}: {how it's used in this voice}

## Tone

- emotional_range: {neutral|dry|warm}
- humor: {none|dry-occasional|frequent}
- confidence: {hedged|matter-of-fact|assertive}
- on_bad_news: {direct|softened|reframed}
- on_good_news: {understated|brief|celebrated}

## Rhythm

- sentences: {short|medium|varied}
- paragraphs: {N-N sentences}
- structure: {action-first|context-first|thesis-first}
- lists: {preferred|occasional|rare}
- closer: {philosophical|call-to-action|sign-off|none}

## Audience

- primary: {holders|community|public|developers}
- assumed_knowledge: {high|medium|low}
- context_level: {minimal|moderate|thorough}
- action_items: {embedded|separate-section|bold-inline}
```
