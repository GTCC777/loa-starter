---
type: vocabulary-context-base
name: resolution-rules
version: 1.0.0
description: "Eight rules for resolving vocabulary decisions in copy. Applied in order."
---

# Resolution Rules

When writing or auditing copy, apply these rules in order.

---

## Rule 1: Moment Type Determines Register

```
if (moment === "error" || moment === "confirmation") {
  register = "Layer 1 required"
  // L2 nouns acceptable if ALL of:
  //   (a) earned through prior discovery exposure
  //   (b) the operational signal is unambiguous without them
  //   (c) the surrounding context is already inside the world
} else if (moment === "action") {
  register = "Layer 1 for verbs, Layer 2 for nouns"
} else {
  register = "Layer 2 preferred, Layer 1 acceptable"
}
```

The register ceiling also applies: a component error inside the product UI can use world vocabulary because the user is already inside the world. A route error outside the product UI strips to pure operational because there's no world to lean on.

## Rule 2: Chekhov's Gun for Words

If you use an evocative word in a confirmation, the user expects it to carry specific meaning. If it's just atmosphere, you've loaded a gun you don't fire. If it later appears as a different action, you've fired the same gun in two contradictory directions.

**Test**: Can this word mean something else in a financial/operational context? If yes, don't use it in confirmations.

## Rule 3: Tooltips Teach Through Consequence

Never: "Your percentage of the total pool." (definition -> definition)
Always: "Each deposited Honeycomb adds weight to the vault." (action -> consequence)

## Rule 4: The Bazaar Baseline

Every user arrives with their own vocabulary already loaded. You cannot override it in 3 seconds. Chain-standard terms (deposit, withdraw, approve, wallet) are the shared language of the bazaar. Use them as anchors.

## Rule 5: Transaction States Are Aviation Copy

Transaction state labels follow the Stripe/aviation principle: short, unambiguous, present-tense.

| State | Label | NOT |
|-------|-------|-----|
| idle | "Withdraw" | "Close this compartment" |
| signing | "Sign in Wallet..." | "Awaiting signature..." |
| confirming | "Confirming..." | "Transaction pending..." |
| success | "Withdrawn" | "Successfully withdrawn!" |
| error | "Failed" | "Transaction failed" |

## Rule 6: Partial Success Needs Maximum Clarity

When a batch operation partially succeeds: state exactly what happened, what remains, and what the user can do.
- "Deposited 3 of 5 keys. Remaining can be retried."
- NOT: "Some compartments were created."

## Rule 7: Anticipate the Cycle

Player vocabulary evolves: informal -> formal -> new informal. Your formal Tier 2 terms will spawn user shorthand. Design terms to be robust enough that abbreviation preserves meaning. Monitor community channels for emergent vocabulary -- when a shorthand stabilizes, consider adopting it. But NEVER adopt shorthand that collides with chain-standard Tier 1 terms.

## Rule 8: Systems Are Not Characters

Systems activate and deactivate; they do not think, feel, or speak. Copy may describe what the system DOES but never what it WANTS or FEELS. This is the line between ceremony (earned) and anthropomorphism (false).

---

## The Lore-in-Operational-Comms Boundary

Five additional rules for using world vocabulary in status updates, bug reports, and incident communications. Extracted from research across Bungie, FFXIV, CCP/EVE, GGG, Warframe, and crypto projects.

### Rule L1: Lore Vocabulary Works When It IS the Technical Identifier

"Iron Banner is disabled" works -- there IS no un-lored name. Would removing the world vocabulary make the message clearer? If no, the vocabulary is load-bearing.

### Rule L2: Community Vocabulary Outranks Developer Vocabulary

CCP calls players "capsuleers" because the community does. If your community uses the term in conversation, it's native speech. If only the product calls them that, it's forced.

### Rule L3: Hard Wall Between Editorial and Operational Channels

FFXIV: Lodestone maintenance (L1) vs Live Letters (lore-rich). Riot: status page (L1) vs patch notes (personality). The studios that mix channels are the ones that stumble.

### Rule L4: Apologies and Incidents Demand the Lowest Lore Register

When trust is at stake, lore is a liability. Candor builds trust, not ceremony.

### Rule L5: Lore Must Never REPLACE Information, Only CARRY It

The moment the world term is vaguer than the operational term it replaces, you've crossed the line.
