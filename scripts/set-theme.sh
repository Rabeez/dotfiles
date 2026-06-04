#!/bin/bash
# set-theme.sh - Universal dark/light mode toggle for Catppuccin Mocha/Latte
# Usage: set-theme.sh [dark|light|toggle]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/log.sh"

# Source machine-local overrides (wallpapers, etc.)
LOCAL_CONF="$SCRIPT_DIR/themes/local.sh"
[[ -f "$LOCAL_CONF" ]] && source "$LOCAL_CONF"

STATE_FILE="$HOME/.local/state/theme-mode"
# Use live config paths (works regardless of which dotfiles repo is stowed)
CFG="$HOME/.config"

# --- Helpers ---
# Resolve symlinks for sed -i compatibility
resolve() { readlink -f "$1" 2>/dev/null || realpath "$1" 2>/dev/null || echo "$1"; }

ensure_state_dir() {
	mkdir -p "$(dirname "$STATE_FILE")"
}

get_current_mode() {
	if [[ -f "$STATE_FILE" ]]; then
		cat "$STATE_FILE"
	else
		echo "dark"
	fi
}

set_state() {
	ensure_state_dir
	echo "$1" >"$STATE_FILE"
}

# --- Per-app switchers ---

switch_macos() {
	local mode="$1"
	if [[ "$mode" == "light" ]]; then
		osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to false'
	else
		osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'
	fi
}

switch_wallpaper() {
	local mode="$1"
	local wallpaper=""
	if [[ "$mode" == "light" ]]; then
		wallpaper="${WALLPAPER_LIGHT:-}"
	else
		wallpaper="${WALLPAPER_DARK:-}"
	fi

	if [[ -z "$wallpaper" || ! -f "$wallpaper" ]]; then
		return 0
	fi

	# Set wallpaper on all spaces/desktops
	osascript -e "
        tell application \"System Events\"
            tell every desktop
                set picture to \"$wallpaper\"
            end tell
        end tell
    "
}

switch_tmux() {
	local mode="$1"
	local flavor="mocha"
	[[ "$mode" == "light" ]] && flavor="latte"
	local conf="$(resolve "$CFG/tmux/tmux.conf")"

	# Update config file for persistence
	sed -i '' "s/set -g @catppuccin_flavor \".*\"/set -g @catppuccin_flavor \"$flavor\"/" "$conf"
	if [[ "$mode" == "light" ]]; then
		sed -i '' 's/set -g popup-style "bg=#1e1e2e,fg=#cdd6f4"/set -g popup-style "bg=#eff1f5,fg=#4c4f69"/' "$conf"
		sed -i '' 's/set -g popup-border-style "fg=#6c7086,bg=#1e1e2e"/set -g popup-border-style "fg=#9ca0b0,bg=#eff1f5"/' "$conf"
		sed -i '' 's/set -g menu-style "bg=#1e1e2e,fg=#cdd6f4"/set -g menu-style "bg=#eff1f5,fg=#4c4f69"/' "$conf"
		sed -i '' 's/set -g menu-border-style "fg=#cba6f7,bg=#1e1e2e"/set -g menu-border-style "fg=#8839ef,bg=#eff1f5"/' "$conf"
		sed -i '' 's/set -g menu-selected-style "bg=#585b70,fg=#cdd6f4"/set -g menu-selected-style "bg=#ccd0da,fg=#4c4f69"/' "$conf"
	else
		sed -i '' 's/set -g popup-style "bg=#eff1f5,fg=#4c4f69"/set -g popup-style "bg=#1e1e2e,fg=#cdd6f4"/' "$conf"
		sed -i '' 's/set -g popup-border-style "fg=#9ca0b0,bg=#eff1f5"/set -g popup-border-style "fg=#6c7086,bg=#1e1e2e"/' "$conf"
		sed -i '' 's/set -g menu-style "bg=#eff1f5,fg=#4c4f69"/set -g menu-style "bg=#1e1e2e,fg=#cdd6f4"/' "$conf"
		sed -i '' 's/set -g menu-border-style "fg=#8839ef,bg=#eff1f5"/set -g menu-border-style "fg=#cba6f7,bg=#1e1e2e"/' "$conf"
		sed -i '' 's/set -g menu-selected-style "bg=#ccd0da,fg=#4c4f69"/set -g menu-selected-style "bg=#585b70,fg=#cdd6f4"/' "$conf"
	fi

	# Live-reload if tmux is running
	if command -v tmux &>/dev/null && tmux info &>/dev/null 2>&1; then
		local plugin_dir="$HOME/.config/tmux/plugins/tmux"
		tmux set -g @catppuccin_flavor "$flavor"

		# Force-load the flavor theme (override -ogq vars)
		local tmp_theme="/tmp/catppuccin_tmux_reload.conf"
		{
			# Unset all catppuccin/theme vars so -ogq can re-set them
			tmux show -g 2>/dev/null | grep -E "^@(thm_|catppuccin_|_ctp_)" | cut -d' ' -f1 | while read -r var; do
				echo "set -gu $var"
			done
			sed 's/set -ogq/set -gq/g' "$plugin_dir/themes/catppuccin_${flavor}_tmux.conf"
		} >"$tmp_theme"
		tmux source "$tmp_theme"

		# Re-run the full plugin entry point (vars are now unset so -ogq works fresh)
		tmux run-shell "$plugin_dir/catppuccin.tmux"

		# Also re-source user tmux.conf to reapply custom status format
		tmux source-file "$HOME/.config/tmux/tmux.conf" 2>/dev/null || true

		# Update popup/menu styling
		if [[ "$mode" == "light" ]]; then
			tmux set -g popup-style "bg=#eff1f5,fg=#4c4f69"
			tmux set -g popup-border-style "fg=#9ca0b0,bg=#eff1f5"
			tmux set -g menu-style "bg=#eff1f5,fg=#4c4f69"
			tmux set -g menu-border-style "fg=#8839ef,bg=#eff1f5"
			tmux set -g menu-selected-style "bg=#ccd0da,fg=#4c4f69"
		else
			tmux set -g popup-style "bg=#1e1e2e,fg=#cdd6f4"
			tmux set -g popup-border-style "fg=#6c7086,bg=#1e1e2e"
			tmux set -g menu-style "bg=#1e1e2e,fg=#cdd6f4"
			tmux set -g menu-border-style "fg=#cba6f7,bg=#1e1e2e"
			tmux set -g menu-selected-style "bg=#585b70,fg=#cdd6f4"
		fi

		rm -f "$tmp_theme"
	fi
}

