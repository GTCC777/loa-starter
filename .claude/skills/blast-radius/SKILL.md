---
name: blast-radius
description: "Map impact surface of a change or regression by tracing data flow through every consumer."
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
---

# Blast Radius

Map the complete impact surface of a change, regression, or data format migration by tracing data flow from a source through every consumer to its terminal endpoints — where data reaches users, smart contracts, or external systems. Produces a structured blast radius report showing affected files, impact classification, and terminal consumers.

---

## Triggers

```
/blast-radius <commit-or-file>
/blast-radius <commit-or-file> --depth <N>
/blast-radius <commit-or-file> --pmr <pmr-id>
```

**Examples:**
```bash
/blast-radius 26ee6fa3
/blast-radius components/loan/repay-loan.tsx
/blast-radius lib/envio/client.ts --depth 3
/blast-radius 48a6ce01 --pmr PMR-2026-001
```

**Arguments:**
- `<commit-or-file>` — Commit hash, PR number, file path, or function name (required)
- `--depth <N>` — Maximum transitive dependency depth to trace (optional, default: 3)
- `--pmr <pmr-id>` — Embed output in the specified PMR's Blast Radius section (optional)

---

## When to Use

- After identifying a regression to understand its full impact surface
- Before a data source migration to preview what will break
- During `/postmortem` to populate the Blast Radius section with deep analysis
- Before refactoring a shared utility to understand downstream effects
- When a triage reveals contract interaction risk and you need the full file list

---

## Workflow

### Step 1: Identify Change Surface

Determine what changed based on the input type:

| Input | Action |
|-------|--------|
| Commit hash | `git diff {hash}~1 {hash}` — parse changed exports, types, data shapes |
| PR number | `gh pr diff {number}` — same as commit but across PR's full diff |
| File path | Read file, identify all exports and their type signatures |
| Function name | Grep for function definition, identify its return type and parameters |

Extract the **change surface**: every export, type definition, data shape, or function signature that was modified or that callers depend on.

### Step 2: Trace Consumers

For each element in the change surface, find every consumer:

1. **Direct consumers**: Files that import from the changed file
   ```
   Grep: import.*from.*{changed_file}
   Grep: require.*{changed_file}
   ```

2. **Type consumers**: Files that reference changed types
   ```
   Grep: {TypeName} in **/*.ts, **/*.tsx
   ```

3. **Data shape consumers**: Files that destructure or access changed fields
   ```
   Grep: \.{field_name} or {field_name}: in relevant files
   ```

4. **Transitive consumers**: Repeat steps 1-3 for each direct consumer, up to `--depth` levels

Build a dependency graph:
```
changed file → direct consumers → transitive consumers → terminal consumers
```

### Step 3: Classify Impact

For each consumer file, assess three dimensions:

| Dimension | Question | Risk Level |
|-----------|----------|------------|
| **Type sensitivity** | Does it perform type-sensitive operations on the changed data? (`BigInt()`, `new Date()`, `JSON.parse()`, numeric comparison) | HIGH if yes |
| **External boundary** | Does it pass data to external systems? (smart contract calls, API requests, database writes) | CRITICAL if yes |
| **User display** | Does it render data to users? (UI components, notifications, logs) | MEDIUM if yes |

Each file gets an overall impact classification:
- **CRITICAL**: Reaches smart contracts or external APIs with type-sensitive data
- **HIGH**: Type-sensitive operations that can throw or produce wrong results
- **MEDIUM**: User-facing display with incorrect or malformed data
- **LOW**: Internal processing with no user-visible or external effect

### Step 4: Generate Blast Map

Produce a structured report with:

1. **Affected Files Table**:

| File | Relationship | Impact | Type Sensitivity | External Boundary | Terminal |
|------|-------------|--------|------------------|--------------------|----------|
| `{path}` | Direct / Transitive | CRITICAL/HIGH/MEDIUM/LOW | Yes/No | Yes/No | Yes/No |

2. **Terminal Consumers**: Files where data reaches its final destination — users see it, a contract receives it, or an external API processes it. These are the highest-priority verification targets.

