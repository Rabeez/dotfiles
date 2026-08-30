#!/usr/bin/env bash
# Emit the list of candidate projects for herdr's prefix+f picker.
#
# This is the herdr equivalent of `sesh list -c -z`: it merges the curated
# entries from ~/.config/sesh/sesh.toml with the zoxide frecency database, so
# useful directories are *selectable* without having to exist as open
# workspaces. Nothing here creates a workspace -- that only happens when you
# pick something.
#
# Output: one entry per line, "<label>\t<path>", curated entries first.
#
# Zoxide priming, run once to seed:
#   fd -H -t d '^\.git$' ~/Programming/ --max-depth 4 -E node_modules -x dirname \
#   | xargs -I {} zoxide add {}

set -uo pipefail

SESH_TOML="${SESH_TOML:-$HOME/.config/sesh/sesh.toml}"

emit_curated() {
  [ -r "$SESH_TOML" ] || return 0
  python3 - "$SESH_TOML" <<'PY' 2>/dev/null
import os, sys, tomllib
try:
    with open(sys.argv[1], "rb") as fh:
        data = tomllib.load(fh)
except Exception:
    sys.exit(0)
for s in data.get("session", []):
    path, name = s.get("path"), s.get("name")
    if not path or not name:
        continue
    p = os.path.abspath(os.path.expanduser(path))
    if os.path.isdir(p):
        print(f"{name}\t{p}")
PY
}

emit_zoxide() {
  command -v zoxide >/dev/null 2>&1 || return 0
  zoxide query -l 2>/dev/null | while IFS= read -r p; do
    [ -d "$p" ] || continue
    printf '%s\t%s\n' "$(basename "$p")" "$p"
  done
}

# Curated first, then zoxide; drop duplicate paths, keeping the first (curated)
# label so nicely-named entries win over a bare basename.
{ emit_curated; emit_zoxide; } | awk -F'\t' '!seen[$2]++'