switch_neovim() {
	local mode="$1"
	local scheme="catppuccin-mocha"
	[[ "$mode" == "light" ]] && scheme="catppuccin-latte"

	# Write state file for nvim startup
	echo "$scheme" >"$HOME/.config/nvim/colorscheme" 2>/dev/null || true

	# Live-reload all running nvim instances
	local socks
	socks=$(find "${TMPDIR:-/tmp}" -path "*/nvim*/nvim.*" -type s 2>/dev/null || true)
	for sock in $socks; do
		nvim --server "$sock" --remote-send "<Cmd>colorscheme $scheme<CR>" 2>/dev/null || true
	done
}

switch_wezterm() {
	local mode="$1"
	local scheme="Catppuccin Mocha"
	[[ "$mode" == "light" ]] && scheme="Catppuccin Latte"
	echo "$scheme" >"$HOME/.config/wezterm/colorscheme" 2>/dev/null || true
}

switch_kitty() {
	local mode="$1"
	local conf="$(resolve "$CFG/kitty/kitty.conf")"
	if [[ -f "$conf" ]]; then
		if [[ "$mode" == "light" ]]; then
			sed -i '' 's/catppuccin-mocha/catppuccin-latte/g' "$conf"
		else
			sed -i '' 's/catppuccin-latte/catppuccin-mocha/g' "$conf"
		fi
	fi
}

switch_bat() {
	local mode="$1"
	local conf="$(resolve "$CFG/bat/config")"
	if [[ "$mode" == "light" ]]; then
		sed -i '' 's/--theme="Catppuccin Mocha"/--theme="Catppuccin Latte"/' "$conf"
	else
		sed -i '' 's/--theme="Catppuccin Latte"/--theme="Catppuccin Mocha"/' "$conf"
	fi
}

switch_delta() {
	local mode="$1"
	local conf="$(resolve "$HOME/.gitconfig")"
	if [[ "$mode" == "light" ]]; then
		sed -i '' 's/features = catppuccin-mocha/features = catppuccin-latte/' "$conf"
	else
		sed -i '' 's/features = catppuccin-latte/features = catppuccin-mocha/' "$conf"
	fi
}

switch_starship() {
	local mode="$1"
	local conf="$(resolve "$CFG/starship.toml")"
	if [[ "$mode" == "light" ]]; then
		sed -i '' 's/palette = "catppuccin_mocha"/palette = "catppuccin_latte"/' "$conf"
	else
		sed -i '' 's/palette = "catppuccin_latte"/palette = "catppuccin_mocha"/' "$conf"
	fi
}

