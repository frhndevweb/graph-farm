#!/bin/bash

#########################################
# Graph Farm v2
# rotate.sh
#########################################

set -e

FARM_ID="$1"
COMMIT_NO="$2"

if [[ -z "$FARM_ID" || -z "$COMMIT_NO" ]]; then
    echo "Usage: bash rotate.sh <farm_id> <commit_number>"
    exit 1
fi

LOG_DIR="logs"
ARCHIVE_DIR="$LOG_DIR/archive"

mkdir -p "$LOG_DIR"
mkdir -p "$ARCHIVE_DIR"

#########################################
# Rotate Every 1000 Commits
#########################################

LOG_INDEX=$(( (COMMIT_NO - 1) / 1000 + 1 ))

if [[ "$LOG_INDEX" -eq 1 ]]; then
    ACTIVE_LOG="$LOG_DIR/farm${FARM_ID}.log"
else
    ACTIVE_LOG="$ARCHIVE_DIR/farm${FARM_ID}-${LOG_INDEX}.log"
fi

touch "$ACTIVE_LOG"

#########################################
# Keep Only Last 20 Archives
#########################################

MAX_ARCHIVES=20

FILES=$(ls "$ARCHIVE_DIR"/farm${FARM_ID}-*.log 2>/dev/null | sort)

COUNT=$(echo "$FILES" | grep -c ".log" || true)

if [[ "$COUNT" -gt "$MAX_ARCHIVES" ]]; then

    REMOVE=$((COUNT - MAX_ARCHIVES))

    echo "$FILES" | head -n "$REMOVE" | while read FILE
    do
        rm -f "$FILE"
        echo "Deleted old archive: $FILE"
    done

fi

#########################################
# Output
#########################################

echo "=============================="
echo "Rotation Completed"
echo "Farm      : $FARM_ID"
echo "Commit    : $COMMIT_NO"
echo "Active Log: $ACTIVE_LOG"
echo "=============================="