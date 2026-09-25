#!/usr/bin/env bash
# lib/checks.sh — dependency checks

require_cmd() {
	for cmd in "$@"; do
		if ! command -v "$cmd" >/dev/null 2>&1; then
			log_error "Required command not found: $cmd"
			log_error "Install via: brew install $cmd"
			exit 1
		fi
	done
}

check_cmd() {
	command -v "$1" >/dev/null 2>&1
}

macos_version() {
	sw_vers -productVersion
}

macos_major() {
	sw_vers -productVersion | cut -d. -f1
}
