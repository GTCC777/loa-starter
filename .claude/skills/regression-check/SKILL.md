---
name: regression-check
description: "Verify hardening measures from past PMRs still hold by checking tests, types, and error boundaries."
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
---

# Regression Check

Verify that hardening measures from past Postmortem Records still hold — checks that specified tests exist, branded types are enforced, error boundaries are in place, and checklists were followed. Uses static analysis only (no test execution). Produces a pass/fail report and flags regressions with file:line evidence.

---

## Triggers

```
/regression-check [pmr-id]
/regression-check --all
/regression-check --scope <file-or-directory>
```

**Examples:**
```bash
/regression-check PMR-2026-001
/regression-check --all
/regression-check --scope components/loan/
```

**Arguments:**
- `[pmr-id]` — Check hardening for a specific PMR (optional)
- `--all` — Check all resolved PMRs with `implemented` or `verified` hardening actions
- `--scope <path>` — Check all PMRs whose blast radius includes files in this path

---

## When to Use

- Periodically (weekly) to verify hardening hasn't degraded
- Before merging a PR that touches files in a known blast radius
- After a refactoring that may have removed or bypassed defensive measures
- To promote hardening actions from `implemented` to `verified` status
- When `correlating` detects a pattern recurrence from a past incident

---

## Workflow

### Step 1: Load PMRs

Based on input, load the target PMR(s):

| Input | Action |
|-------|--------|
| Specific PMR ID | Load `grimoires/hardening/pmr/{pmr-id}.md` |
| `--all` | Load all PMRs with status `resolved` from `grimoires/hardening/pmr/` |
| `--scope <path>` | Load all PMRs whose blast radius table includes files matching the path |

Filter to hardening actions in `implemented` or `verified` status. Skip actions still in `proposed` or `accepted` status (not yet implemented, nothing to check).

### Step 2: Static Verification

For each hardening action, verify its implementation using static analysis only. The construct does NOT run tests or CI pipelines.

#### Test Specs (action_type: `test-spec`)

1. Does the specified test file exist?
   ```
   Glob: **/{expected_test_file}
   ```
2. Does it contain test cases matching the specification?
   ```
   Grep: describe|it|test.*{scenario_keywords} in test file
   ```
3. Do test fixtures use production-realistic data shapes?
   ```
   Grep: "80094_backing_" or compound ID patterns in test fixtures
   ```
4. Flag `needs_ci_run: true` if the test file has been modified since the last CI run
   ```bash
   git log -1 --format=%H -- {test_file}
   ```

**Status determination:**
- Test file exists + relevant test cases found + realistic fixtures → `passing`
- Test file exists but fixtures use placeholder data → `stale`
- Test file not found → `failing`

#### Type Specs (action_type: `type-spec`)

1. Does the branded type exist?
   ```
   Grep: type {TypeName} in **/*.ts
   ```
2. Is it used at the specified boundary?
   ```
   Grep: {TypeName} in {boundary_file}
   ```
3. Are there `as any` casts bypassing it?
   ```
   Grep: as any.*{related_variable} or as unknown.*{related_variable}
   ```

**Status determination:**
- Type exists + used at boundary + no bypassing casts → `passing`
- Type exists but `as any` casts found → `failing` (defense bypassed)
- Type not found → `failing`

#### Error Boundary Specs (action_type: `error-boundary`)

1. Is the error boundary in place at the specified location?
   ```
   Grep: try|catch|ErrorBoundary|\.catch in {specified_file} near {specified_line}
   ```
2. Has new code been added inside the boundary's scope without the guard?
   ```
   Grep: BigInt\(|new Date\(|Number\( in {scope} without surrounding try/catch
   ```

**Status determination:**
- Error boundary exists + covers the specified scope → `passing`
- Error boundary removed or scope expanded without guard → `failing`
- Cannot determine → `untested`

#### Checklist Protocols (action_type: `checklist`)

1. Check git commit messages in the affected area for checklist references:
   ```bash
   git log --oneline --grep="{checklist_name}" -- {affected_files}
   ```
2. If user provides PR URLs, optionally use `gh pr view` for checklist evidence
3. Mark as `unverifiable` if neither source provides evidence

**Status determination:**
- Commit/PR references checklist + checklist items addressed → `passing`
- No evidence found → `unverifiable` (not `failing` — absence of evidence is not evidence of absence)

### Step 3: Detect Drift

For each hardening action currently in `verified` status, check whether the defense has been weakened since verification:

1. **Removed**: The defensive artifact (test, type, error boundary) no longer exists at the specified location
2. **Weakened**: The defense exists but has been reduced in scope (e.g., test cases removed, `as any` cast added)
3. **Bypassed**: New code paths added that avoid the defense (e.g., new contract call site without the type guard)
4. **Stale**: The defensive artifact exists but the protected code has changed significantly since verification

Evidence must include:
- File path and line number where the drift was detected
- The specific change that weakened the defense (commit hash if determinable)
- How the defense was supposed to work vs. how it currently works

### Step 4: Update Regression Checks Table

