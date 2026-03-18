# /snapshot — MiDi Experience Record (MER) Capture

Capture a point-in-time MER for a wallet. Produces a 4-layer snapshot: data state, visual screenshot, user perception, and decision context.

## Usage

```
/snapshot <wallet-or-alias>
/snapshot xabbu --trigger feedback
/snapshot xabbu --data-only
/snapshot --cohort
/snapshot --cohort --diff MER-2026-001
```

## Arguments

| Argument | Description | Required |
|----------|-------------|----------|
| `wallet-or-alias` | Wallet address or alias from wallets.yaml | Yes (unless --cohort) |
| `--trigger` | Trigger type: feedback, model-bump, issue-creation, manual, ecosystem-event | No (default: manual) |
| `--data-only` | Suppress visual capture (data + perception only) | No |
| `--cohort` | Process all wallets from wallets.yaml | No |
| `--diff MER-ID` | Compare against baseline MER | No (P3) |

## Pipeline (12 Steps)

### Step 1: Parse Arguments

Parse the invocation arguments:
- Extract `wallet_or_alias` from first positional argument
- Extract `--trigger` value (default: `manual`)
- Check for `--data-only`, `--cohort`, `--diff` flags

If `--cohort` is specified:
- Read all wallets from `grimoires/observer/wallets.yaml`
- Process each wallet sequentially through Steps 2–12
- LOW-weight wallets are skipped (no MER created) per Step 5
- Print summary at end: "N MERs created for M wallets (S skipped as LOW)"

```bash
# --cohort mode: iterate all tracked wallets
if [[ "$cohort_mode" == "true" ]]; then
    wallets=$(yq -r '.wallets | keys[]' grimoires/observer/wallets.yaml 2>/dev/null || echo "")
    if [[ -z "$wallets" ]]; then
        echo "ERROR: No wallets found in grimoires/observer/wallets.yaml" >&2
        exit 1
    fi

    total=0
    created=0
    skipped_low=0

    for alias in $wallets; do
        total=$((total + 1))
        echo "Processing wallet $total: $alias..." >&2

        # Execute Steps 2-12 for this wallet
        # wallet_or_alias="$alias"
        # trigger="${trigger:-manual}"  (from --trigger arg or default)
        # data_only="${data_only:-false}"
        #
        # Step 5 will exit early for LOW wallets — catch and count
        # If MER created: created++
        # If skipped (LOW): skipped_low++
    done

    echo "" >&2
    echo "Cohort snapshot complete:" >&2
    echo "  $created MERs created for $total wallets ($skipped_low skipped as LOW)" >&2
    exit 0
fi
```

If `--diff` is specified:
- Read the baseline MER from `grimoires/observer/timeline/{MER-ID}.md`
- Extract baseline data state from frontmatter (combined_score, og_score, nft_score, onchain_score, overall_rank, crowd_tier, elite_tier)
- After Step 4 (fetch current data), generate a comparison table
- Include before/after screenshots if visual layer available in both MERs

```bash
# --diff mode: compare current state against baseline MER
if [[ -n "$diff_baseline" ]]; then
    baseline_file="grimoires/observer/timeline/${diff_baseline}.md"
    if [[ ! -f "$baseline_file" ]]; then
        echo "ERROR: Baseline MER not found: $baseline_file" >&2
        exit 1
    fi

    # Extract baseline data from the body's Data State markdown table
    # Format: "| Metric | Value |" — extract the Value column
    extract_data_state() {
        local file="$1" metric="$2"
        awk -v m="$metric" '/## Data State/,/^$/{if($0 ~ "\\| "m" \\|"){split($0,a,"|"); gsub(/^[ \t]+|[ \t]+$/,"",a[3]); print a[3]}}' "$file"
    }

    baseline_combined=$(extract_data_state "$baseline_file" "Combined Score")
    baseline_og=$(extract_data_state "$baseline_file" "OG Score")
    baseline_nft=$(extract_data_state "$baseline_file" "NFT Score")
    baseline_onchain=$(extract_data_state "$baseline_file" "Onchain Score")
    baseline_rank=$(extract_data_state "$baseline_file" "Overall Rank")
    baseline_crowd=$(extract_data_state "$baseline_file" "Crowd Tier")
    baseline_elite=$(extract_data_state "$baseline_file" "Elite Tier")

    # Screenshot URL is in frontmatter: wallets[0].visual_snapshots.profile
    baseline_screenshot=$(awk '/visual_snapshots:/,/profile:/{if(/profile:/){gsub(/.*profile: */,""); gsub(/"/,""); print}}' "$baseline_file")
fi
```

