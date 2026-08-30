#!/usr/bin/env bash
# herdr-setup-plugins.sh — link local herdr plugins from dotfiles
#
# First run (fresh machine):  herdr-setup-plugins.sh -f
# After manifest changes:     herdr-setup-plugins.sh -f
# Dry run (show what exists): herdr-setup-plugins.sh
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for lib in "$SCRIPT_DIR"/lib/*.sh; do source "$lib"; done

require_cmd herdr

PLUGINS_LOCAL="$HOME/.config/herdr/plugins-local"

if [[ "${1:-}" == "-f" ]]; then
	for dir in "$PLUGINS_LOCAL"/*/; do
		[ -f "$dir/herdr-plugin.toml" ] || continue
		id=$(grep -m1 '^id' "$dir/herdr-plugin.toml" | sed 's/.*= *"//;s/"//')
		name=$(basename "$dir")
		# Unlink first (idempotent — fails silently if not linked)
		herdr plugin unlink "$id" 2>/dev/null || true
		if herdr plugin link "$dir" >/dev/null 2>&1; then
			log_info "Linked $name ($id)"
		else
			log_warn "Failed to link $name ($id)"
		fi
	done
	log_info "Plugin setup complete"
else
	log_warn "Run with -f to link/relink plugins"
	log_info "Local plugins in $PLUGINS_LOCAL:"
	for dir in "$PLUGINS_LOCAL"/*/; do
		[ -f "$dir/herdr-plugin.toml" ] || continue
		id=$(grep -m1 '^id' "$dir/herdr-plugin.toml" | sed 's/.*= *"//;s/"//')
		name=$(basename "$dir")
		if herdr plugin list 2>/dev/null | grep -q "$id"; then
			log_info "  $name ($id) — linked"
		else
			log_info "  $name ($id) — not linked"
		fi
	done
fi