Update the PMR's **Regression Checks** table:

| Check | Hardening Action | Method | Last Verified | Status |
|-------|-----------------|--------|---------------|--------|
| RC-1 | H1 | test-exists | {timestamp} | passing |
| RC-2 | H2 | type-check | {timestamp} | failing |

**Status values:**
- `passing` — Defense verified as present and effective
- `failing` — Defense removed, weakened, or bypassed
- `untested` — Cannot verify with static analysis alone
- `stale` — Defense exists but hasn't been re-verified after significant code changes

**Cross-table update rule:** Only update the **Hardening Actions** table status to `regressed` when a previously `verified` action's regression check transitions to `failing`. Do not change actions in `implemented` status — they haven't been verified yet, so they can't regress.

For `regressed` findings, emit event:
```bash
source .claude/scripts/lib/event-bus.sh
emit_event "forge.hardening.regression_detected" \
  '{
    "action_id": "{action_id}",
    "pmr_id": "{pmr_id}",
    "regression_type": "{removed|weakened|bypassed|stale}",
    "evidence": "{file:line description}",
    "affected_files": ["{file1}", "{file2}"]
  }' \
  "hardening/regression-check"
```

For `passing` findings on `implemented` actions, emit verification event and update status to `verified`:
```bash
emit_event "forge.hardening.action_verified" \
  '{
    "action_id": "{action_id}",
    "pmr_id": "{pmr_id}",
    "verification_method": "{method}",
    "verified_at": "{timestamp}"
  }' \
  "hardening/regression-check"
```

### Step 5: Output Report

```
REGRESSION CHECK REPORT
========================

PMR: {pmr_id} — {title}
Checked: {timestamp}
Actions Checked: {N}

Results:
  PASSING:  {N}  ████████████░░░░  {percentage}%
  FAILING:  {N}  ██░░░░░░░░░░░░░░  {percentage}%
  UNTESTED: {N}  ░░░░░░░░░░░░░░░░  {percentage}%
  STALE:    {N}  ░░░░░░░░░░░░░░░░  {percentage}%

Regressions Detected:
  H2: [FAILING] Type spec — branded OnChainLoanId bypassed by `as any` at components/loan/repay-loan.tsx:47
  H5: [FAILING] Smoke test — no commit evidence found for post-migration smoke test

Needs CI Run:
  H1: Test file modified since last CI run — recommend running test suite

Newly Verified:
  H3: Error boundary confirmed at components/loan/repay-loan.tsx:23-31

Next Steps:
  - Fix regressions: /bug (for each failing action)
  - Full signal audit: /signal-audit {scope}
  - Deep analysis: /postmortem (if regression indicates new incident)
```

---

## Counterfactuals — Verification Accuracy & Defense Persistence

Regression checking verifies that past hardening measures still hold. The failure modes involve either accepting shallow evidence of defense presence or checking the wrong properties of the defense.

### Target (Correct Behavior)

When checking the Envio incident's hardening actions, the skill verifies H1 (frontend integration tests) by finding the test file, confirming it contains test cases that use compound Envio IDs (`"80094_backing_157"`), and checking that the fixtures match production data shapes. It does not merely confirm the test file exists — it confirms the test *tests the right thing with the right data*.

For H2 (branded types), the check finds `OnChainLoanId` type definition, confirms it's used in `repay-loan.tsx` at the contract call boundary, and searches for `as any` or `as unknown` casts that would bypass the type safety. Finding `BigInt(loanId as any)` anywhere in the codebase flags a regression — the type system defense was introduced but then circumvented.

For H4 (migration checklist), the check acknowledges that checklist compliance is inherently harder to verify than code artifacts. It searches commit messages and PR descriptions for checklist references, but marks the result as `unverifiable` rather than `failing` if no evidence is found. The distinction matters: `failing` means "the defense was present and is now gone." `Unverifiable` means "we cannot confirm whether the defense was applied." These are different states that require different responses.

The regression check produces a report with file:line evidence for every finding. "H2 failing" is not sufficient — "H2 failing: `as any` cast at `components/loan/repay-loan.tsx:47` bypasses `OnChainLoanId` type guard" is. The evidence allows `/bug` or `/implement` to act directly on the regression.

### Near Miss — Existence Check Without Substance Verification (Seductively Close, But Wrong)

The seductively wrong approach: checking that defensive artifacts *exist* without verifying they *defend against the specified threat*.

A regression check that confirms "test file `repay-loan.test.ts` exists, status: passing" has verified existence, not substance. The test file might:
- Exist but test the wrong thing (sort order instead of contract calls)
- Exist with correct test names but use unrealistic fixtures (`id: "loan-1"` instead of `"80094_backing_157"`)
- Exist with correct fixtures but have assertions that are always true (`expect(true).toBe(true)`)
- Have been modified to comment out the critical assertions

In the Envio incident, the original test suite had 82 passing tests and 100% pass rate — for the API route layer. The frontend component layer that actually broke had zero test coverage. An existence check would have counted those 82 tests as "defense present" while the actual vulnerability remained unguarded.

