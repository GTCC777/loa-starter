# loa-starter

A minimal starter template for projects using the [Loa](https://github.com/0xHoneyJar/loa) framework with Claude Code.

## What's included

- `.claude/` — Claude Code config with overrides directory
- `.loa.config.yaml` — Loa framework configuration (submodule mode)
- `.loa-version.json` — Pinned Loa version
- `.gitmodules` — Loa submodule reference
- `grimoires/loa/` — Loa state/notes directory
- `CLAUDE.md` — Project-level Claude instructions

## Getting started

```bash
# 1. Clone this template
git clone https://github.com/GTCC777/loa-starter my-project
cd my-project

# 2. Initialize the Loa submodule
git submodule update --init --recursive

# 3. Mount the framework (creates symlinks in .claude/)
claude /mount

# 4. Start building
claude
```

## About Loa

Loa is a structured AI workflow framework for Claude Code. It provides slash commands, agents, skills, and protocols for systematic software development.

Source: https://github.com/0xHoneyJar/loa
