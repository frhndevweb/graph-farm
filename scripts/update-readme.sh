#!/bin/bash

set -e

export TZ=Asia/Jakarta

README="README.md"
STATS_DIR="stats"

NOW=$(date "+%Y-%m-%d %H:%M:%S WIB")

TOTAL=0

TABLE="| Farm | Commits | Last Run | Log |\n"
TABLE+="|------|---------|----------|-----|\n"

for i in $(seq 1 10)
do

FILE="$STATS_DIR/farm$i.json"

if [ -f "$FILE" ]; then

COMMITS=$(jq '.commits' "$FILE")

LAST=$(jq -r '.last_run' "$FILE")

LOG=$(jq -r '.log' "$FILE")

TOTAL=$((TOTAL + COMMITS))

TABLE+="| Farm $i | $COMMITS | $LAST | $LOG |\n"

else

TABLE+="| Farm $i | 0 | - | - |\n"

fi

done

STATUS=$(cat <<EOF
<!-- FARM_STATUS_START -->

## 📊 Farm Status

Last Update

**$NOW**

Timezone

**Asia/Jakarta (WIB)**

### Statistics

$TABLE

### Total Commits

**$TOTAL**

<!-- FARM_STATUS_END -->
EOF
)

awk -v repl="$STATUS" '
BEGIN {inside=0}
/<!-- FARM_STATUS_START -->/{
print repl
inside=1
next
}
/<!-- FARM_STATUS_END -->/{
inside=0
next
}
!inside
' "$README" > README.tmp

mv README.tmp "$README"

echo "README updated."