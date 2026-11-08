#!/usr/bin/env bash
# ==============================================================================
# Graph Farm v2 - Live README Status Generator
# File: scripts/update-readme.sh
# ==============================================================================

set -eo pipefail

export TZ="Asia/Jakarta"

README="README.md"
STATS_DIR="stats"

if [[ ! -f "$README" ]]; then
    echo "Error: $README not found." >&2
    exit 1
fi

NOW=$(date "+%Y-%m-%d %H:%M:%S WIB")
TOTAL=0

# Helper to extract JSON fields portably (jq if present, regex fallback otherwise)
extract_field() {
    local file="$1"
    local field="$2"
    if command -v jq >/dev/null 2>&1; then
        jq -r ".${field} // \"\"" "$file" 2>/dev/null
    else
        grep -m 1 "\"${field}\"" "$file" | sed -E "s/.*\"${field}\": *\"?([^,\"]*)\"?.*/\1/" || true
    fi
}

TABLE="| Farm | Commits | Last Run (WIB) | Active Log |"$'\n'
TABLE+="|:---|---:|:---|:---|"$'\n'

for i in $(seq 1 10); do
    FILE="$STATS_DIR/farm${i}.json"

    if [[ -f "$FILE" ]]; then
        COMMITS=$(extract_field "$FILE" "commits")
        LAST_RUN=$(extract_field "$FILE" "last_run")
        LOG_FILE=$(extract_field "$FILE" "log")

        if [[ ! "$COMMITS" =~ ^[0-9]+$ ]]; then
            COMMITS=0
        fi
        if [[ -z "$LAST_RUN" ]]; then
            LAST_RUN="-"
        fi
        if [[ -z "$LOG_FILE" ]]; then
            LOG_FILE="-"
        fi

        TOTAL=$((TOTAL + COMMITS))
        TABLE+="| Farm ${i} | ${COMMITS} | ${LAST_RUN} | \`${LOG_FILE}\` |"$'\n'
    else
        TABLE+="| Farm ${i} | 0 | - | - |"$'\n'
    fi
done

STATUS=$(cat <<EOF
<!-- FARM_STATUS_START -->

### 📊 Live Status

| Metric | Current Value |
|:---|:---|
| **Last Synchronized** | **${NOW}** |
| **Active Timezone** | **Asia/Jakarta (WIB)** |
| **Total Farm Commits** | **${TOTAL}** |

#### Per-Farm Performance Summary

${TABLE}
<!-- FARM_STATUS_END -->
EOF
)

export STATUS
awk '
BEGIN { inside = 0 }
/<!-- FARM_STATUS_START -->/ {
    print ENVIRON["STATUS"]
    inside = 1
    next
}
/<!-- FARM_STATUS_END -->/ {
    inside = 0
    next
}
!inside { print }
' "$README" > "${README}.tmp"

mv "${README}.tmp" "$README"

echo "README live status updated successfully. Total commits: ${TOTAL}"
