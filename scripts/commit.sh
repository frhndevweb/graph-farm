#!/bin/bash

set -e

#########################################
# Graph Farm v2
# commit.sh
#########################################

FARM_ID="$1"

if [ -z "$FARM_ID" ]; then
    echo "Usage: bash scripts/commit.sh <farm_id>"
    exit 1
fi

export TZ=Asia/Jakarta

LOG_DIR="logs"
ARCHIVE_DIR="logs/archive"
STATS_DIR="stats"
DATA_DIR=".farm"

mkdir -p "$LOG_DIR"
mkdir -p "$ARCHIVE_DIR"
mkdir -p "$STATS_DIR"
mkdir -p "$DATA_DIR"

COUNT_FILE="$DATA_DIR/farm${FARM_ID}.count"

if [ ! -f "$COUNT_FILE" ]; then
    echo "0" > "$COUNT_FILE"
fi

COUNT=$(cat "$COUNT_FILE")
COUNT=$((COUNT + 1))

echo "$COUNT" > "$COUNT_FILE"

#########################################
# Rotate Log Every 1000 Entries
#########################################

LOG_INDEX=$(( (COUNT - 1) / 1000 + 1 ))

if [ "$LOG_INDEX" -eq 1 ]; then
    LOG_FILE="$LOG_DIR/farm${FARM_ID}.log"
else
    LOG_FILE="$ARCHIVE_DIR/farm${FARM_ID}-${LOG_INDEX}.log"
fi

#########################################
# Timestamp
#########################################

NOW=$(date "+%Y-%m-%d %H:%M:%S WIB")

#########################################
# Log
#########################################

cat << EOF >> "$LOG_FILE"

==========================================
Time   : $NOW
Farm   : $FARM_ID
Commit : #$COUNT
Status : SUCCESS
==========================================

EOF

#########################################
# Stats
#########################################

cat > "$STATS_DIR/farm${FARM_ID}.json" << EOF
{
  "farm": $FARM_ID,
  "commits": $COUNT,
  "last_run": "$NOW",
  "log": "$(basename "$LOG_FILE")"
}
EOF

#########################################
# Generate Random Content
#########################################

RANDOM_FILE="$DATA_DIR/farm${FARM_ID}.txt"

echo "$NOW" > "$RANDOM_FILE"
echo "$RANDOM" >> "$RANDOM_FILE"
echo "$COUNT" >> "$RANDOM_FILE"

#########################################
# Summary
#########################################

echo ""
echo "=============================="
echo "Graph Farm"
echo "Farm      : $FARM_ID"
echo "Commit    : $COUNT"
echo "Time      : $NOW"
echo "Log File  : $LOG_FILE"
echo "=============================="
echo ""