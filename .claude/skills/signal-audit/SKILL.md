---
name: signal-audit
description: "Audit monitoring, test, type, and error handling coverage for a scope and identify gaps."
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
---

# Signal Audit

Audit what monitoring, tests, types, and error handling exist for a given scope — and what's missing. Produces a signal coverage matrix showing defense depth across four dimensions (test, type, error handling, monitoring) for every file or module in scope. Cross-references coverage against historical PMR blast radii to prioritize gaps in historically fragile code.

---

## Triggers

```
/signal-audit [scope]
/signal-audit [scope] --dimension <test|type|error|monitor>
/signal-audit --all
```

**Examples:**
```bash
/signal-audit components/loan/
/signal-audit lib/envio/ --dimension type
/signal-audit app/api/loans/
/signal-audit --all
```

**Arguments:**
- `[scope]` — Directory path, feature name, or "all" (optional, defaults to `src/` or `app/`)
- `--dimension` — Audit only a specific signal dimension (optional)
- `--all` — Audit the entire codebase

---

## When to Use

- Before a major migration or data source change to understand current coverage
- After a postmortem to identify broader signal gaps beyond the specific incident
- Periodically to track signal coverage trends across the codebase
- When planning sprint tasks to prioritize defensive measure implementation
- Before onboarding a new data source, API, or external dependency

---

## Workflow

### Step 1: Define Scope

Resolve the scope to a set of files:

| Input | Resolution |
|-------|------------|
| Directory path | All `.ts`, `.tsx`, `.js`, `.jsx` files in directory (recursive) |
| Feature name | Grep for feature-related directories: `components/{feature}/`, `app/{feature}/`, `lib/{feature}/` |
| `--all` | All source files in `src/`, `app/`, `lib/`, `components/` |

Exclude: `node_modules/`, `.next/`, `*.test.*`, `*.spec.*`, `*.d.ts`, build artifacts.

### Step 2: Inventory Tests

For each file in scope, check test coverage:

1. **Test file existence**: Does a corresponding test file exist?
   ```
   Glob: **/{filename}.test.{ts,tsx} or **/{filename}.spec.{ts,tsx}
   Glob: **/__tests__/{filename}.{ts,tsx}
   ```

2. **Test type classification**:
   | Type | Detection Pattern |
   |------|------------------|
   | Unit | Single file import, mock dependencies |
   | Integration | Multiple file imports, real dependencies, database/API calls |
   | E2E | Playwright/Cypress patterns, browser interactions |
   | Smoke | Minimal assertions, health check patterns |

3. **Fixture realism audit**: For files with tests, check if fixtures match production data shapes:
   ```
   Grep: mock|fixture|stub|fake in test files → read fixture definitions
   ```
   Flag unrealistic fixtures: simple string IDs where compound IDs are expected, hardcoded timestamps, placeholder addresses.

4. **Coverage gap**: Files with no corresponding test file are `untested`. Files with tests using unrealistic fixtures are `weakly tested`.

### Step 3: Inventory Types

For each file in scope, audit type safety:

1. **Loose types**: Count occurrences of type system escape hatches:
   ```
   Grep: : any[^_] or as any or : unknown[^)] in file
   Grep: @ts-ignore or @ts-expect-error
   Grep: !\.  (non-null assertions)
   ```

2. **Branded/opaque types at data boundaries**: Check if data entering from external sources is typed with branded types:
   ```
   Grep: Brand<|Opaque<|NewType< in type definitions
   Grep: type.*Id.*= string (loose ID types)
   ```

3. **Implicit type coercions**: Find type-sensitive operations without explicit conversion:
   ```
   Grep: BigInt\( in non-utility files → check if argument is typed
   Grep: new Date\( → check if argument has unit documentation
   Grep: Number\( or parseInt\( → check for overflow guards
   ```

4. **Type gap**: Files with `any` count > 3, or files at data boundaries without branded types, are `weakly typed`.

### Step 4: Inventory Error Handling

For each file in scope, audit error handling coverage:

1. **Try/catch blocks**: Find error handling patterns:
   ```
   Grep: try\s*\{ in file → count and check scope
   Grep: \.catch\( in file → count promise error handlers
   Grep: ErrorBoundary in JSX files → check component-level error handling
   ```

2. **Unhandled dangerous operations**: Find operations that can throw without surrounding error handling:
   ```
   Grep: BigInt\( not inside try/catch → unhandled parse errors
   Grep: new Date\( not inside try/catch → potential Invalid Date
   Grep: JSON\.parse\( not inside try/catch → unhandled parse errors
   Grep: \.json\(\) not inside try/catch → unhandled response parse errors
   ```

3. **Error surfacing**: For caught errors, check if they're surfaced to users or monitoring:
   ```
   Grep: console\.error|Sentry|toast|alert in catch blocks
   ```
   Errors caught but not surfaced (swallowed) are worse than unhandled — they hide failure.

4. **Error gap**: Files with dangerous operations outside error handlers, or with swallowed errors, are `unguarded`.

