---
name: researching-showcase
description: Deep research into any Showcase sub-domain via k-hole construct
user-invocable: true
allowed-tools: Read, Write, Glob, Grep, Edit, Bash, Agent
---

# Researching Showcase

Deep dive into any Showcase sub-domain. Wraps the k-hole construct's /dig command with Showcase-specific framing and knowledge storage.

## Trigger

/showcase-research "visual metaphor selection in premium landing pages"
/showcase-research "how Mercury and Stripe choose card visuals"

## Workflow

### Step 1: Frame the Research
Take the user's thread and frame it within Showcase's domain. Add context about landing page visual communication.

### Step 2: Execute Research
Use the k-hole /dig command to perform grounded research.

### Step 3: Synthesize into Showcase Knowledge
Extract actionable patterns from the research and store them in the appropriate grimoire subdirectory:
- Layout patterns → `grimoires/the-easel/constructs/showcase/storytelling/`
- Visual metaphor patterns → `grimoires/the-easel/constructs/showcase/visual-metaphor/`
- Data encoding patterns → `grimoires/the-easel/constructs/showcase/data-encoding/`
- Shape/motion meaning → `grimoires/the-easel/constructs/showcase/visual-semiotics/`

### Step 4: Update Construct Knowledge
Add new patterns to the relevant SKILL.md or create standalone pattern files.

## Dependencies

Requires k-hole construct for grounded search.

## Boundaries

- Does NOT apply findings to code (use other skills or /implement)
- DOES research, synthesize, and store knowledge
