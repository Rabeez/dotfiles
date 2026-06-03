#!/usr/bin/env bash
# Keep only the 10 most recent resurrect save files
resurrect_dir="$HOME/.tmux/resurrect"
ls -t "$resurrect_dir"/tmux_resurrect_*.txt 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null