After Step 4, the diff comparison table is generated and included in the MER body (after Data State, before Visual Evidence):

```markdown
## Model Diff: vs {baseline_mer_id}

| Metric | Baseline | Current | Delta |
|--------|----------|---------|-------|
| Combined Score | {baseline} | {current} | {+/-delta} |
| OG Score | {baseline} | {current} | {+/-delta} |
| NFT Score | {baseline} | {current} | {+/-delta} |
| Onchain Score | {baseline} | {current} | {+/-delta} |
| Overall Rank | #{baseline} | #{current} | {+/-delta} |
| Crowd Tier | {baseline} | {current} | {changed/unchanged} |
| Elite Tier | {baseline} | {current} | {changed/unchanged} |
```

If both MERs have screenshots, include side-by-side visual comparison:

```markdown
### Visual Comparison

| Baseline ({baseline_mer_id}) | Current ({current_mer_id}) |
|------------------------------|---------------------------|
| ![baseline]({baseline_screenshot_url}) | ![current]({current_screenshot_url}) |
```

If either MER lacks a screenshot, show text-only comparison with a note.

When used with `--cohort`, the diff runs per-wallet: each wallet's current state is compared against the same wallet's entry in the baseline MER set. Wallets not present in the baseline are marked as "new (no baseline)".

### Step 2: Resolve Wallet

```bash
wallet=$(scripts/observer/wallet-resolve.sh "$wallet_or_alias")
```

Extract the alias for use in filenames. If wallet-resolve.sh fails:
- Log warning: "Could not resolve wallet: $wallet_or_alias"
- Exit with message (do not create a MER for unresolvable wallets)

### Step 3: Generate MER ID

```bash
mer_id=$(scripts/observer/generate-mer-id.sh)
```

If generate-mer-id.sh fails (lock timeout):
- Log error and exit — cannot proceed without a reserved ID

### Step 4: Fetch Data Layer

```bash
data_json=$(scripts/observer/score-api-query.sh profile "$wallet" --format snapshot)
```

Store JSON sidecar for archival:
```bash
mkdir -p "grimoires/observer/timeline/snapshots/${mer_id}"
echo "$data_json" > "grimoires/observer/timeline/snapshots/${mer_id}/${alias}-data.json"
```

Extract fields for the MER Data State table:
- `combined_score`, `og_score`, `nft_score`, `onchain_score`
- `overall_rank`, `crowd_tier_display`, `elite_tier_display`

**Degradation**: If Score API is unavailable (exit 1), set all data fields to "unavailable" and continue. The MER is still valid with empty data state.

### Step 5: Classify Signal Weight

Determine signal weight from the data:
- Read `overall_rank` from data response
- Look up percentile position (rank 1 = top percentile)

Classification rules:
- **HIGH**: percentile >= 99 (top 1%)
- **MEDIUM**: percentile >= 75 (top 25%)
- **LOW**: percentile < 75 → **Do not create MER. Exit with message.**

If Score API was unavailable in Step 4:
- Default to **MEDIUM** (create MER but note degraded data)

Important: `--data-only` suppresses visual capture only. LOW wallets never produce a MER regardless of flags.

### Step 6: Capture Visual Layer

For HIGH-weight wallets only (unless `--data-only` flag is set):

```bash
has_visual=false
capture_env='{"environment":"unavailable"}'

if [[ "$signal_weight" == "HIGH" && "$data_only" != "true" ]]; then
    if metadata=$(scripts/observer/capture-screenshot.sh "$wallet" "$alias" "/tmp/${mer_id}-profile.png" 2>&1); then
        capture_env=$metadata
        has_visual=true
    else
        echo "WARNING: Screenshot capture failed — continuing with data-only MER" >&2
    fi
fi
```

The script uses QA fixture auth bypass (`sf-qa-effective-address` localStorage injection) to capture the wallet's profile page without wallet connection. Accepts optional `--base-url` for non-localhost environments.

**Degradation**: agent-browser failure → data-only MER with warning. Never halt pipeline. MEDIUM-weight wallets always skip visual capture.

### Step 7: Upload Screenshot

If capture succeeded in Step 6, upload to Supabase Storage:

```bash
screenshot_url=""

if [[ "$has_visual" == "true" ]]; then
    if url=$(scripts/observer/upload-snapshot.sh "/tmp/${mer_id}-profile.png" "${mer_id}/${alias}-profile.png" 2>&1); then
        screenshot_url="$url"
    else
        echo "WARNING: Upload failed — local cache retained" >&2
    fi
fi
```

Requires `SUPABASE_URL` and `SUPABASE_STORAGE_TOKEN` environment variables. Uses scoped storage token (NEVER service role key).

**Degradation**: Upload failure → `visual_snapshots.profile` set to null, local screenshot retained at `/tmp/${mer_id}-profile.png`. Local cache also at gitignored `grimoires/observer/timeline/snapshots/`.

### Step 8: Pull Perception Layer

Check if a canvas exists for this wallet:
```bash
canvas_path="grimoires/observer/canvas/${alias}-canvas.md"
```

If canvas exists:
- Extract latest user quotes (look for `>` blockquotes)
- Extract feedback entries and expectation gaps
- Populate the User Signals and Perception vs Reality sections

If canvas does not exist:
- Note "No canvas exists for this wallet" in User Signals section
- Leave Perception vs Reality table with placeholder values

### Step 9: Generate MER Markdown

1. Read the MER template: `.claude/constructs/packs/observer/templates/mer-template.md`
2. Replace all `{{PLACEHOLDER}}` values with actual data:

| Placeholder | Source |
|-------------|--------|
| `{{MER_ID}}` | Step 3 output |
| `{{TITLE}}` | Generate from: "{alias} — {trigger} snapshot" |
| `{{EVENT_DATE}}` | Today's date (ISO 8601) |
| `{{DATE_RECORDED}}` | Current timestamp (ISO 8601) |
| `{{MODEL_VERSION}}` | Read from Score API response or "unknown" |
| `{{OWNER}}` | "observer" |
| `{{TRIGGER}}` | From --trigger argument |
| `{{SIGNAL_WEIGHT}}` | Step 5 classification |
| `{{WALLET_ADDRESS}}` | Step 2 resolved address |
| `{{WALLET_ALIAS}}` | Step 2 alias |
| `{{LOCAL_CACHE_PATH}}` | `grimoires/observer/timeline/snapshots/${mer_id}/${alias}-data.json` |
| `{{SCREENSHOT_URL}}` | Step 7 URL or null |
| `{{ERA}}` | null (future use) |
| `{{CORE_CONVICTION}}` | From canvas or "To be determined" |
| `{{CAPTURE_*}}` | Step 6 metadata or null |
| `{{COMBINED_SCORE}}`, etc. | Step 4 data fields |
| `{{CONTEXT_DESCRIPTION}}` | Generate brief context sentence |
| `{{USER_QUOTE}}` | Step 8 extracted quote or "No user signals captured" |
| `{{QUOTE_SOURCE}}` | Canvas path or "N/A" |
| `{{EXPECTED}}`, `{{ACTUAL}}`, `{{GAP_TYPE}}` | Step 8 perception data or placeholders |
| `{{CORE_CONVICTION_ANSWER}}` | From canvas or "Record only" |
| `{{TARGET_AUDIENCE}}` | Infer from wallet tier or "General participant" |
| `{{COMMUNITY_PULSE}}` | From canvas quotes or "No community signal" |
| `{{ONE_LESSON}}` | "Record only — first snapshot" for initial MERs |
| `{{STATE_DIAGRAM}}` | Simple state node or "stateDiagram-v2\n  [*] --> Captured" |

3. Handle conditional sections:
   - If `has_visual == true`: render `{{#IF_VISUAL}}` block, remove `{{#IF_NO_VISUAL}}` block
   - If `has_visual == false`: render `{{#IF_NO_VISUAL}}` block, remove `{{#IF_VISUAL}}` block

4. Write to temp path:
```
grimoires/observer/timeline/.${mer_id}.tmp.md
```

5. Validate the generated MER:
```bash
scripts/observer/validate-mer.sh --instance "grimoires/observer/timeline/.${mer_id}.tmp.md"
```

If validation fails, log error and exit (do not commit invalid MER).

### Step 10: Atomic Commit (INDEX + MER)

Use commit-mer.sh for atomic INDEX.json entry + MER file placement:

```bash
final_path=$(scripts/observer/commit-mer.sh \
  "$mer_id" \
  "$event_date" \
  "$title" \
  "$trigger" \
  "$alias" \
  "$signal_weight" \
  "grimoires/observer/timeline/.${mer_id}.tmp.md")
```

If commit-mer.sh fails:
- Exit code 1 (lock timeout): retry once after 2s, then fail
- Exit code 2 (write failure): log error, clean up temp file, exit

### Step 11: Emit Event

Emit `observer.snapshot_captured` after MER write AND INDEX update succeed:

```bash
source .claude/scripts/lib/event-bus.sh

# Build layers_captured array dynamically
layers="[\"data\""
if [[ "$has_visual" == "true" ]]; then
    layers="${layers},\"visual\""
fi
if [[ -f "$canvas_path" ]]; then
    layers="${layers},\"perception\""
fi
layers="${layers}]"

# Build payload
payload=$(cat <<PAYLOAD
{
  "target": {"type": "wallet", "selector": "wallet:${wallet_address}"},
  "signal": {
    "mer_id": "${mer_id}",
    "trigger": "${trigger}",
    "signal_weight": "${signal_weight}",
    "layers_captured": ${layers},
    "screenshot_url": ${screenshot_url:+\"$screenshot_url\"}${screenshot_url:-null},
    "canvas_exists": $([ -f "$canvas_path" ] && echo true || echo false)
  },
  "idempotency_key": "${mer_id}:${wallet_address}:${trigger}:${event_date}"
}
PAYLOAD
)

# Emit — failure must not block the pipeline
if emit_event "observer.snapshot_captured" "$payload" "observer/snapshotting" "${correlation_id:-}"; then
    echo "Event emitted: observer.snapshot_captured" >&2
else
    echo "WARNING: Event emission failed — MER is still valid" >&2
fi
```

**Payload matches `snapshot-event.schema.json`**: target (wallet selector), signal (mer_id, trigger, signal_weight, layers_captured, screenshot_url, canvas_exists), idempotency_key.

`layers_captured` is built dynamically from actual capture results (e.g., `["data"]` when visual skipped, `["data","visual","perception"]` when all layers succeed).

`event_date` in idempotency key is sourced from the MER frontmatter `event_date` field (ISO 8601 date, set at MER creation time in Step 9).

**Degradation**: Emission failure → MER still written, just not broadcast. Log warning.

### Step 12: Summary

Print completion summary:

```
MER Created: ${mer_id}
Path: grimoires/observer/timeline/${mer_id}.md
Wallet: ${alias} (${wallet_address})
Trigger: ${trigger}
Weight: ${signal_weight}
Layers: ${layers_captured}
Visual: ${screenshot_url:-"unavailable"}
Event: skipped (P0)
```

Where `layers_captured` is built dynamically:
- Always includes `"data"` (unless Score API unavailable)
- Includes `"visual"` if `has_visual == true`
- Includes `"perception"` if canvas exists

## Consumer Entry: `observer.feedback_captured`

Registered in manifest as consumer group `snapshotting` with `pull` delivery. The event bus routes `observer.feedback_captured` events to this skill.

### Handler Function

Define a handler function and pass it to `consume_events`. The handler receives one CloudEvents JSON object via stdin per invocation.

```bash
source .claude/scripts/lib/event-bus.sh

handle_snapshot_trigger() {
    local event
    read -r event

    # === Extract fields ===
    # Envelope fields (CloudEvents standard)
    local event_source
    event_source=$(echo "$event" | jq -r '.source // empty')
    local correlation_id
    correlation_id=$(echo "$event" | jq -r '.id // empty')

    # Data payload fields (per grimoires/shared/feedback/schema.json)
    local target_selector
    target_selector=$(echo "$event" | jq -r '.data.target.selector')
    local user_tier
    user_tier=$(echo "$event" | jq -r '.data.context.user_tier // "medium"')
    local resolved_wallet
    resolved_wallet=$(echo "$event" | jq -r '.data.subject.wallet // empty')
```

### Loop Prevention (SKP-007)

**CRITICAL**: This is a self-consumption pattern (same pack emits `feedback_captured` and consumes it). The `.source` field in the CloudEvents envelope identifies the emitting skill (e.g., `"observer/snapshotting"`).

```bash
    # MUST check envelope .source to prevent infinite loops
    if [[ "$event_source" == "observer/snapshotting" ]]; then
        echo "SKIP: Ignoring feedback_captured from snapshotting (loop prevention SKP-007)" >&2
        return 0
    fi
```

