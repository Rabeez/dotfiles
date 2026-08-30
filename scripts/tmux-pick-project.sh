#!/usr/bin/env bash
# Project picker for tmux (bound to prefix+f).
# Picks from sesh list (sessions + configured + zoxide + home).
# - If an existing session is picked → sesh connect (attach to it)
# - If a directory is picked → always create a new session with basename-N counter

set -uo pipefail

IND_COLOR=120
[ "$(cat ~/.local/state/theme-mode 2>/dev/null)" = light ] && IND_COLOR="#40a02b"

SELECTED=$(sesh list -i -c -z -t -H -d \
  | sed "s|$HOME|~|" \
  | gum filter --indicator="" --indicator.foreground="$IND_COLOR" \
      --limit 1 --no-sort --fuzzy --no-strip-ansi \
      --placeholder 'Pick a Sesh' --height 60 --prompt=' ')

[ -z "$SELECTED" ] && exit 0

# Strip ANSI escape codes and the leading icon character
CLEAN=$(echo "$SELECTED" | sed $'s/\x1b\[[0-9;]*m//g; s/^[^ ]* //')

case "$CLEAN" in
  "~/"*|/*)
    # Directory entry → create new session with incrementing counter
    EXPANDED="${CLEAN/#\~/$HOME}"
    BASE=$(basename "$EXPANDED")
    IDX=1
    while tmux has-session -t "${BASE}-${IDX}" 2>/dev/null; do
      IDX=$((IDX + 1))
    done
    tmux new-session -d -s "${BASE}-${IDX}" -c "$EXPANDED"
    tmux switch-client -t "${BASE}-${IDX}"
    ;;
  *)
    # Existing session name → attach via sesh (preserves original behavior)
    sesh connect "$CLEAN"
    ;;
esac
