---
name: harden
description: "Generate defensive measure specifications from a PMR — test specs, types, error boundaries, checklists."
user-invocable: true
allowed-tools: Read, Write, Glob, Grep, Edit
---

# Harden

Read a Postmortem Record and generate concrete defensive measure specifications — test specs, type definitions, error boundary placements, and migration checklists. Produces actionable specs that feed into sprint planning, not executable code. The construct analyzes and specifies; Loa `/implement` builds.

---

## Triggers

```
/harden <pmr-id>
/harden <pmr-id> --priority <CRITICAL|HIGH|MEDIUM|LOW>
/harden <pmr-id> --type <test-spec|type-spec|error-boundary|checklist|monitor>
```

**Examples:**
```bash
/harden PMR-2026-001
/harden PMR-2026-001 --priority CRITICAL
/harden PMR-2026-001 --type type-spec
```

**Arguments:**
- `<pmr-id>` — PMR identifier (e.g., `PMR-2026-001`) (required)
- `--priority` — Only generate actions at or above this priority level (optional)
- `--type` — Only generate actions of this type (optional)

---

## When to Use

- After creating a PMR with `/postmortem` to design defenses
- When preparing sprint tasks from incident hardening actions
- When a signal audit reveals gaps that need defensive specifications
- To generate a migration checklist protocol from a past migration incident
- When an accepted hardening action needs a detailed specification before implementation

---

## Workflow

### Step 1: Read PMR

Load the specified PMR from `grimoires/hardening/pmr/{pmr-id}.md`:

1. Validate the PMR has a **Signal Gaps** section (required — no gaps means no actions to generate)
2. Validate the PMR has a **Blast Radius** section (required — need to know where defenses go)
3. Read existing **Hardening Actions** table to avoid duplicating already-specified actions
4. If `--priority` or `--type` filters specified, scope to matching signal gaps only

### Step 2: Generate Test Specs

For each signal gap related to missing tests, write a test specification:

```markdown
# Test Spec: {action_id}
## PMR: {pmr_id}
## Signal Gap: {gap_description}

### What to Test
{Description of the behavior to verify}

### Test Fixture Requirements
- {Realistic data shape requirement — e.g., "Use Envio compound ID format '80094_backing_157', NOT simple strings like 'loan-1'"}
- {Boundary conditions — e.g., "Test with IDs containing underscores, hyphens, and pure numeric strings"}

### Assertions
1. {Specific assertion — e.g., "BigInt(getOnChainLoanId(envioId)) does not throw for compound IDs"}
2. {Negative assertion — e.g., "BigInt(rawEnvioId) DOES throw, proving the guard is necessary"}

### Files Under Test
- `{file:line}` — {what to test in this file}

### Verification Criterion
{Observable condition that proves the gap is closed — e.g., "Test suite includes at least one test per contract-calling component that uses production-realistic Envio IDs"}
```

Write each test spec to `grimoires/hardening/actions/{action_id}.md`.

### Step 3: Generate Type Specs

For each signal gap related to type system weaknesses, write a type specification:

```markdown
# Type Spec: {action_id}
## PMR: {pmr_id}
## Signal Gap: {gap_description}

### Branded Types to Introduce
- `{TypeName}` — {description, e.g., "Opaque type for Envio compound entity IDs ('chainId_entityType_numericId')"}
- `{TypeName}` — {description, e.g., "Opaque type for on-chain numeric loan IDs"}

### Conversion Boundary
- **Input boundary**: {Where raw data enters the system — e.g., "API route handler response transform"}
- **Output boundary**: {Where typed data exits to external systems — e.g., "Contract call arguments"}
- **Conversion function**: {Signature — e.g., "toOnChainLoanId(envioId: EnvioEntityId): OnChainLoanId"}

### Type Guard Signature
```typescript
function is{TypeName}(value: unknown): value is {TypeName}
```

### Files to Modify
- `{file}` — {what type change to make}

### Verification Criterion
{Observable condition — e.g., "Passing an EnvioEntityId directly to BigInt() produces a TypeScript compilation error"}
```

### Step 4: Generate Error Boundary Specs

For each signal gap related to unhandled errors, write an error boundary specification:

```markdown
# Error Boundary Spec: {action_id}
## PMR: {pmr_id}
## Signal Gap: {gap_description}

### Placement
- **File**: `{file:line}`
- **Scope**: {What code to wrap — e.g., "All BigInt() conversions in contract call argument preparation"}

### What to Catch
- {Error type — e.g., "SyntaxError from BigInt() with non-numeric strings"}
- {Error type — e.g., "TypeError from undefined/null values"}

### Error Surfacing
- **User notification**: {How to inform the user — e.g., "Toast: 'Unable to process loan ID. Please refresh and try again.'"}
- **Monitoring**: {What to log — e.g., "Sentry.captureException with loan ID value and component context"}
- **Fallback behavior**: {What the UI should do — e.g., "Disable the Repay button, show error state"}

### Verification Criterion
{Observable condition — e.g., "A malformed loan ID produces a user-visible error message instead of a silent React crash"}
```

