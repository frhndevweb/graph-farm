#!/bin/bash

#########################################
# Graph Farm v2
# utils.sh
#########################################

set -e

export TZ=Asia/Jakarta

#########################################
# Get Current Timestamp
#########################################

current_time() {
    date "+%Y-%m-%d %H:%M:%S WIB"
}

#########################################
# Create Directory
#########################################

ensure_dir() {

    if [[ ! -d "$1" ]]; then
        mkdir -p "$1"
    fi

}

#########################################
# Read Counter
#########################################

read_counter() {

    local FILE="$1"

    if [[ ! -f "$FILE" ]]; then
        echo 0 > "$FILE"
    fi

    cat "$FILE"

}

#########################################
# Increase Counter
#########################################

increase_counter() {

    local FILE="$1"

    COUNT=$(read_counter "$FILE")

    COUNT=$((COUNT + 1))

    echo "$COUNT" > "$FILE"

    echo "$COUNT"

}

#########################################
# Active Log
#########################################

active_log() {

    FARM_ID="$1"
    COMMIT="$2"

    INDEX=$(( (COMMIT - 1) / 1000 + 1 ))

    if [[ "$INDEX" -eq 1 ]]; then
        echo "logs/farm${FARM_ID}.log"
    else
        echo "logs/archive/farm${FARM_ID}-${INDEX}.log"
    fi

}

#########################################
# JSON Writer
#########################################

write_stats() {

    FILE="$1"
    FARM="$2"
    COMMIT="$3"
    TIME="$4"
    LOG="$5"

cat > "$FILE" << EOF
{
    "farm": $FARM,
    "commits": $COMMIT,
    "last_run": "$TIME",
    "log": "$LOG",
    "status": "success"
}
EOF

}

#########################################
# Banner
#########################################

banner() {

echo "======================================"
echo "        🌱 Graph Farm v2"
echo "======================================"

}