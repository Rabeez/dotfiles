#!/usr/bin/env bash
# external_tools/backup.sh — dump installed packages to manifest files
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUPS_DIR="$SCRIPT_DIR/backups"

for lib in "$SCRIPTS_DIR"/lib/*.sh; do source "$lib"; done

require_cmd gum

log_header "External Tools Backup" "Dumping package lists to $BACKUPS_DIR"

mkdir -p "$BACKUPS_DIR"

# --- Brew ---
if check_cmd brew; then
	log_debug "Backing up Homebrew packages..."
	brew bundle dump --force --mas --tap --cask --formula --no-vscode --describe --file="$BACKUPS_DIR/Brewfile"
	log_info "Brewfile written"
else
	log_warn "brew not found — skipping Homebrew backup"
fi

# --- Cargo ---
if check_cmd cargo; then
	log_debug "Backing up Cargo crates..."
	{
		echo "# Cargofile — installed via \`cargo install <crate>\`"
		cargo install --list | grep -E '^\S' | awk '{print $1}'
	} >"$BACKUPS_DIR/Cargofile"
	log_info "Cargofile written"
else
	log_warn "cargo not found — skipping Cargo backup"
fi

# --- Go ---
if check_cmd go; then
	log_debug "Backing up Go tools..."
	{
		echo "# Gofile — installed via \`go install <module>@latest\`"
		go version -m ~/go/bin/* 2>/dev/null | grep -E '^\s+path' | awk '{print $2}'
	} >"$BACKUPS_DIR/Gofile"
	log_info "Gofile written"
else
	log_warn "go not found — skipping Go backup"
fi

# --- UV ---
if check_cmd uv; then
	log_debug "Backing up UV tools..."
	{
		echo "# UVfile — installed via \`uv tool install <package>\`"
		uv tool list 2>/dev/null | grep -E '^\S' | awk '{print $1}'
	} >"$BACKUPS_DIR/UVfile"
	log_info "UVfile written"
else
	log_warn "uv not found — skipping UV backup"
fi

log_info "Backup complete — $(date '+%Y-%m-%d %H:%M:%S')"

# =============================================================================
# Untracked Warning Report
# =============================================================================
log_header "Untracked Detection" "Scanning for apps/tools not managed by brew, cargo, go, or uv"

REPORT_FILE="$BACKUPS_DIR/untracked_report.txt"
MISCFILE="$BACKUPS_DIR/Miscfile"
untracked_apps=()
untracked_bins=()

brew_prefix="$(brew --prefix)"

# --- Collect known apps from brew Caskroom + MAS ---
known_apps=()
if [[ -d "$brew_prefix/Caskroom" ]]; then
	while IFS= read -r cask_app; do
		known_apps+=("$(basename "$cask_app" .app)")
	done < <(find "$brew_prefix/Caskroom" -maxdepth 3 -name "*.app" 2>/dev/null)
fi
# Also grab MAS app names from Brewfile
if [[ -f "$BACKUPS_DIR/Brewfile" ]]; then
	while IFS= read -r line; do
		if [[ "$line" =~ ^mas\ \"([^\"]+)\" ]]; then
			known_apps+=("${BASH_REMATCH[1]}")
		fi
	done <"$BACKUPS_DIR/Brewfile"
fi

# --- Collect known items from Miscfile (user-curated) ---
known_misc=()
if [[ -f "$MISCFILE" ]]; then
	while IFS= read -r line; do
		[[ -z "$line" || "$line" == \#* ]] && continue
		known_misc+=("$line")
	done <"$MISCFILE"
fi

# --- Scan /Applications for untracked apps ---
if [[ -d /Applications ]]; then
	while IFS= read -r app_path; do
		app_name="$(basename "$app_path" .app)"
		tracked=false
		for known in "${known_apps[@]:-}"; do
			if [[ "$app_name" == "$known" ]]; then
				tracked=true
				break
			fi
		done
		# Check if in Miscfile
		if ! $tracked; then
			for misc in "${known_misc[@]:-}"; do
				if [[ "$app_name" == "$misc" ]]; then
					tracked=true
					break
				fi
			done
		fi
		if ! $tracked; then
			untracked_apps+=("$app_name")
		fi
	done < <(find /Applications -maxdepth 1 -name "*.app" 2>/dev/null | sort)
fi

# --- Scan common bin dirs for untracked binaries ---
# Collect all managed binary names
managed_bins=()
# Cargo
if [[ -d "$HOME/.cargo/bin" ]]; then
	while IFS= read -r b; do
		managed_bins+=("$(basename "$b")")
	done < <(find "$HOME/.cargo/bin" -maxdepth 1 -type f 2>/dev/null)
fi
# Go
if [[ -d "$HOME/go/bin" ]]; then
	while IFS= read -r b; do
		managed_bins+=("$(basename "$b")")
	done < <(find "$HOME/go/bin" -maxdepth 1 -type f 2>/dev/null)
fi
# Brew
# Check /usr/local/bin and ~/.local/bin for orphans
for bin_dir in /usr/local/bin "$HOME/.local/bin"; do
	[[ -d "$bin_dir" ]] || continue
	while IFS= read -r bin_path; do
		[[ -f "$bin_path" && -x "$bin_path" ]] || continue
		bin_name="$(basename "$bin_path")"
		# Skip if managed by brew (symlink into brew prefix)
		if [[ -L "$bin_path" ]]; then
			link_target="$(readlink "$bin_path" 2>/dev/null || true)"
			if [[ "$link_target" == *"$brew_prefix"* || "$link_target" == *"/Cellar/"* ]]; then
				continue
			fi
		fi
		# Skip if in cargo/go bins
		skip=false
		for mb in "${managed_bins[@]:-}"; do
			if [[ "$bin_name" == "$mb" ]]; then
				skip=true
				break
			fi
		done
		$skip && continue
		# Skip if in Miscfile
		for misc in "${known_misc[@]:-}"; do
			if [[ "$bin_name" == "$misc" ]]; then
				skip=true
				break
			fi
		done
		$skip && continue
		untracked_bins+=("$bin_dir/$bin_name")
	done < <(find "$bin_dir" -maxdepth 1 -type f -o -type l 2>/dev/null | sort)
done

# --- Write report ---
{
	echo "# Untracked Report — $(date '+%Y-%m-%d %H:%M:%S')"
	echo "# Items below are NOT managed by brew, cargo, go, uv, or listed in Miscfile."
	echo "# Add items to backups/Miscfile to suppress these warnings."
	echo ""
	echo "## Applications (/Applications)"
	if ((${#untracked_apps[@]} > 0)); then
		printf '  %s\n' "${untracked_apps[@]}"
	else
		echo "  (none)"
	fi
	echo ""
	echo "## Binaries (/usr/local/bin, ~/.local/bin)"
	if ((${#untracked_bins[@]} > 0)); then
		printf '  %s\n' "${untracked_bins[@]}"
	else
		echo "  (none)"
	fi
} >"$REPORT_FILE"

# --- Print summary ---
total_untracked=$((${#untracked_apps[@]} + ${#untracked_bins[@]}))
if ((total_untracked > 0)); then
	log_warn "$total_untracked untracked item(s) detected — see $REPORT_FILE"
	if ((${#untracked_apps[@]} > 0)); then
		preview="${untracked_apps[*]:0:5}"
		((${#untracked_apps[@]} > 5)) && preview+=" ..."
		log_warn "  Apps (${#untracked_apps[@]}): $preview"
	fi
	if ((${#untracked_bins[@]} > 0)); then
		preview="$(basename -a "${untracked_bins[@]:0:5}" | tr '\n' ' ')"
		((${#untracked_bins[@]} > 5)) && preview+="..."
		log_warn "  Bins (${#untracked_bins[@]}): $preview"
	fi
	if ((${#untracked_bins[@]} > 0)); then
		log_warn "  Bins (${#untracked_bins[@]}): $(printf '%s ' "${untracked_bins[@]:0:5}")$((${#untracked_bins[@]} > 5)) && echo '...'"
	fi
else
	log_info "All detected apps/tools are tracked — nothing untracked found."
fi
