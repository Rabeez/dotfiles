#!/usr/bin/env bash
# herdr navigation dispatch -- latency-optimized fork of herdr-splits' script.
#
# Upstream makes four socket round trips per keypress
# (pane current -> process-info -> edges -> focus) and shells out to sed/grep
# about seven times to parse config and JSON. Measured ~99 ms per keypress,
# which is clearly perceptible when holding ctrl+h/j/k/l.
#
# Two optimizations, both behaviour-preserving:
#
#   1. Two round trips instead of four. `pane process-info` already returns
#      pane_id (so `pane current` is redundant), and `pane focus` returns
#      changed / reason=no_neighbor / layout.zoomed (so the `pane edges` probe
#      is redundant -- just attempt the move and inspect the response).
#
#   2. No helper processes. Config and JSON parsing use bash builtins only,
#      which removes ~7 fork+exec pairs. On macOS this dominated the runtime.
#
# Behaviour preserved: forward the chord to Neovim when the focused pane runs
# it, otherwise move herdr pane focus, unzoom when leaving a zoomed pane, and
# wrap at layout edges unless nav_at_edge=stop.
#
# Usage: herdr-nav.sh <left|down|up|right>

set -uo pipefail

dir="${1:?usage: herdr-nav.sh <left|down|up|right>}"
herdr="${HERDR_BIN_PATH:-herdr}"

case "$dir" in
  left)  key="ctrl+h"; config_key="nav_key_left";  opp="right" ;;
  down)  key="ctrl+j"; config_key="nav_key_down";  opp="up"    ;;
  up)    key="ctrl+k"; config_key="nav_key_up";    opp="down"  ;;
  right) key="ctrl+l"; config_key="nav_key_right"; opp="left"  ;;
  *) echo "herdr-nav.sh: unknown direction: $dir" >&2; exit 2 ;;
esac

unzoom=1
nav_at_edge=wrap
config_path="${HERDR_SPLITS_CONFIG:-${HERDR_PLUGIN_CONFIG_DIR:-$HOME/.config/herdr/plugins/config/herdr-splits}/herdr-splits.conf}"

# Config parsing with builtins only (no sed/grep forks).
if [ -r "$config_path" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"                       # strip comments
    [ -z "$line" ] && continue
    case "$line" in
      *unzoom_on_nav*=*false*) unzoom=0 ;;
      *nav_at_edge*=*stop*)    nav_at_edge=stop ;;
      *"$config_key"*=*)
        v="${line#*=}"
        v="${v//[[:space:]]/}"
        [ -n "$v" ] && key="$v"
        ;;
    esac
  done < "$config_path"
fi

# --- call 1: pane identity + foreground process ----------------------------
info=$("$herdr" pane process-info --current 2>/dev/null)

if [[ $info =~ \"name\"[[:space:]]*:[[:space:]]*\"(n?vim|gvim|vimdiff|nvimdiff|view|vimx)\" ]]; then
  if [[ $info =~ \"pane_id\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
    # Neovim owns in-split movement, edge crossing and unzoom -- not us.
    exec "$herdr" pane send-keys "${BASH_REMATCH[1]}" "$key"
  fi
fi

# --- call 2: attempt the move; the response carries the rest ---------------
res=$("$herdr" pane focus --direction "$dir" --current 2>/dev/null)

changed=0
zoomed=0
case "$res" in
  *'"changed":true'*|*'"changed": true'*) changed=1 ;;
esac
case "$res" in
  *'"zoomed":true'*|*'"zoomed": true'*) zoomed=1 ;;
esac

# A zoomed pane fills the tab and reports no neighbours, so unzoom and retry.
if [ "$zoomed" -eq 1 ] && [ "$unzoom" -eq 1 ]; then
  "$herdr" pane zoom --off --current >/dev/null 2>&1
  [ "$changed" -eq 1 ] && exit 0
  res=$("$herdr" pane focus --direction "$dir" --current 2>/dev/null)
  case "$res" in
    *'"changed":true'*|*'"changed": true'*) exit 0 ;;
  esac
elif [ "$changed" -eq 1 ]; then
  exit 0
fi

# At a layout edge in the requested direction.
[ "$nav_at_edge" = stop ] && exit 0
exec "$herdr" pane focus --direction "$opp" --current