### Step 5: Inventory Monitoring

For each file or module in scope, check runtime monitoring:

1. **Error reporting integration**:
   ```
   Grep: Sentry\.|captureException|captureMessage in file
   Grep: ErrorBoundary.*fallback in JSX files
   ```

2. **Health check endpoints**:
   ```
   Glob: app/api/health*
   Grep: /health|/status|/readiness in route files
   ```

3. **CI workflows**:
   ```
   Glob: .github/workflows/*.yml → check if scope files are covered
   ```

4. **Monitoring gap**: Areas with zero runtime error capture or no CI coverage are `unmonitored`.

### Step 6: Cross-Reference with PMRs

Check if any historical PMR's blast radius overlaps the audited scope:

1. Load all PMRs from `grimoires/hardening/pmr/`
2. For each PMR, check if any file in the current scope appears in the PMR's blast radius table
3. If overlap found:
   - Flag as "historically fragile" in the coverage matrix
   - Check if the PMR's hardening actions for those files are in `verified` status
   - Flag gaps where past incidents occurred but current coverage is still insufficient

This cross-reference ensures that historically fragile code gets the highest scrutiny.

### Step 7: Output Signal Coverage Report

```
SIGNAL COVERAGE AUDIT
======================

Scope: {scope}
Files Audited: {N}
Date: {timestamp}

Coverage Matrix:
| File | Tests | Types | Error Handling | Monitoring | PMR Overlap |
|------|-------|-------|----------------|------------|-------------|
| {path} | {status} | {status} | {status} | {status} | {pmr_ids} |

Status Legend:
  ■ Strong    — Full coverage with realistic data
  ◧ Weak      — Coverage exists but has gaps (unrealistic fixtures, loose types, swallowed errors)
  □ None      — No coverage in this dimension
  ⚠ Historic  — File appears in past PMR blast radius

Summary:
  Tests:          {N} strong / {N} weak / {N} none
  Types:          {N} strong / {N} weak / {N} none
  Error Handling: {N} strong / {N} weak / {N} none
  Monitoring:     {N} strong / {N} weak / {N} none

Critical Gaps (historically fragile + uncovered):
  1. {file} — in PMR-{id} blast radius, {dimension} uncovered
  2. {file} — in PMR-{id} blast radius, {dimension} uncovered

Recommended Actions:
  - Highest priority: {files with PMR overlap + gaps}
  - Generate hardening specs: /harden {pmr-id}
  - Detailed blast radius: /blast-radius {file}
```

Write detailed report to `grimoires/hardening/signals/SIGNAL-AUDIT-{scope_slug}-{date}.md` if the audit covers more than 10 files.

---

## Counterfactuals — Coverage Assessment & Gap Prioritization

Signal auditing measures the depth of defense across multiple dimensions. The failure modes involve either measuring the wrong property of each dimension or weighting all gaps equally regardless of historical evidence.

### Target (Correct Behavior)

When auditing `components/loan/` after the Envio incident, the skill inventories all 4 dimensions for each file. For `repay-loan.tsx`, it finds:
- **Tests**: `repay-loan.test.ts` exists but tests `loan-utils.ts` helpers, not the contract call path → `weak`
- **Types**: `loanId` typed as `string` with no branded type → `weak`
- **Error Handling**: `BigInt()` call outside try/catch → `none`
- **Monitoring**: No Sentry integration in component → `none`
- **PMR Overlap**: In PMR-2026-001 blast radius → `historic`

This produces a 4-dimensional profile: `[weak, weak, none, none]` with PMR overlap. The audit correctly identifies that `repay-loan.tsx` has the worst signal coverage profile in the scope AND appears in a past incident's blast radius — making it the highest priority for hardening.

Contrast with `loan-parameter-form.tsx`, which has: `[none, weak, none, none]` with PMR overlap (missing chainId bug). This file is also high priority but for a different reason — its gap is in the type dimension (no chain ID enforcement) rather than the error handling dimension.

The audit doesn't just count gaps — it characterizes them by dimension, enabling targeted hardening. "File X needs tests" is less actionable than "File X needs an integration test that exercises the contract call path with realistic Envio compound IDs and a try/catch around the BigInt conversion."

### Near Miss — Counting Tests as Coverage (Seductively Close, But Wrong)

The seductively wrong approach: equating test *count* with test *coverage*.

The Envio migration test suite had 82 tests across 13 files, all passing. A signal audit that reports "82 tests, 100% pass rate, test coverage: strong" has measured quantity, not quality. Those 82 tests covered the API route layer — every route handler was tested with Envio response validation. Zero tests covered the frontend component layer where the actual bugs manifested.

The audit that counts tests would report `components/loan/` as having `strong` test coverage because `repay-loan.test.ts` exists with multiple test cases. But those test cases test `isLoanExpired()`, `sortLoans()`, and `filterActiveLoans()` — utility functions that didn't break. The contract call path (`BigInt(loanId)`) has zero test coverage despite sharing a file name with the utility tests.