switch_lazygit() {
	local mode="$1"
	local conf="$(resolve "$CFG/lazygit/config.yml")"
	if [[ "$mode" == "light" ]]; then
		# Mocha -> Latte colors
		sed -i '' \
			-e 's/#cba6f7/#8839ef/g' \
			-e 's/#a6adc8/#9ca0b0/g' \
			-e 's/#89b4fa/#1e66f5/g' \
			-e 's/#313244/#ccd0da/g' \
			-e 's/#45475a/#bcc0cc/g' \
			-e 's/#f38ba8/#d20f39/g' \
			-e 's/#cdd6f4/#4c4f69/g' \
			-e 's/#f9e2af/#df8e1d/g' \
			-e 's/#b4befe/#7287fd/g' \
			"$conf"
	else
		# Latte -> Mocha colors
		sed -i '' \
			-e 's/#8839ef/#cba6f7/g' \
			-e 's/#9ca0b0/#a6adc8/g' \
			-e 's/#1e66f5/#89b4fa/g' \
			-e 's/#ccd0da/#313244/g' \
			-e 's/#bcc0cc/#45475a/g' \
			-e 's/#d20f39/#f38ba8/g' \
			-e 's/#4c4f69/#cdd6f4/g' \
			-e 's/#df8e1d/#f9e2af/g' \
			-e 's/#7287fd/#b4befe/g' \
			"$conf"
	fi
}

switch_yazi() {
	local mode="$1"
	local conf="$(resolve "$CFG/yazi/theme.toml")"
	if [[ -f "$conf" ]]; then
		if [[ "$mode" == "light" ]]; then
			sed -i '' 's/Catppuccin-mocha/Catppuccin-latte/g' "$conf"
			# Swap known mocha bg/fg colors to latte
			sed -i '' 's/#1e1e2e/#eff1f5/g' "$conf"
			sed -i '' 's/#94e2d5/#179299/g' "$conf"
		else
			sed -i '' 's/Catppuccin-latte/Catppuccin-mocha/g' "$conf"
			sed -i '' 's/#eff1f5/#1e1e2e/g' "$conf"
			sed -i '' 's/#179299/#94e2d5/g' "$conf"
		fi
	fi
}

switch_btop() {
	local mode="$1"
	local conf="$(resolve "$CFG/btop/btop.conf")"
	if [[ "$mode" == "light" ]]; then
		sed -i '' 's/catppuccin_mocha/catppuccin_latte/g' "$conf"
	else
		sed -i '' 's/catppuccin_latte/catppuccin_mocha/g' "$conf"
	fi
}

switch_zellij() {
	local mode="$1"
	local conf="$(resolve "$CFG/zellij/config.kdl")"
	if [[ "$mode" == "light" ]]; then
		sed -i '' 's/theme "catppuccin-mocha"/theme "catppuccin-latte"/' "$conf"
	else
		sed -i '' 's/theme "catppuccin-latte"/theme "catppuccin-mocha"/' "$conf"
	fi
}

switch_spotify_player() {
	local mode="$1"
	local conf="$(resolve "$CFG/spotify-player/app.toml")"
	if [[ "$mode" == "light" ]]; then
		sed -i '' 's/theme = "Catppuccin-mocha"/theme = "Catppuccin-latte"/' "$conf"
	else
		sed -i '' 's/theme = "Catppuccin-latte"/theme = "Catppuccin-mocha"/' "$conf"
	fi
}

switch_vim() {
	local mode="$1"
	local conf="$(resolve "$CFG/vim/vimrc")"
	if [[ "$mode" == "light" ]]; then
		sed -i '' 's/catppuccin_mocha/catppuccin_latte/g' "$conf"
	else
		sed -i '' 's/catppuccin_latte/catppuccin_mocha/g' "$conf"
	fi
}

switch_superfile() {
	local mode="$1"
	local conf="$(resolve "$CFG/superfile/config.toml")"
	[[ -f "$conf" ]] || return 0
	if [[ "$mode" == "light" ]]; then
		sed -i '' "s/theme = 'catppuccin-mocha-mauve'/theme = 'catppuccin-latte'/" "$conf"
	else
		sed -i '' "s/theme = 'catppuccin-latte'/theme = 'catppuccin-mocha-mauve'/" "$conf"
	fi
}

