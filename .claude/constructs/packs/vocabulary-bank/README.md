# construct-vocabulary-bank

Per-product vocabulary governance with tiered lexicons, register-aware channel mapping, and the Anchor-Space-Gravity philosophy.

## what it does

Every product has words that carry weight. Some are industry-standard (deposit, withdraw, approve). Some are yours (compartment, weight, key). Some aren't ready yet (coronene, carpathit).

This construct provides the schema for managing those words: which are chain-standard (never rename), which are world vocabulary (earned through discovery), and which are reserved (not yet deployed).

Install it. Populate your bank. Let Herald (or any comms construct) read it when drafting.

## the model

Two registers. Three tiers. Five moment types. Eight resolution rules.

**Registers**: L1 (operational clarity) and L2 (world vocabulary). L1 is required in confirmations and errors. L2 is preferred in discovery and idle moments. The boundary between them is the vocabulary bank's primary governance mechanism.

**Tiers**: T1 (chain-standard, never rename), T2 (earned through discovery exposure), T3 (reserved, not yet deployed). Words promote from T3 to T2 through consistent use in discovery moments. Words that skip this earn-cycle feel arbitrary.

**Philosophy**: Anchor-Space-Gravity. Material words stick (Anchor). Unfilled space creates meaning (Space). Consistent use accumulates meaning beyond definition (Gravity).

## skills

| Skill | Command | What it does |
|-------|---------|-------------|
| Synthesize Vocabulary | `/synthesize-vocabulary` | Extract terms from existing copy, classify into tiers, generate a bank |
| Audit Vocabulary | `/audit-vocabulary` | Check copy against the bank, flag violations by severity |

## install

```bash
# from the constructs network
claude skills add vocabulary-bank

# or clone directly
git clone https://github.com/0xHoneyJar/construct-vocabulary-bank.git .claude/constructs/packs/vocabulary-bank
```

Then: `/synthesize-vocabulary` to bootstrap from your codebase.

## research

Based on a 70+ source dig across 8 ecosystems: Riot (LoL/Valorant/TFT), Bungie (Destiny), Square Enix (FFXIV), CCP (EVE Online), Valve (TF2/Dota 2), Supergiant (Hades), Yuga Labs (BAYC/Otherside), and DeFi protocols (Aave/Uniswap).

Key finding: no studio maintains explicit channel voice guides. Voice register modulation is emergent, governed by structural constraints, not style guides. This construct provides those structural constraints.

## works with

- **Herald** — reads the vocabulary bank when drafting announcements. Knows what terms are available at what tier.
- **Artisan** — vocabulary bank governs copy vocabulary; Artisan governs visual vocabulary (atlas.md).
- **Observer** — surfaces community vocabulary adoption; vocabulary bank formalizes it into tiers.
