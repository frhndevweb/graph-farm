#!/usr/bin/env bash
# ==============================================================================
# Graph Farm v2 - Utility Functions
# File: scripts/utils.sh
# ==============================================================================

set -eo pipefail

export TZ="Asia/Jakarta"

# ------------------------------------------------------------------------------
# Output formatted current timestamp in Asia/Jakarta (WIB)
# ------------------------------------------------------------------------------
get_timestamp() {
    date "+%Y-%m-%d %H:%M:%S WIB"
}

# ------------------------------------------------------------------------------
# Ensure directory exists
# ------------------------------------------------------------------------------
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
    fi
}

# ------------------------------------------------------------------------------
# Validate Farm ID (must be a positive integer, typically 1 to 10)
# ------------------------------------------------------------------------------
validate_farm_id() {
    local farm_id="$1"
    if [[ -z "$farm_id" || ! "$farm_id" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Farm ID must be a positive integer. Received: '${farm_id}'" >&2
        return 1
    fi
    return 0
}

# ------------------------------------------------------------------------------
# Read integer counter from file (defaults to 0 if missing or invalid)
# ------------------------------------------------------------------------------
read_counter() {
    local count_file="$1"
    local count=0

    if [[ -f "$count_file" ]]; then
        local raw_val
        raw_val=$(tr -d '[:space:]' < "$count_file" 2>/dev/null || true)
        if [[ "$raw_val" =~ ^[0-9]+$ ]]; then
            count="$raw_val"
        fi
    fi

    echo "$count"
}

# ------------------------------------------------------------------------------
# Write integer counter to file
# ------------------------------------------------------------------------------
write_counter() {
    local count_file="$1"
    local count="$2"
    echo "$count" > "$count_file"
}

# ------------------------------------------------------------------------------
# Compute log archive index (1 for commits 1-1000, 2 for 1001-2000, etc.)
# ------------------------------------------------------------------------------
compute_log_index() {
    local count="$1"
    if [[ "$count" -le 0 ]]; then
        echo 1
        return
    fi
    echo $(( (count - 1) / 1000 + 1 ))
}

# ------------------------------------------------------------------------------
# Determine active log file path
# ------------------------------------------------------------------------------
get_log_path() {
    local farm_id="$1"
    local log_index="$2"

    if [[ "$log_index" -eq 1 ]]; then
        echo "logs/farm${farm_id}.log"
    else
        echo "logs/archive/farm${farm_id}-${log_index}.log"
    fi
}

# ------------------------------------------------------------------------------
# Write formatted stats JSON
# ------------------------------------------------------------------------------
write_stats_file() {
    local stats_file="$1"
    local farm_id="$2"
    local count="$3"
    local timestamp="$4"
    local log_name="$5"

    cat > "$stats_file" << EOF
{
  "farm": $farm_id,
  "commits": $count,
  "last_run": "$timestamp",
  "log": "$log_name"
}
EOF
}

# ------------------------------------------------------------------------------
# Rotate & prune old archives (preserves newest MAX_ARCHIVES, default 20)
# Uses version/numeric sort (sort -V) so farm1-10.log is not sorted before farm1-2.log
# ------------------------------------------------------------------------------
rotate_and_prune_archives() {
    local farm_id="$1"
    local max_archives="${2:-20}"
    local archive_dir="logs/archive"

    if [[ ! -d "$archive_dir" ]]; then
        return 0
    fi

    local files
    files=$(find "$archive_dir" -maxdepth 1 -name "farm${farm_id}-*.log" 2>/dev/null | sort -V || true)

    if [[ -z "$files" ]]; then
        return 0
    fi

    local file_count
    file_count=$(echo "$files" | grep -c "\.log$" || true)

    if [[ "$file_count" -gt "$max_archives" ]]; then
        local remove_count=$((file_count - max_archives))
        echo "$files" | head -n "$remove_count" | while read -r file_to_delete; do
            if [[ -f "$file_to_delete" ]]; then
                rm -f "$file_to_delete"
                echo "Rotated & removed old archive: $file_to_delete"
            fi
        done
    fi
}

# ------------------------------------------------------------------------------
# Display banner
# ------------------------------------------------------------------------------
banner() {
    echo "======================================"
    echo "        🌱 Graph Farm v2"
    echo "======================================"
}
