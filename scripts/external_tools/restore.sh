#!/usr/bin/env bash
# external_tools/restore.sh — install packages from manifest files
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUPS_DIR="$SCRIPT_DIR/backups"

for lib in "$SCRIPTS_DIR"/lib/*.sh; do source "$lib"; done

require_cmd gum

DRY_RUN=true
[[ "${1:-}" == "-f" ]] && DRY_RUN=false

log_header "External Tools Restore" "Installing from $BACKUPS_DIR"

installed=0
skipped=0
failed=0
failed_names=()

# --- Brew ---
if [[ -f "$BACKUPS_DIR/Brewfile" ]]; then
	log_debug "Restoring Homebrew packages..."
	if $DRY_RUN; then
		log_debug "[dry-run] brew bundle install --file=$BACKUPS_DIR/Brewfile"
	else
		if ! brew bundle install --file="$BACKUPS_DIR/Brewfile"; then
			log_warn "Some Homebrew packages may have failed"
		fi
	fi
else
	log_warn "Brewfile not found — skipping"
fi

# --- Cargo ---
if [[ -f "$BACKUPS_DIR/Cargofile" ]]; then
	if ! check_cmd cargo; then
		log_warn "cargo not found — skipping Cargo restore"
	else
		log_debug "Restoring Cargo crates..."
		while IFS= read -r crate; do
			[[ -z "$crate" || "$crate" == \#* ]] && continue
			if [[ -f "$HOME/.cargo/bin/$crate" ]]; then
				((skipped++))
				continue
			fi
			if $DRY_RUN; then
				log_debug "[dry-run] cargo install $crate"
				((installed++))
			else
				if cargo install "$crate" 2>/dev/null; then
					((installed++))
				else
					((failed++))
					failed_names+=("$crate")
					log_error "Failed to install cargo crate: $crate"
				fi
			fi
		done <"$BACKUPS_DIR/Cargofile"
	fi
else
	log_warn "Cargofile not found — skipping"
fi

# --- Go ---
if [[ -f "$BACKUPS_DIR/Gofile" ]]; then
	if ! check_cmd go; then
		log_warn "go not found — skipping Go restore"
	else
		log_debug "Restoring Go tools..."
		while IFS= read -r module; do
			[[ -z "$module" || "$module" == \#* ]] && continue
			binary_name="${module##*/}"
			if [[ -f "$HOME/go/bin/$binary_name" ]]; then
				((skipped++))
				continue
			fi
			if $DRY_RUN; then
				log_debug "[dry-run] go install ${module}@latest"
				((installed++))
			else
				if go install "${module}@latest" 2>/dev/null; then
					((installed++))
				else
					((failed++))
					failed_names+=("$module")
					log_error "Failed to install go tool: $module"
				fi
			fi
		done <"$BACKUPS_DIR/Gofile"
	fi
else
	log_warn "Gofile not found — skipping"
fi

# --- UV ---
if [[ -f "$BACKUPS_DIR/UVfile" ]]; then
	if ! check_cmd uv; then
		log_warn "uv not found — skipping UV restore"
	else
		log_debug "Restoring UV tools..."
		uv_installed=$(uv tool list 2>/dev/null | grep -E '^\S' | awk '{print $1}')
		while IFS= read -r pkg; do
			[[ -z "$pkg" || "$pkg" == \#* ]] && continue
			if echo "$uv_installed" | grep -qx "$pkg"; then
				((skipped++))
				continue
			fi
			if $DRY_RUN; then
				log_debug "[dry-run] uv tool install $pkg"
				((installed++))
			else
				if uv tool install "$pkg" 2>/dev/null; then
					((installed++))
				else
					((failed++))
					failed_names+=("$pkg")
					log_error "Failed to install uv tool: $pkg"
				fi
			fi
		done <"$BACKUPS_DIR/UVfile"
	fi
else
	log_warn "UVfile not found — skipping"
fi

# --- Summary ---
if $DRY_RUN; then
	log_info "Dry-run complete: $installed would install, $skipped already present. Pass -f to execute."
else
	log_info "Restore complete: $installed installed, $skipped skipped, $failed failed"
	if ((failed > 0)); then
		log_error "Failed packages: ${failed_names[*]}"
	fi
fi

# --- Neovim reminder ---
log_warn "Neovim is built from source — remember to clone and build:"
log_warn "  git clone https://github.com/neovim/neovim && cd neovim && make CMAKE_BUILD_TYPE=Release install"

# --- Miscfile reminder ---
MISCFILE="$BACKUPS_DIR/Miscfile"
if [[ -f "$MISCFILE" ]]; then
	misc_items=()
	while IFS= read -r line; do
		[[ -z "$line" || "$line" == \#* ]] && continue
		misc_items+=("$line")
	done <"$MISCFILE"
	if ((${#misc_items[@]} > 0)); then
		log_warn "Manual installs not handled by this script (see Miscfile):"
		printf '  • %s\n' "${misc_items[@]}"
	fi
fi
