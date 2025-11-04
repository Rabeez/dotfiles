#!/usr/bin/env bash
set -euo pipefail

if ! command -v gum &> /dev/null; then
    echo "Error: gum is not installed. Install it using: brew install gum" >&2
    exit 1
fi

if ! command -v rclone &> /dev/null; then
    gum log --level error "rclone is not installed. Install it using: brew install rclone.\n Then run: rclone config."
    exit 1
fi

SRC="$HOME/Programming"
DST="backblaze-main:"

gum log -t "RFC3339" --level info "Initiating backup dry-run"
rclone sync \
    "$SRC" \
    "$DST" \
    --exclude "node_modules/**" \
    --exclude ".pixi/**" \
    --fast-list \
    --skip-links \
    --progress \
    --log-level WARNING \
    --dry-run

echo ""
gum log -t "RFC3339" --level info "Verifying contents of potential upload"
find "$SRC" \
    \( -path "*/node_modules" -o -path "*/.pixi" -o -type l \) \
    -prune -o -type f -print0 \
    | xargs -0 stat -c %s \
    | awk '{total += $1} END {printf "Total size: %.3f GiB\nFiles: %d\n", total/1024/1024/1024, NR}'

echo ""
if gum confirm --default=no "Proceed with full backup?"; then
    gum log -t "RFC3339" --level info "Starting actual backup"
    rclone sync \
        "$SRC" \
        "$DST" \
        --exclude "node_modules/**" \
        --exclude ".pixi/**" \
        --fast-list \
        --skip-links \
        --progress \
        --log-level WARNING
    gum log -t "RFC3339" --level info "Completed"
else
    gum log -t "RFC3339" --level info "Aborting"
fi

