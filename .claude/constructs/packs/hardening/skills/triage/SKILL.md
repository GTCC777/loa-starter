---
name: triage
description: "Rapid severity assessment connecting user reports to affected code with blast radius estimate."
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
---

# Triage

Rapid severity assessment that connects a user report, error log, or Discord message to affected code paths and estimates blast radius. Produces a triage card with severity classification and recommended next action — not a full postmortem, but enough to decide whether to invoke `/bug`, `/postmortem`, or `/blast-radius`.

---

## Triggers

```
/triage <signal>
/triage <signal> --source <discord|github|error-log|user-report>
```

**Examples:**
```bash
/triage "users can't repay loans, BigInt error in console"
/triage "activity page shows 56 years ago for all entries" --source discord
/triage "https://github.com/0xHoneyJar/mibera-interface/issues/58"
/triage "SyntaxError: Cannot convert 80094_backing_157 to a BigInt"
```

**Arguments:**
- `<signal>` — User report text, error stack trace, GitHub issue URL, or Discord message (required)
- `--source` — Signal origin for tracking (optional, auto-detected if URL provided)

---

## When to Use

- A user reports something is broken in Discord, Telegram, or GitHub
- An error appears in logs or monitoring that needs quick assessment
- Before deciding whether to invoke `/bug` (fix it) or `/postmortem` (analyze it deeply)
- When you need to quickly estimate how many users or code paths are affected
- When Observer surfaces a canvas with severity signals

---

## Workflow

### Step 1: Parse Signal

Accept the input and classify its format:

| Input Format | Detection | Extraction |
|-------------|-----------|------------|
| GitHub issue URL | Starts with `https://github.com` | Use `gh issue view` for title, body, comments |
| Stack trace | Contains `Error:`, `at `, file:line patterns | Extract error type, file paths, line numbers |
| Discord message | Free text with user language | Extract symptom, affected feature, user ID |
| Error log | Structured log format | Extract timestamp, error code, affected service |

Extract from the signal:
- **Symptom**: What the user or system reports as broken
- **Affected feature**: Which product capability (loans, activity, marketplace, backing)
- **Timestamp**: When the issue was reported or observed
- **Error details**: Stack trace, error message, or behavioral description

### Step 2: Locate Code

Use Grep/Glob to find code paths related to the reported symptom:

1. **From error**: If stack trace provided, read the referenced files directly
2. **From feature name**: Search for component files matching the affected feature
   ```
   Glob: components/{feature}/**/*.tsx
   Grep: {symptom keywords} in app/, components/, lib/
   ```
3. **From data flow**: Trace from UI component → API route → data source
   - Find the component that renders the broken UI
   - Find the API route that feeds it data
   - Find the data source (Envio, Supabase, contract) that provides raw data

### Step 3: Estimate Severity

Apply severity classification based on four dimensions:

| Dimension | CRITICAL | HIGH | MEDIUM | LOW |
|-----------|----------|------|--------|-----|
| **Financial risk** | Funds at risk, liquidation possible | Transaction failures | Incorrect amounts displayed | Minor rounding |
| **User count** | All users of feature | Most users | Some users | Edge cases |
| **Workaround** | None | Complex workaround | Simple workaround | Obvious alternative |
| **Data integrity** | Corruption, wrong contract calls | Silent failures | Stale data | Cosmetic |

The highest dimension determines overall severity. Document which dimension drove the classification.

### Step 4: Quick Blast Radius

Identify the top 5-10 files most likely affected:

1. Find all files that import from or depend on the broken code path
2. Check `git blame` for recent changes in those files (last 30 days)
3. Classify each file by impact type:
   - **Direct**: Contains the bug or directly consumes broken data
   - **Indirect**: Depends on a direct consumer
   - **Display**: Shows broken data to users
   - **Contract**: Passes broken data to smart contracts (highest risk)

### Step 5: Output Triage Card

