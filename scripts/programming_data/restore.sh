#!/usr/bin/env bash
# programming_data/restore.sh — restore ~/Programming from Backblaze via rclone
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
for lib in "$SCRIPTS_DIR"/lib/*.sh; do source "$lib"; done

require_cmd gum rclone

SRC="backblaze-main:"
DST="$HOME/Programming"

RCLONE_FLAGS=(
	--exclude "node_modules/**"
	--exclude ".pixi/**"
	--fast-list
	--skip-links
)

FORCE=false
[[ "${1:-}" == "-f" ]] && FORCE=true

log_header "Programming Data Restore" "Backblaze → local"

# Validate remote
if ! rclone listremotes | grep -q "^backblaze-main:$"; then
	log_error "rclone remote 'backblaze-main' not configured. Run: rclone config"
	exit 1
fi

if ! rclone lsd "$SRC" &>/dev/null; then
	log_error "Cannot reach remote 'backblaze-main' — check credentials/network. Run: rclone config reconnect backblaze-main:"
	exit 1
fi

# Dry-run and capture stats
log_debug "Initiating dry-run"
log_warn "Dry-run does not show real-time progress — checking what would transfer..."
dry_output=$(rclone copy "$SRC" "$DST" "${RCLONE_FLAGS[@]}" \
	--stats-log-level NOTICE \
	--stats-one-line \
	--log-level NOTICE \
	--dry-run 2>&1)

# Parse transfer summary from rclone output
transferred=$(echo "$dry_output" | grep -oP 'Transferred:\s+\K[^,]+' | head -1)
if [[ -n "$transferred" ]]; then
	log_warn "Dry-run summary: $transferred would be restored"
else
	log_info "Nothing to transfer — remote and local are in sync"
fi

if ! $FORCE; then
	echo ""
	log_info "Pass -f to execute the actual restore."
	exit 0
fi

echo ""
if gum confirm --default=no "Proceed with full restore to $DST?"; then
	log_debug "Starting actual restore"
	rclone copy "$SRC" "$DST" "${RCLONE_FLAGS[@]}" \
		--progress \
		--log-level WARNING
	log_info "Restore complete"
else
	log_debug "Cancelled"
fi