3. **Data Flow Diagram** (text-based):
```
{source} → {transform} → {consumer_1} → [Contract Call]
                        → {consumer_2} → [UI Display]
                        → {consumer_3} → {transitive} → [API Request]
```

4. **Severity Distribution**: Count of files by impact level.

### Step 5: Output Report

If `--pmr` flag provided, embed the blast map in the specified PMR's Blast Radius section using Edit.

Otherwise, write to stdout:

```
BLAST RADIUS REPORT
===================

Source: {commit hash / file path}
Trace Depth: {N}
Total Files Affected: {N}

Severity Distribution:
  CRITICAL: {N}  HIGH: {N}  MEDIUM: {N}  LOW: {N}

Terminal Consumers ({N}):
  1. {file:line} → [Contract Call] — {description}
  2. {file:line} → [UI Display] — {description}
  ...

Full Blast Map:
  {table}

Data Flow:
  {diagram}
```

Emit event:
```bash
source .claude/scripts/lib/event-bus.sh
emit_event "forge.hardening.blast_radius_mapped" \
  '{
    "scope": "{input}",
    "affected_file_count": {N},
    "terminal_consumer_count": {N},
    "severity_distribution": {"critical": {N}, "high": {N}, "medium": {N}, "low": {N}}
  }' \
  "hardening/blast-radius"
```

---

## Counterfactuals — Consumer Tracing & Impact Classification

Blast radius mapping requires following data from its source through every transformation to every terminal consumer. The failure modes involve either stopping the trace too early (missing consumers) or tracing the wrong dimension of the change.

### Target (Correct Behavior)

When mapping the blast radius of commit `26ee6fa3` (the Envio migration), the skill identifies the change surface: 12 API routes now return Envio entity shapes instead of subsquid shapes. The critical differences are (1) loan IDs changed from `"157"` to `"80094_backing_157"`, (2) timestamps changed from milliseconds to seconds, and (3) entity field names may differ.

The trace follows each changed API route's response to its consumers. For the loans API: `app/api/loans/route.ts` → `components/loan/repay-loan.tsx` (uses `loan.id` in `BigInt()`) → `berachain contract` (terminal consumer). This path is classified CRITICAL because the data reaches a smart contract through a type-sensitive operation (`BigInt`). A parallel trace finds `components/marketplace/expired-loans-counter.tsx` with the same pattern.

For the activity API: `app/api/activity/route.ts` → `components/activity/Activity.tsx` (uses `timestamp` in `new Date()`) → `UI display` (terminal consumer). This path is classified MEDIUM — the timestamp renders as "56 years ago" but no financial harm occurs.

The complete blast map shows 8 files across 3 bug categories, with 2 CRITICAL paths (contract calls with broken BigInt), 5 HIGH paths (wrong chain reads with missing chainId), and 1 MEDIUM path (broken timestamp display). The terminal consumers are the smart contract interface and the user-facing activity feed.

### Near Miss — Import Graph Without Data Flow (Seductively Close, But Wrong)

The seductively wrong approach: tracing the *import graph* rather than the *data flow graph*.

An import graph trace starting from `lib/envio/client.ts` finds every file that imports the Envio client — the 12 API route handlers. It then finds every file that imports from those route handlers — but in Next.js, API routes are consumed via `fetch()` calls, not ES imports. The import graph dead-ends at the route handlers because the consumer relationship crosses an HTTP boundary.

The data flow graph, by contrast, traces the response shape: what fields does the route handler return? What components consume those fields? How do those components use each field? This trace crosses the HTTP boundary because it follows the data, not the import statements.

In the Envio incident, the import graph would find 12 API route files and stop. The data flow graph continues to find the 8 frontend component files that consume the API responses — including `repay-loan.tsx` where the actual CRITICAL bug lives. The import graph correctly identifies the transform layer (API routes) but completely misses the consumer layer (frontend components).