The correct audit measures coverage per *code path*, not per *file*. A file with 50 tests for utility functions and zero tests for its primary responsibility (contract interaction) is `weakly tested`, not `strongly tested`. The signal audit must distinguish between "tests exist for this file" (existence) and "tests exist for the dangerous operations in this file" (substance).

The detection signal: if a file has tests but also appears in a PMR blast radius, the tests demonstrably failed to prevent the incident. This means either (a) the tests didn't cover the path that broke, or (b) the tests used unrealistic data. Both indicate `weak` coverage despite test existence.

**Physics of Error:** Semantic Collapse — reducing the multi-dimensional concept of "test coverage" (which code paths? with what data? testing what properties?) to a single dimension (test count). The 82-test suite had excellent quantity coverage and zero quality coverage for the paths that mattered. Collapsing these dimensions produces false confidence.

### Category Error — Auditing Available Signals Instead of Needed Signals (Fundamentally Wrong)

The fundamentally wrong approach: inventorying the signals that *exist* rather than the signals that *would detect the actual failure modes*.

A signal audit that finds "Sentry is configured, 3 error boundaries exist, CI runs on every PR" reports on the monitoring infrastructure's existence. But the question is not "what monitoring exists?" — it's "what monitoring would catch the failures that actually happen?"

In the Envio incident, the failure mode was `BigInt("80094_backing_157")` throwing a `SyntaxError`. What signal would catch this?
- **Sentry**: Only if the error boundary reports to Sentry. It didn't — there was no error boundary.
- **CI**: Only if tests exercise the `BigInt()` path with compound IDs. They didn't — fixtures used simple strings.
- **Error boundary**: Only if one exists around the contract call. It didn't.
- **Type system**: Only if `loanId` has a branded type that prevents passing compound IDs to `BigInt()`. It didn't.

An audit that reports "Sentry is configured" is technically accurate but useless — Sentry was configured globally but had no instrumentation in the component that broke. The audit must ask: "for each dangerous operation in scope, is there a signal that would fire if the operation fails?" Not: "does the project have monitoring infrastructure?"

The distinction is between *infrastructure presence* and *signal path completeness*. A project can have every monitoring tool installed and still have zero coverage for a specific failure mode because the tools aren't wired to the vulnerable code paths. The signal audit traces from failure mode to detection mechanism, not from monitoring tool to configuration file.

For the Envio incident, the correct audit would report:
- `BigInt()` in `repay-loan.tsx:32` — no error boundary, no Sentry, no type guard → 0/3 signals for SyntaxError
- `new Date()` in `Activity.tsx:34` — no unit assertion, misleading comment, no monitoring → 0/3 signals for timestamp unit error

This per-operation audit finds the exact gaps. The infrastructure-level audit ("Sentry: configured") provides false assurance.

**Physics of Error:** Semantic Drift — applying the concept of "signal coverage" to the monitoring *infrastructure* (does the tool exist?) rather than the monitoring *paths* (does the tool connect to the vulnerable operation?). Coverage applies to code paths, not to tool installations. A configured-but-unwired tool provides zero coverage for the paths it doesn't monitor.

---

## Validation

After signal audit:
- [ ] Scope resolved to a concrete file list
- [ ] Each file assessed across all 4 dimensions (test, type, error handling, monitoring)
- [ ] Test audit distinguishes existence from substance (realistic fixtures, relevant assertions)
- [ ] Type audit counts escape hatches (`any`, `as any`, `@ts-ignore`) per file
- [ ] Error handling audit identifies unguarded dangerous operations
- [ ] Monitoring audit checks signal path, not just infrastructure presence
- [ ] PMR cross-reference performed if PMRs exist
- [ ] Coverage matrix produced with file-level granularity
- [ ] Critical gaps (PMR overlap + uncovered) explicitly listed
- [ ] Report written to `grimoires/hardening/signals/` for large audits (>10 files)

---

## Error Handling

| Error | Resolution |
|-------|------------|
| Scope resolves to zero files | Suggest valid directories, check for typos in path |
| Feature name doesn't match any directory | Search for feature-related files with broader Grep |
| No PMRs exist for cross-reference | Skip PMR cross-reference, note "no historical incident data" |
| `grimoires/hardening/signals/` doesn't exist | Create directory |
| Audit scope too large (>500 files) | Suggest narrowing scope or using `--dimension` filter |

---

## Integration Points

- **`/harden`**: Signal audit identifies gaps that become hardening action specifications
- **`/postmortem`**: Signal gaps section of PMR draws from signal audit findings
- **`/regression-check`**: Signal audit reveals whether past hardening actions still hold in context
- **Sprint planning**: Coverage gaps inform sprint task prioritization
- **`/blast-radius`**: Audit scope can be defined by a blast radius report

---

## Related

- `/harden` — Generate defensive specs for identified gaps
- `/postmortem` — Full incident analysis (signal audit feeds the signal gaps section)
- `/regression-check` — Verify specific PMR hardening actions (narrower than signal audit)
- `/blast-radius` — Map impact surface to define audit scope
