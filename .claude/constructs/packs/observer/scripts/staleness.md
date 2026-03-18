# Canonical Staleness Function

**Single source of truth** for cognition staleness detection. Referenced by `/think` (candidate selection) and `/follow-up` (cognition loading). Both skills MUST use this definition — do not redefine inline.

```
FUNCTION check_staleness(cognition, canvas_frontmatter, growth_path, score_snapshot_raw):
  # Trigger 1: Cycle count
  IF exists(growth_path):
    growth = read_yaml(growth_path)
    current_cycle_index = len(growth.follow_ups)
    IF current_cycle_index - cognition.distilled_at_cycle_index >= cognition.stale_after_cycles:
      RETURN true

  # Trigger 2: New feedback
  IF canvas_frontmatter.last_enriched > cognition.input_anchors.canvas_last_enriched:
    RETURN true

  # Trigger 3: Growth state changed
  IF exists(growth_path):
    current_growth_hash = sha256(read_file(growth_path))
    IF current_growth_hash != cognition.input_anchors.growth_state_hash:
      RETURN true

  # Trigger 4: Score snapshot changed (skip if unavailable)
  IF score_snapshot_raw is not null AND score_snapshot_raw != "unavailable":
    current_score_hash = sha256(score_snapshot_raw)
    IF current_score_hash != cognition.input_anchors.score_snapshot_hash:
      RETURN true

  RETURN false
```

## Score API Unavailability

When score API is down, `score_snapshot_hash` is set to the sentinel `"unavailable"`. Staleness checks skip the score trigger when the current snapshot is also unavailable, preventing churn.

## Atomic Write Contract

All skills writing to `grimoires/observer/` MUST use the atomic write pattern:

```bash
write_yaml("${path}.tmp", content)
mv("${path}.tmp", path)  # atomic rename on POSIX
```

### Crash Recovery

If the process crashes between `write_yaml` and `mv`, an orphaned `.tmp` file remains. On startup or next run, skills SHOULD clean up stale `.tmp` files:

```bash
# Clean up orphaned .tmp files older than 5 minutes
find grimoires/observer/ -name "*.tmp" -mmin +5 -delete 2>/dev/null
```

This is safe because:
- Active `.tmp` files are written and renamed within seconds
- Any `.tmp` older than 5 minutes is from a crashed run
- The source file (without `.tmp`) is the last known good state