Write triage summary to stdout (not persisted unless explicitly requested):

```
TRIAGE CARD
===========

Signal: {original signal text, truncated to 200 chars}
Source: {discord | github | error-log | user-report}
Assessed: {current timestamp}

Severity: {CRITICAL | HIGH | MEDIUM | LOW}
Rationale: {which dimension drove the severity + one-sentence explanation}

Affected Code Paths:
  1. {file:line} — {description}
  2. {file:line} — {description}
  ...

Quick Blast Radius:
  - {N} files directly affected
  - {N} files indirectly affected
  - Contract interaction risk: {YES/NO}
  - Recent changes in blast radius: {YES/NO + commit refs}

Recommended Action:
  - {/bug — for immediate fix}
  - {/postmortem — for deep analysis after fix}
  - {/blast-radius <commit> — for full impact mapping}
  - {Monitor / defer — for low severity}
```

If severity is CRITICAL or HIGH, include a recommendation to invoke `/bug` with the triage card context.

Emit event:
```bash
source .claude/scripts/lib/event-bus.sh
emit_event "forge.hardening.triage_completed" \
  '{
    "signal_source": "{source}",
    "severity": "{severity}",
    "affected_paths": [{paths}],
    "recommended_action": "{action}"
  }' \
  "hardening/triage"
```

---

## Counterfactuals — Severity Assessment & Code Path Tracing

Triage requires rapid, accurate mapping from symptom to cause. The failure modes involve either misjudging severity by confusing symptom with root cause, or tracing the wrong code path because the symptom's location differs from the bug's location.

### Target (Correct Behavior)

When triaging the Envio migration regression, the skill receives a signal like "users can't repay loans" or a stack trace containing `SyntaxError: Cannot convert 80094_backing_157 to a BigInt`. The correct triage traces from the symptom (failed loan repayment) through the UI component (`repay-loan.tsx`) to the contract call path (`BigInt(loanId)`) to the data source (Envio API returning compound IDs).

The severity assessment lands on CRITICAL because the financial risk dimension is at maximum — users with active loans cannot repay them, which means they face liquidation. The "user count" dimension might suggest MEDIUM (only users with active loans near expiry), but the financial risk dimension overrides. This is the correct behavior: severity is determined by the *worst-case* dimension, not the average.

The blast radius correctly identifies 8 files across 3 bug categories, including files that don't appear in the stack trace at all (like `expired-loans-counter.tsx` which has the same compound ID bug but in a different code path). The triage card flags "Contract interaction risk: YES" because the broken data reaches `BigInt()` calls that feed into smart contract transactions.

The recommended action is `/bug` for immediate fix, followed by `/postmortem` for full analysis — this two-step recommendation reflects that stopping user harm takes priority over understanding the full failure.

### Near Miss — Symptom-Level Severity (Seductively Close, But Wrong)

The seductively wrong approach: assessing severity based on the visible symptom rather than the underlying failure mode.

Consider two signals from the same incident:
1. "Activity page shows '56 years ago' for all entries"
2. "Users can't repay loans"

Signal 1 looks like MEDIUM — cosmetic issue, functionality not broken, workaround exists (ignore the timestamp). Signal 2 looks CRITICAL — financial risk, no workaround. But both signals originate from the same root cause: the Envio migration changed data formats without updating all consumers.

The near miss triages each signal independently and produces two separate triage cards with different severities. This is technically correct for each symptom but structurally wrong because it misses that Signal 1 is a *sentinel* for Signal 2. The timestamp bug (seconds vs. milliseconds) reveals that data format assumptions changed — which means any other format-sensitive operation (like `BigInt()` parsing) is also suspect.

A triage that stops at the symptom says "fix the timestamp display." A triage that traces to the root cause says "check every data format assumption downstream of the Envio migration." The first fixes one bug. The second finds three.

