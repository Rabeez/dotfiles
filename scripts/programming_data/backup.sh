#!/usr/bin/env bash
# programming_data/backup.sh — sync ~/Programming to Backblaze via rclone
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
for lib in "$SCRIPTS_DIR"/lib/*.sh; do source "$lib"; done

require_cmd gum rclone

SRC="$HOME/Programming"
DST="backblaze-main:"

RCLONE_FLAGS=(
	--exclude "node_modules/**"
	--exclude ".pixi/**"
	--fast-list
	--skip-links
)

log_header "Programming Data Backup" "rclone → Backblaze"

# Validate remote
if ! rclone listremotes | grep -q "^backblaze-main:$"; then
	log_error "rclone remote 'backblaze-main' not configured. Run: rclone config"
	exit 1
fi

if ! rclone lsd "$DST" &>/dev/null; then
	log_error "Cannot reach remote 'backblaze-main' — check credentials/network. Run: rclone config reconnect backblaze-main:"
	exit 1
fi

if [[ ! -d "$SRC" ]]; then
	log_error "Source directory not found: $SRC"
	exit 1
fi

# Local size summary
log_debug "Scanning local files"
read -r file_count total_bytes < <(
	find "$SRC" \
		\( -path "*/node_modules" -o -path "*/.pixi" -o -type l \) \
		-prune -o -type f -print0 |
		xargs -0 stat -f %z |
		awk '{total += $1; count++} END {printf "%d %d\n", count, total}'
)
size_gib=$(awk "BEGIN {printf \"%.2f\", $total_bytes/1024/1024/1024}")
log_info "$file_count files, $size_gib GiB locally (excluding node_modules, .pixi)"

# Dry-run
log_debug "Initiating dry-run"
log_warn "Dry-run does not show real-time progress — checking what would transfer..."
echo ""
rclone sync "$SRC" "$DST" "${RCLONE_FLAGS[@]}" \
	--stats-log-level NOTICE \
	--stats-one-line \
	--log-level NOTICE \
	--dry-run 2>&1 | tail -5
echo ""

if gum confirm --default=no "Proceed with full backup?"; then
	log_debug "Starting actual sync"
	rclone sync "$SRC" "$DST" "${RCLONE_FLAGS[@]}" \
		--progress \
		--log-level WARNING
	log_info "Backup complete"
else
	log_debug "Cancelled"
fi
