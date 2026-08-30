#!/usr/bin/env bash
# Shared fzf styling for herdr pickers. Sourced, not executed.
#
# Emits catppuccin colors matching the active theme-mode (mocha/latte) and a
# consistent set of layout flags so every picker looks the same.

_herdr_fzf_opts() {
  local mode="dark"
  [ -r "$HOME/.local/state/theme-mode" ] && mode="$(cat "$HOME/.local/state/theme-mode" 2>/dev/null)"

  local colors
  if [ "$mode" = "light" ]; then
    # catppuccin latte
    colors="bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#d20f39,fg:#4c4f69"
    colors="$colors,header:#d20f39,info:#8839ef,pointer:#dc8a78,marker:#7287fd"
    colors="$colors,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39,border:#9ca0b0"
  else
    # catppuccin mocha
    colors="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4"
    colors="$colors,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#b4befe"
    colors="$colors,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8,border:#6c7086"
  fi

  printf '%s\n' \
    --height=100% \
    --layout=reverse \
    --border=rounded \
    --info=inline \
    --pointer='▎' \
    --cycle \
    --no-multi \
    --color="$colors"
}
