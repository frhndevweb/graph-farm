#!/usr/bin/env bash
# ==============================================================================
# Graph Farm v2 - Structured Logger
# File: scripts/logger.sh
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/utils.sh
source "${SCRIPT_DIR}/utils.sh"

FARM_ID="$1"
COMMIT_NO="$2"
STATUS="${3:-SUCCESS}"

if [[ -z "$FARM_ID" || -z "$COMMIT_NO" ]]; then
    echo "Usage: bash scripts/logger.sh <farm_id> <commit_number> [status]" >&2
    exit 1
fi

validate_farm_id "$FARM_ID"

LOG_DIR="logs"
ARCHIVE_DIR="logs/archive"
ensure_dir "$LOG_DIR"
ensure_dir "$ARCHIVE_DIR"

LOG_INDEX=$(compute_log_index "$COMMIT_NO")
ACTIVE_LOG=$(get_log_path "$FARM_ID" "$LOG_INDEX")
NOW=$(get_timestamp)

# Append structured log entry
cat << EOF >> "$ACTIVE_LOG"

==========================================
Time   : $NOW
Farm   : $FARM_ID
Commit : #$COMMIT_NO
Status : $STATUS
==========================================

EOF

echo "Log written to: $ACTIVE_LOG"
