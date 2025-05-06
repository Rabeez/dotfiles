#!/usr/bin/env bash

if [[ "$1" == "-f" ]]; then
    echo "Running commands..."
    rm -rf .config/yazi/plugins
    ya pack -u
    command3
else
    echo "Run with -f to execute commands."
    echo "Before this, make sure that no 'manual' plugins exist in yazi config plugins directory"
    echo "    such as those from yazi docs (tips page)."
    echo "These will not have an entry in yazi package.toml"
fi