### Step 5: Generate Checklist Protocols

For structural gaps (e.g., migration without consumer tracing), write a reusable checklist:

```markdown
# Checklist Protocol: {action_id}
## PMR: {pmr_id}
## Gap Type: {structural gap description}

### When to Use
{Trigger condition — e.g., "Before any data source migration (indexer, API, database)"}

### Checklist
- [ ] **Schema diff**: Compare response shapes field-by-field (types, units, ID formats, nullable changes)
- [ ] **Consumer trace**: Run `/blast-radius` on every changed endpoint to find all consumers
- [ ] **Type-sensitive operations**: For each consumer, check: BigInt(), new Date(), Number(), JSON.parse()
- [ ] **Fixture update**: Update all test fixtures to match the new data format
- [ ] **Comment audit**: Find and update all code comments referencing the old data format
- [ ] **Integration test**: Add at least one test per terminal consumer with production-realistic data
- [ ] **Smoke test**: Execute one real operation (on testnet) through the full data path

### Verification Criterion
{How to confirm the checklist was followed — e.g., "PR description includes completed checklist with file:line references for each item"}
```

### Step 6: Update PMR

Write generated action IDs back into the PMR's Hardening Actions table:

| ID | Action | Status | Priority | Sprint | Verification |
|----|--------|--------|----------|--------|-------------|
| H1 | {description} | proposed | {priority} | — | {method} |

Use Edit to update the PMR file in place.

Emit event for each action:
```bash
source .claude/scripts/lib/event-bus.sh
emit_event "forge.hardening.action_proposed" \
  '{
    "action_id": "{action_id}",
    "pmr_id": "{pmr_id}",
    "action_type": "{test-spec|type-spec|error-boundary|checklist|monitor}",
    "priority": "{priority}",
    "description": "{description}"
  }' \
  "hardening/harden"
```

### Step 7: Report Output

```
HARDENING ACTIONS GENERATED
============================

PMR: {pmr_id} — {title}

Actions Created:
  H1: [CRITICAL] {test-spec} — {description}
      → grimoires/hardening/actions/H1-{slug}.md
  H2: [HIGH] {type-spec} — {description}
      → grimoires/hardening/actions/H2-{slug}.md
  ...

PMR Updated: Hardening Actions table now has {N} proposed actions

Next Steps:
  - Review action specs: Read grimoires/hardening/actions/
  - Accept actions for sprint: update PMR action status to 'accepted'
  - Plan sprint: /sprint-plan (reads accepted actions from grimoires/hardening/actions/)
  - Verify existing hardening: /regression-check {pmr_id}
```

---

## Counterfactuals — Defensive Measure Specification

Hardening converts incident analysis into forward-looking defenses. The failure modes involve either designing defenses that target the specific bug instance rather than the bug class, or crossing the construct's boundary by producing implementation code instead of specifications.

### Target (Correct Behavior)

When hardening PMR-2026-001 (Envio migration), the skill generates 7 actions from 7 signal gaps. The test spec for H1 doesn't say "test that `BigInt('80094_backing_157')` throws" — it specifies "test every contract-calling component with Envio compound IDs to verify the ID extraction function handles all format variants." The type spec for H2 doesn't say "add a type for loan IDs" — it specifies two branded types (`EnvioEntityId` and `OnChainLoanId`) with a conversion function signature and the exact files where the type boundary should be enforced.

The migration checklist (H4) is not a one-time fix for the Envio migration — it's a reusable protocol for any future data source migration. The checklist items are generic ("compare response shapes field-by-field") with concrete verification criteria ("PR description includes completed checklist with file:line references"). This means the next migration — whether from Envio to a different indexer, or from one Supabase schema to another — inherits the structural defense without needing a new incident to learn from.

Each action spec includes a verification criterion: a concrete, observable condition that proves the defense is in place. "Tests exist" is not a verification criterion. "Test suite includes at least one test per contract-calling component that uses production-realistic Envio IDs" is. The criterion is specific enough for `/regression-check` to verify programmatically.

### Near Miss — Instance-Specific Hardening (Seductively Close, But Wrong)

The seductively wrong approach: hardening against the specific bug values rather than the bug class.

A test spec that says "assert `getOnChainLoanId('80094_backing_157')` returns `'157'`" is technically correct — it tests the exact case that broke. But it's an instance-specific test. What about `'80094_backing_0'`? What about `'80094_loan_157'` (a different entity type)? What about a future format change where Envio adds a fourth segment?

The instance-specific hardening looks right because it directly addresses the reported bug. The test will pass. The regression will not recur *in exactly this form*. But the class of error — format-sensitive parsing of external entity IDs — is not defended against. A new Envio format variant will produce a new bug in the same code, requiring a new postmortem, generating new hardening actions — a cycle that never compounds.

