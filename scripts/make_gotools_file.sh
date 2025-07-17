#!/usr/bin/env bash

find "$HOME/go/bin" -maxdepth 1 -type f | sed -E "s:.*/([^/]+)$:go install \1@latest:" > "$HOME/dotfiles/go_tools.txt"