The substance verification checks three properties beyond existence:
1. **Scope**: Does the test cover the code path specified in the hardening action? (Not just any code path in the file)
2. **Realism**: Do fixtures use data shapes matching production? (Not placeholders)
3. **Assertion relevance**: Do assertions verify the specified invariant? (Not unrelated properties)

Each property requires reading the test content, not just confirming the file is on disk. An existence check runs in O(1) with Glob. A substance check requires O(n) with Read and Grep. The time difference tempts shortcuts, but an existence check that produces false confidence is worse than no check at all — it tells the team their defense holds when it doesn't, which suppresses the urgency to actually build the defense.

**Physics of Error:** Concept Impermanence — treating the *snapshot* of "test file created" as a permanent guarantee of defense. A test file is not a defense; a *correct test with realistic fixtures and relevant assertions* is a defense. The file is a container; the defense is its content. Content can change while the container persists.

### Category Error — Checking Implementation Instead of Invariant (Fundamentally Wrong)

The fundamentally wrong approach: verifying that the specific fix code is still present rather than that the defended invariant still holds.

The fix for the compound loan ID bug was `getOnChainLoanId()` in commit `48a6ce01`. A regression check that searches for `getOnChainLoanId` in `repay-loan.tsx` and confirms it's still there has checked the *implementation*, not the *invariant*. A future developer might:
- Rename the function to `extractNumericId()` — check fails, but invariant holds
- Replace the function with an inline regex — check fails, but invariant holds
- Remove the function and use a different parsing library — check fails, but invariant holds
- Keep the function but change its logic to return the wrong segment — check passes, but invariant violated

The defended invariant is: "the value passed to `BigInt()` in contract call arguments is always a numeric string, never a compound Envio ID." This invariant can be checked without knowing the implementation:
```
Grep: BigInt\( in contract call sites → verify argument is from a conversion function (any name)
Grep: compound ID pattern in BigInt arguments → should return zero matches
```

The implementation is *how* the invariant is maintained. The invariant is *what* must be true. Checking the implementation is fragile — any refactor breaks the check. Checking the invariant is robust — it holds regardless of implementation changes.

In the Envio incident, the type spec (H2) defends the invariant "compound Envio IDs cannot be passed to contract calls without conversion." Checking for the type `OnChainLoanId` is closer to invariant-checking than checking for the function `getOnChainLoanId`, because the type is the *declaration of the invariant* while the function is one *implementation of the conversion*. But even the type check is implementation-level if a developer achieves the same safety through a different mechanism (runtime validation, schema enforcement, or a different type pattern).

The regression check should prioritize invariant verification: "is it still impossible to pass a compound ID to BigInt?" over implementation verification: "does the getOnChainLoanId function still exist?"

**Physics of Error:** Coupling Inversion — depending on the specific implementation (function name, type name, code pattern) instead of the interface contract (the invariant that must hold). Implementations change during refactors, library upgrades, and feature additions. Invariants persist — or if they don't, that's the actual regression.

---

## Validation

After regression check:
- [ ] All target PMR(s) loaded and their hardening actions enumerated
- [ ] Each `implemented` or `verified` action checked with appropriate method
- [ ] Each finding includes file:line evidence (not just pass/fail status)
- [ ] `failing` status only assigned when defense was previously present and is now absent/weakened
- [ ] `unverifiable` used for checklist protocols where static analysis is insufficient
- [ ] `needs_ci_run` flag set when test files changed since last verification
- [ ] Regression Checks table updated in PMR file
- [ ] Hardening Actions table updated only for `verified` → `regressed` transitions
- [ ] Events emitted for all regressions and new verifications
- [ ] Report includes actionable next steps

---

## Error Handling

| Error | Resolution |
|-------|------------|
| PMR not found | List available PMRs, prompt for correct ID |
| PMR has no hardening actions | Report "no actions to check" — suggest running `/harden` first |
| All actions still in `proposed` status | Report "no implemented actions to verify" — nothing to check yet |
| File referenced in hardening action no longer exists | Flag as `failing` with "file removed" evidence |
| Git history unavailable for drift detection | Perform current-state check only, note "drift detection unavailable" |
| `--scope` matches no PMR blast radii | Report "no PMRs cover this scope" — suggest running `/signal-audit` |

---

## Integration Points

- **PMRs**: Reads from `grimoires/hardening/pmr/` — all data comes from PMR hardening actions
- **`/postmortem`**: A regression creates a new incident signal, may warrant new PMR
- **`/harden`**: If regression detected, may need to regenerate or update action specs
- **CI integration**: Can be wired into GitHub Actions to check on PRs touching blast radius files
- **`correlating`**: Regression patterns feed into cross-incident correlation

---

## Related

- `/postmortem` — Create PMR with hardening actions (source of regression check targets)
- `/harden` — Generate or update hardening action specifications
- `/signal-audit` — Broader coverage audit beyond PMR-specific hardening
- `/blast-radius` — Map files that should trigger regression checks on change
