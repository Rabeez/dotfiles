#!/usr/bin/env bash
# lib/checks.sh — macOS version detection, dependency checks

require_cmd() {
	for cmd in "$@"; do
		if ! command -v "$cmd" &>/dev/null; then
			log_error "Required command not found: $cmd"
			log_error "Install via: brew install $cmd"
			exit 1
		fi
	done
}

macos_version() {
	sw_vers -productVersion
}

macos_major() {
	sw_vers -productVersion | cut -d. -f1
}