Class-level hardening specifies: "test `getOnChainLoanId` with compound IDs (multi-segment), simple numeric IDs (single-segment), edge cases (empty string, no underscores, trailing underscores), and adversarial inputs (non-numeric segments where numeric is expected)." This single test spec defends against the entire class of format parsing errors, not just the one instance that was reported.

The detection signal: if a test spec's assertions reference specific data values from the incident rather than data shape properties of the format, the spec is instance-level. Ask: "would this test catch a *variant* of this bug with different data values?" If no, the spec needs to be generalized.

**Physics of Error:** Brittle Dependency — coupling the defensive measure to the specific value (`"80094_backing_157"`) that triggered the bug rather than to the structural property (compound multi-segment ID format) that defines the bug class. The specific value will never recur, but the structural property will recur in every variant.

### Category Error — Writing Code Instead of Specifications (Fundamentally Wrong)

The fundamentally wrong approach: generating executable test code, type definitions, or error boundary implementations instead of specifications.

A harden invocation that outputs a complete `repay-loan.test.ts` file with working Vitest assertions has crossed the construct boundary. The Hardening construct analyzes and specifies — it does not write application code. Writing code bypasses Loa's implement → review → audit cycle, which means:

1. The code is unreviewed — no `/review-sprint` validates it against acceptance criteria
2. The code is unaudited — no `/audit-sprint` checks for security or quality issues
3. The code has no sprint context — it's not tracked in beads, has no task ID, and is invisible to sprint planning

The specification says *what* to test, *what* types to introduce, and *where* to place error boundaries. The implementation decides *how* — which test framework, which assertion style, which type system features, which error boundary component. The "how" decisions depend on the host project's conventions, which the construct cannot know without crossing into implementation.

In the Envio incident, the test spec should specify "test that loan repayment works with compound Envio IDs" and leave the choice of `Vitest` vs `Jest`, `render` vs `screen.getByRole`, and mock strategy to the implementing agent. The type spec should specify "branded type `OnChainLoanId` enforced at the API boundary" and leave the choice of `Brand<string, 'OnChainLoanId'>` vs `Newtype<string, {readonly OnChainLoanId: unique symbol}>` to the implementer who knows the project's type patterns.

The construct's value is analytical precision, not code generation. Every line of code it writes is a line that bypasses quality gates. Every specification it writes is a line that *passes through* quality gates while carrying the incident's lessons forward.

**Physics of Error:** Layer Violation — operating at the implementation layer (writing code) instead of the specification layer (describing what to build). The construct is an analyst and architect, not a developer. Crossing this boundary doesn't just produce lower-quality code — it undermines the entire implement → review → audit pipeline that ensures code quality.

---

## Validation

After hardening action generation:
- [ ] Each action spec has: ID, PMR reference, signal gap reference, verification criterion
- [ ] Test specs include fixture requirements with realistic data shapes (not placeholder values)
- [ ] Type specs include branded type names, conversion boundary, and type guard signature
- [ ] Error boundary specs include placement, catch scope, and user-facing error message
- [ ] Checklist protocols are generic (reusable for future similar operations)
- [ ] PMR Hardening Actions table updated with new action IDs and `proposed` status
- [ ] Action spec files written to `grimoires/hardening/actions/{action_id}-{slug}.md`
- [ ] No executable code in any action spec (specifications only)
- [ ] Events emitted for each proposed action

---

## Error Handling

| Error | Resolution |
|-------|------------|
| PMR not found | List available PMRs in `grimoires/hardening/pmr/`, prompt for correct ID |
| PMR has no signal gaps | Cannot generate actions — suggest running `/signal-audit` to identify gaps first |
| PMR has no blast radius | Cannot determine where to place defenses — suggest running `/blast-radius` first |
| Action ID conflict (H{N} already exists) | Increment to next available ID |
| `grimoires/hardening/actions/` directory doesn't exist | Create directory |
| Filter returns no matching gaps | Inform user, suggest widening `--priority` or `--type` filter |

---

## Integration Points

- **`/postmortem`**: Consumes PMR as input — signal gaps become hardening actions
- **Loa `/sprint-plan`**: Reads `grimoires/hardening/actions/` for accepted actions → sprint tasks
- **Loa `/implement`**: Test specs and type specs inform implementation
- **`/regression-check`**: Verification criteria enable automated regression detection
- **`/signal-audit`**: Signal audit can identify gaps that feed additional hardening actions

---

## Related

- `/postmortem` — Create the PMR that feeds hardening
- `/regression-check` — Verify that hardening actions remain effective over time
- `/signal-audit` — Broader coverage audit that may reveal additional gaps
- `/blast-radius` — Detailed impact mapping that informs where defenses are needed
