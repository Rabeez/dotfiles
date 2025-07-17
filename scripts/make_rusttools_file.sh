#!/usr/bin/env bash

find "$HOME/.cargo/bin" -maxdepth 1 -type f | while read -r file; do
    if file "$file" | grep -q "executable"; then
        echo "cargo install $(basename "$file")"
    fi
done > "$HOME/dotfiles/rust_tools.txt"
