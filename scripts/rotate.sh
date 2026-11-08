#!/usr/bin/env bash
# ==============================================================================
# Graph Farm v2 - Log Archive & Rotation Manager
# File: scripts/rotate.sh
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/utils.sh
source "${SCRIPT_DIR}/utils.sh"

FARM_ID="$1"
MAX_ARCHIVES="${2:-20}"

if [[ -z "$FARM_ID" ]]; then
    echo "Usage: bash scripts/rotate.sh <farm_id> [max_archives]" >&2
    exit 1
fi

validate_farm_id "$FARM_ID"

ensure_dir "logs"
ensure_dir "logs/archive"

echo "Checking log archives for Farm $FARM_ID (Retaining up to $MAX_ARCHIVES archives)..."
rotate_and_prune_archives "$FARM_ID" "$MAX_ARCHIVES"
echo "Log rotation check completed for Farm $FARM_ID."