switch_vivid_cache() {
	local mode="$1"
	local cache="$HOME/.cache/vivid-ls-colors"
	if command -v vivid &>/dev/null; then
		if [[ "$mode" == "light" ]]; then
			vivid generate catppuccin-latte >"$cache"
		else
			vivid generate catppuccin-mocha >"$cache"
		fi
	fi
}

switch_sketchybar() {
	local mode="$1"
	local colors="$(resolve "$CFG/sketchybar/colors.sh")"

	# Swap the palette section in colors.sh
	if [[ "$mode" == "light" ]]; then
		sed -i '' \
			-e 's/0xff181926/0xffdce0e8/g' \
			-e 's/0xffcad3f5/0xff4c4f69/g' \
			-e 's/0xffed8796/0xffd20f39/g' \
			-e 's/0xffa6da95/0xff40a02b/g' \
			-e 's/0xff8aadf4/0xff1e66f5/g' \
			-e 's/0xffeed49f/0xffdf8e1d/g' \
			-e 's/0xfff5a97f/0xfffe640b/g' \
			-e 's/0xffc6a0f6/0xff8839ef/g' \
			-e 's/0xff939ab7/0xff9ca0b0/g' \
			-e 's/0xff94e2d5/0xff179299/g' \
			-e 's/0x801e1e2e/0x80eff1f5/g' \
			-e 's/0x80494d64/0x809ca0b0/g' \
			"$colors"
	else
		sed -i '' \
			-e 's/0xffdce0e8/0xff181926/g' \
			-e 's/0xff4c4f69/0xffcad3f5/g' \
			-e 's/0xffd20f39/0xffed8796/g' \
			-e 's/0xff40a02b/0xffa6da95/g' \
			-e 's/0xff1e66f5/0xff8aadf4/g' \
			-e 's/0xffdf8e1d/0xffeed49f/g' \
			-e 's/0xfffe640b/0xfff5a97f/g' \
			-e 's/0xff8839ef/0xffc6a0f6/g' \
			-e 's/0xff9ca0b0/0xff939ab7/g' \
			-e 's/0xff179299/0xff94e2d5/g' \
			-e 's/0x80eff1f5/0x801e1e2e/g' \
			-e 's/0x809ca0b0/0x80494d64/g' \
			"$colors"
	fi

	# Reload sketchybar
	if command -v sketchybar &>/dev/null; then
		sketchybar --reload 2>/dev/null || true
	fi
}

switch_borders() {
	local mode="$1"
	local conf="$(resolve "$CFG/borders/bordersrc")"
	if [[ "$mode" == "light" ]]; then
		sed -i '' 's/active_color=0xFF000000/active_color=0xFF1e66f5/; s/inactive_color=0xFF000000/inactive_color=0xFF9ca0b0/' "$conf"
	else
		sed -i '' 's/active_color=0xFF1e66f5/active_color=0xFF000000/' "$conf"
		sed -i '' 's/inactive_color=0xFF9ca0b0/inactive_color=0xFF000000/' "$conf"
	fi
	# Restart borders
	if pgrep -q borders 2>/dev/null; then
		pkill borders 2>/dev/null
		(sleep 0.3 && "$conf") &>/dev/null &
		disown
	fi
}

# --- Main ---
main() {
	local target="${1:-toggle}"

	if [[ "$target" == "toggle" ]]; then
		local current
		current="$(get_current_mode)"
		if [[ "$current" == "dark" ]]; then
			target="light"
		else
			target="dark"
		fi
	fi

	if [[ "$target" != "dark" && "$target" != "light" ]]; then
		echo "Usage: set-theme.sh [dark|light|toggle]"
		exit 1
	fi

	log_info "Switching to $target mode" "flavor=$([ "$target" == "dark" ] && echo "Catppuccin Mocha" || echo "Catppuccin Latte")"

	# Save state first
	set_state "$target"

	# Switch everything
	switch_macos "$target"
	switch_wallpaper "$target"
	switch_tmux "$target"
	switch_neovim "$target"
	switch_wezterm "$target"
	switch_kitty "$target"
	switch_bat "$target"
	switch_delta "$target"
	switch_starship "$target"
	switch_lazygit "$target"
	switch_yazi "$target"
	switch_btop "$target"
	switch_zellij "$target"
	switch_spotify_player "$target"
	switch_vim "$target"
	switch_superfile "$target"
	switch_vivid_cache "$target"
	switch_sketchybar "$target"
	switch_borders "$target"

	log_info "Done! Theme set to $target."
}

main "$@"