### Resolve Wallet

Feedback events use `target.type: "user"` with `target.selector: "user:{username}"` format. If the event has a resolved wallet in `subject.wallet`, use that directly. Otherwise, extract the username alias for wallet-resolve.sh.

```bash
    # Prefer resolved wallet from subject (when resolution_status=resolved)
    local wallet_or_alias
    if [[ -n "$resolved_wallet" ]]; then
        wallet_or_alias="$resolved_wallet"
    else
        # Feedback target uses "user:{username}" format — extract alias
        wallet_or_alias=$(echo "$target_selector" | sed 's/^user://')
    fi
```

### Map Signal Weight

The feedback schema uses `context.user_tier` (high/medium/low string derived from rank) rather than an explicit signal weight enum. Map to MER signal weight classification.

```bash
    # Map user_tier to signal weight (per SDD §10.2 routing table)
    local signal_weight
    case "$user_tier" in
        high)   signal_weight="HIGH" ;;
        medium) signal_weight="MEDIUM" ;;
        low|*)  signal_weight="LOW" ;;
    esac
```

### Idempotency Guard

Before creating a MER, check if one already exists for this wallet+trigger+date combination.

```bash
    local event_date
    event_date=$(date -u +"%Y-%m-%d")

    # Resolve to actual wallet address for idempotency check
    local wallet_address
    wallet_address=$(scripts/observer/wallet-resolve.sh "$wallet_or_alias" 2>/dev/null || echo "")
    if [[ -z "$wallet_address" ]]; then
        echo "SKIP: Could not resolve wallet for $wallet_or_alias" >&2
        return 0
    fi

    # Check INDEX.json for existing MER with same wallet + trigger + date
    local existing
    existing=$(jq -r --arg alias "$wallet_or_alias" --arg date "$event_date" \
        '.entries[] | select(.trigger == "feedback") | select(.date == $date) | select(.wallets == $alias)' \
        grimoires/observer/timeline/INDEX.json 2>/dev/null || true)

    if [[ -n "$existing" ]]; then
        echo "SKIP: MER already exists for ${wallet_or_alias}:feedback:${event_date}" >&2
        return 0
    fi
```

### Routing

```bash
    case "$signal_weight" in
        HIGH)
            # Full snapshot with visual capture
            echo "Triggering: /snapshot $wallet_or_alias --trigger feedback" >&2
            # Execute Steps 2-12 of this SKILL.md with:
            #   wallet_or_alias="$wallet_or_alias"
            #   trigger="feedback"
            #   data_only="false"
            #   correlation_id="$correlation_id"
            ;;
        MEDIUM)
            # Data-only snapshot (no visual capture)
            echo "Triggering: /snapshot $wallet_or_alias --trigger feedback --data-only" >&2
            # Execute Steps 2-12 with:
            #   wallet_or_alias="$wallet_or_alias"
            #   trigger="feedback"
            #   data_only="true"
            #   correlation_id="$correlation_id"
            ;;
        LOW|*)
            # LOW weight never creates MERs — log and skip
            echo "SKIP: LOW weight feedback for $wallet_or_alias (no MER created)" >&2
            return 0
            ;;
    esac
}

# Invoke the consumer — processes all pending events from offset
consumed_count=$(consume_events "observer.feedback_captured" handle_snapshot_trigger "snapshotting")
echo "Processed $consumed_count feedback events for snapshot triggers" >&2
```

### Routing Summary

| User Tier | Signal Weight | Action | Visual Capture |
|-----------|---------------|--------|----------------|
| high | HIGH | `/snapshot {wallet} --trigger feedback` | Yes |
| medium | MEDIUM | `/snapshot {wallet} --trigger feedback --data-only` | No |
| low | LOW | Skip (log only) | N/A |

## Degradation Summary

| Dependency | Available | Unavailable | Behavior |
|------------|-----------|-------------|----------|
| Score API | Full data layer | Empty data table + note | MER created, MEDIUM default |
| agent-browser | Screenshots captured | No visual layer | Data-only MER (P1+) |
| Supabase Storage | Screenshots uploaded | Upload failed | Null URL, local cache (P1+) |
| Canvas | Perception layer filled | "No canvas" note | MER without quotes |
| Event bus | Event emitted | No emission | MER still written (P2+) |

Every dependency failure produces a degraded but valid MER. The pipeline never halts.
