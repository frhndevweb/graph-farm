#!/usr/bin/env bash
# ==============================================================================
# Graph Farm v2 - Farm Commit Engine
# File: scripts/commit.sh
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/utils.sh
source "${SCRIPT_DIR}/utils.sh"

FARM_ID="$1"

if [[ -z "$FARM_ID" ]]; then
    echo "Usage: bash scripts/commit.sh <farm_id>" >&2
    exit 1
fi

validate_farm_id "$FARM_ID"

LOG_DIR="logs"
ARCHIVE_DIR="logs/archive"
STATS_DIR="stats"
DATA_DIR=".farm"

ensure_dir "$LOG_DIR"
ensure_dir "$ARCHIVE_DIR"
ensure_dir "$STATS_DIR"
ensure_dir "$DATA_DIR"

COUNT_FILE="$DATA_DIR/farm${FARM_ID}.count"
COUNT=$(read_counter "$COUNT_FILE")
COUNT=$((COUNT + 1))
write_counter "$COUNT_FILE" "$COUNT"

# Determine active log file according to 1,000-commit rotation policy
LOG_INDEX=$(compute_log_index "$COUNT")
LOG_FILE=$(get_log_path "$FARM_ID" "$LOG_INDEX")
NOW=$(get_timestamp)

# Write structured log entry
cat << EOF >> "$LOG_FILE"

==========================================
Time   : $NOW
Farm   : $FARM_ID
Commit : #$COUNT
Status : SUCCESS
==========================================

EOF

# Rotate and prune archives if in archive mode (keep up to 20 archives)
if [[ "$LOG_INDEX" -gt 1 ]]; then
    rotate_and_prune_archives "$FARM_ID" 20
fi

# Write updated statistics JSON
STATS_FILE="$STATS_DIR/farm${FARM_ID}.json"
LOG_BASENAME=$(basename "$LOG_FILE")
write_stats_file "$STATS_FILE" "$FARM_ID" "$COUNT" "$NOW" "$LOG_BASENAME"

# Update repository data file with deterministic change
RANDOM_FILE="$DATA_DIR/farm${FARM_ID}.txt"
{
    echo "$NOW"
    echo "$RANDOM"
    echo "$COUNT"
} > "$RANDOM_FILE"

# Automatically synchronize README live status
if [[ -f "${SCRIPT_DIR}/update-readme.sh" ]]; then
    bash "${SCRIPT_DIR}/update-readme.sh" || echo "Warning: Could not update README.md" >&2
fi

# Output summary banner
echo ""
echo "=============================="
echo "🌱 Graph Farm v2"
echo "Farm ID   : $FARM_ID"
echo "Commit #  : $COUNT"
echo "Timestamp : $NOW"
echo "Log File  : $LOG_FILE"
echo "=============================="
echo ""