The seduction is that import graphs are mechanically traceable — `Grep` for import statements produces exact results. Data flow graphs require understanding how Next.js API routes connect to frontend components via `fetch()` or React Query hooks. The mechanical approach produces precise but incomplete results, which is worse than a rough but complete trace because incomplete blast radius maps create false confidence that the change is contained.

The detection signal: if a blast radius trace terminates at API route handlers or data access layers without reaching UI components or contract call sites, the trace is following imports, not data. Ask: "where does this data ultimately get *used*?" If the answer is "in a component" but no components appear in the trace, the trace methodology is wrong.

**Physics of Error:** Coupling Inversion — depending on the implementation mechanism (ES import statements) instead of the interface contract (data shape consumption). The real dependency between an API route and its consumers is the response schema, not the import path. The import graph and the data flow graph diverge at every HTTP/RPC/event boundary.

### Category Error — Files Changed as Blast Radius (Fundamentally Wrong)

The fundamentally wrong approach: equating the blast radius with the files changed in the commit.

`git diff 26ee6fa3~1 26ee6fa3 --name-only` returns the 14 files modified in the Envio migration commit: 12 API route files and 2 frontend files. This is the *change surface*, not the *blast radius*. The blast radius includes every file that *consumes* the changed output — the 8 frontend components that broke because they expected subsquid data shapes but received Envio shapes.

None of the 8 broken frontend files appear in the commit's diff. They weren't modified. They didn't need to be modified during the migration. They broke because their *input* changed, not their code. This is the fundamental distinction: the blast radius of a data source change extends to every consumer of that data, not just to the files that were edited.

A blast radius report that shows "14 files changed" has the wrong numerator and the wrong denominator. The 14 changed files are the *cause*. The 8 consumer files are the *effect*. The blast radius measures the effect, not the cause. Conflating them produces a report that lists the files the developer already knows about (they just edited them) while omitting the files they need to check (the consumers they didn't edit).

In the Envio incident, the migration commit's author wrote tests for all 12 changed API routes (the cause). Zero tests covered the 8 consumer files (the effect). The test suite had 82 tests and 100% pass rate — for the wrong set of files. The blast radius analysis exists precisely to find the files that aren't in the diff but should be in the test suite.

**Physics of Error:** Semantic Collapse — reducing "blast radius" (the full impact surface including all transitive consumers) to "changed files" (the immediate modification set). This collapses a two-dimensional concept (source changes × consumer impact) to a single dimension (source changes only), losing the consumer axis entirely.

---

## Validation

After blast radius mapping:
- [ ] Change surface identified with specific exports, types, or data shapes
- [ ] Direct consumers traced with file:line references
- [ ] Transitive consumers traced up to specified depth
- [ ] Each consumer classified by type sensitivity, external boundary, and user display
- [ ] Terminal consumers explicitly identified (where data reaches users or contracts)
- [ ] Severity distribution calculated
- [ ] If `--pmr` specified, blast radius embedded in PMR file
- [ ] Data flow diagram shows the path from source to terminal consumers

---

## Error Handling

| Error | Resolution |
|-------|------------|
| Commit hash not found in git history | Check if hash is abbreviated, try `git log --all --oneline \| grep {hash}` |
| File path doesn't exist | Check for renames with `git log --follow --diff-filter=R -- {path}` |
| No consumers found for change | Verify the changed element is exported; check for dynamic imports or `fetch()` consumers |
| Trace exceeds depth limit | Report partial results, note truncation, suggest increasing `--depth` |
| PMR file not found for `--pmr` flag | List available PMRs, prompt user to verify PMR ID |

---

## Integration Points

- **`/postmortem`**: Blast radius section of PMR, invoked with `--pmr` flag
- **`/harden`**: Blast radius informs where defensive measures must be placed
- **`/triage`**: Quick blast radius during triage may escalate to full mapping
- **`/regression-check`**: Blast radius files become the check scope for regression detection

---

## Related

- `/postmortem` — Full incident analysis (blast radius is one section)
- `/harden` — Generate defenses for blast radius files
- `/triage` — Quick blast radius estimate (precedes full mapping)
- `/signal-audit` — Audit signal coverage across blast radius files
