#!/usr/bin/env bash
# update_yazi_plugins.sh — remove managed plugins and re-install via ya pkg
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for lib in "$SCRIPT_DIR"/lib/*.sh; do source "$lib"; done

require_cmd gum ya

PLUGINS_DIR=".config/yazi/plugins"
PACKAGE_TOML=".config/yazi/package.toml"

if [[ "${1:-}" == "-f" ]]; then
	log_debug "Removing managed plugins and upgrading..."

	# Get list of managed plugins from package.toml
	managed=$(grep 'use' "$PACKAGE_TOML" | sed 's|.*/||' | tr -d '"' | sed 's/plugins://' | xargs -I {} echo "{}.yazi" | sort)

	# Remove only managed plugins (leave local/custom ones intact)
	for dir in "$PLUGINS_DIR"/*.yazi; do
		name=$(basename "$dir")
		if echo "$managed" | grep -qx "$name"; then
			rm -rf "$dir"
		else
			log_debug "Keeping local plugin: $name"
		fi
	done

	ya pkg upgrade
	log_info "Plugin upgrade complete"
else
	log_warn "Run with -f to execute commands"
	log_info "Local (unmanaged) plugins will be preserved."
	log_info "Managed plugins will be removed and re-installed via 'ya pkg upgrade'."
fi
