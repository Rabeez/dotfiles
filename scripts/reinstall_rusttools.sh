#!/usr/bin/env bash

while read -r line; do
    eval "$line"
done < "$HOME/dotfiles/rust_tools.txt"