The detection signal: when a triage finds a format conversion error (timestamp unit, ID format, encoding), always check whether the same data source feeds other format-sensitive operations in the codebase. A single format mismatch is rarely isolated.

**Physics of Error:** Semantic Drift — applying the concept of "severity" to the symptom's surface appearance rather than to the underlying failure's blast radius. A cosmetic symptom can be a high-severity sentinel if it indicates a class of format mismatches that include non-cosmetic failures.

### Category Error — Component-Level Triage (Fundamentally Wrong)

The fundamentally wrong approach: triaging at the component level instead of the data flow level.

A component-level triage receives "BigInt error in repay-loan.tsx" and scopes the investigation to `repay-loan.tsx` alone. It finds the `BigInt(loanId)` call, sees that `loanId` is a string from the API, and concludes: severity HIGH, blast radius = 1 file, fix = add parseInt before BigInt.

This misses the structural truth of the incident. The bug is not in `repay-loan.tsx` — it's in the *boundary* between the Envio API response format and every frontend consumer that performs type-sensitive operations on the response data. `repay-loan.tsx` is one consumer. `expired-loans-counter.tsx` is another. `purchase-dialog.tsx` is a third. They all have the same bug, and a component-level triage would need to independently discover each one.

The data flow level triage starts at the Envio API response, traces every consumer of the `id` field, and identifies all files that pass it to `BigInt()`, `Number()`, or `new Date()`. This produces a blast radius of 8 files from a single trace — not 1 file with 7 unknown siblings.

The component-level approach is fundamentally wrong because it treats the symptom's location as the bug's location. In the Envio incident, the bug is at the API boundary (where compound IDs enter the frontend), but the symptoms appear in 8 different components. Triaging each component independently would require 8 separate triage invocations to find what one data-flow trace reveals immediately.

The concrete cost: during the 8-day silent regression window, a component-level triage of the timestamp bug ("Activity.tsx shows wrong dates") would have fixed `Activity.tsx` but left `repay-loan.tsx` broken — users still couldn't repay loans. The data-flow triage would have found both bugs in a single pass.

**Physics of Error:** Layer Violation — operating at the component layer (where symptoms appear) instead of the data flow layer (where the bug originates). Components are the wrong unit of analysis for data format regressions because the bug exists at the boundary, not at the consumer.

---

## Validation

After triage:
- [ ] Signal parsed and source identified
- [ ] At least one affected code path identified with file:line reference
- [ ] Severity classified with rationale citing the driving dimension
- [ ] Blast radius estimate includes direct and indirect files
- [ ] Contract interaction risk assessed (YES/NO)
- [ ] Recommended next action provided (`/bug`, `/postmortem`, `/blast-radius`, or monitor)
- [ ] Triage card displayed to user in structured format

---

## Error Handling

| Error | Resolution |
|-------|------------|
| Signal too vague to locate code | Ask user for more detail: affected feature, error message, or steps to reproduce |
| GitHub issue URL but `gh` CLI unavailable | Parse URL for issue number, search git log for references |
| No matching code paths found | Widen search scope, check for renamed files or recent refactors |
| Multiple unrelated code paths match | Present top candidates, ask user to confirm which is relevant |
| Cannot determine severity | Default to HIGH with note "severity unconfirmed — recommend `/postmortem` for full analysis" |

---

## Integration Points

- **Loa `/bug`**: Triage card feeds directly into bug triage as input context
- **Observer**: `forge.observer.canvas_created` events with severity signals can trigger auto-triage
- **`/postmortem`**: High severity triage escalates to full postmortem analysis
- **`/blast-radius`**: Triage may recommend deep blast radius mapping

---

## Related

- `/postmortem` — Full incident analysis (when triage reveals HIGH/CRITICAL severity)
- `/bug` — Fix the bug (triage card provides input context)
- `/blast-radius` — Deep impact mapping (when triage blast radius estimate needs expansion)
- `/signal-audit` — Broader coverage audit (when triage reveals systemic gaps)
