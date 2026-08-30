#!/usr/bin/env bash
# New project scaffold for herdr (bound to prefix+n).
#
# Exact replica of the tmux prefix+n popup:
#   1. Prompt for a project name
#   2. Create ~/Programming/Probe/<name>
#   3. git init
#   4. Open a herdr workspace focused on it

set -uo pipefail

here="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=/dev/null
. "$here/herdr-fzf-common.sh"

command -v herdr >/dev/null 2>&1 || { echo "herdr not found" >&2; sleep 2; exit 1; }

# Read the theme-mode for fzf styling (not used for the input, but keeps
# the visual language consistent if we ever add a picker step).
mode="dark"
[ -r "$HOME/.local/state/theme-mode" ] && mode="$(cat "$HOME/.local/state/theme-mode" 2>/dev/null)"

printf '\n'
printf '  \033[1mNew project\033[0m\n'
printf '  ~/Programming/Probe/<name>\n\n'
printf '  Name: '
read -r NAME

[ -z "$NAME" ] && exit 0

DIR="$HOME/Programming/Probe/$NAME"

if ! mkdir -p "$DIR"; then
  echo "  Failed to create $DIR" >&2
  sleep 2
  exit 1
fi

git -C "$DIR" init --quiet >/dev/null 2>&1

herdr workspace create --cwd "$DIR" --label "$NAME" --focus >/dev/null 2>&1
