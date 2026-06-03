#!/usr/bin/env bash
# lib/log.sh — gum log wrappers + header

log_header() {
	gum style --border rounded --align center --width 50 --margin "1 2" --padding "1 2" \
		"$1" "$2"
}

log_debug() { gum log -t "RFC3339" --level debug "$@"; }
log_info() { gum log -t "RFC3339" --level info "$@"; }
log_warn() { gum log -t "RFC3339" --level warn "$@"; }
log_error() { gum log -t "RFC3339" --level error "$@"; }
