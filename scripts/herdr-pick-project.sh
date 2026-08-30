#!/usr/bin/env bash
# Project picker for herdr (bound to prefix+f).
#
# The herdr equivalent of `sesh connect $(sesh list -c -z)`: fuzzy-pick any
# candidate directory (curated sesh.toml entries + zoxide), then focus the
# matching workspace if it already exists, or create it if it doesn't.

set -uo pipefail

here="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=/dev/null
. "$here/herdr-fzf-common.sh"

command -v herdr >/dev/null 2>&1 || { echo "herdr not found" >&2; sleep 2; exit 1; }
command -v fzf   >/dev/null 2>&1 || { echo "fzf not found" >&2;   sleep 2; exit 1; }
command -v jq    >/dev/null 2>&1 || { echo "jq not found" >&2;    sleep 2; exit 1; }

list=$("$here/herdr-project-list.sh" 2>/dev/null)
if [ -z "$list" ]; then
  echo "No candidate projects found." >&2
  sleep 2
  exit 0
fi

# label \t path, with $HOME shortened to ~ for display only.
display=$(printf '%s\n' "$list" | awk -F'\t' -v h="$HOME" '{
  p = $2
  sub("^" h, "~", p)
  print $1 "\t" p "\t" $2
}')

FZF_OPTS=()
while IFS= read -r _opt; do FZF_OPTS+=("$_opt"); done < <(_herdr_fzf_opts)

selected=$(printf '%s\n' "$display" \
  | fzf "${FZF_OPTS[@]}" \
        --delimiter='\t' \
        --with-nth='{1}  {2}' \
        --nth=1,2 \
        --prompt='  ' \
        --no-header) || exit 0

[ -z "$selected" ] && exit 0

label=$(printf '%s' "$selected" | cut -f1)
path=$(printf '%s' "$selected" | cut -f3)
[ -n "$path" ] || exit 0

# Use the $dir metadata token (set by the rabeez.workspace plugin's on-focus
# hook) as the canonical cwd identity. The worktree field is always null for
# non-managed-worktree workspaces, and label dedupes on basename which breaks
# inside monorepos. Fall back to full path match if no $dir token exists yet.
short_dir="${path##*/}"
[ "$path" = "$HOME" ] && short_dir="~"

existing=$(herdr workspace list 2>/dev/null \
  | jq -r --arg dir "$short_dir" --arg cwd "$path" \
      '.result.workspaces[]
       | select((.tokens.dir == $dir) or (.tokens.dir == $cwd))
       | .workspace_id' 2>/dev/null \
  | head -1)

# Generate a label from the last dirname.
new_label="$short_dir"

if [ -n "$existing" ]; then
  herdr workspace focus "$existing" >/dev/null 2>&1
else
  herdr workspace create --cwd "$path" --label "$new_label" --focus >/dev/null 2>&1
fi
