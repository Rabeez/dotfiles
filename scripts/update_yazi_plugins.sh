#!/usr/bin/env bash

if [[ "$1" == "-f" ]]; then
    echo "Running commands..."
    rm -rf .config/yazi/plugins
    ya pkg upgrade
else
    echo "Run with -f to execute commands!!!"
    echo ""
    echo "Before this, make sure that no *manual* plugins exist in yazi config plugins directory"
    echo "    such as those from yazi docs (tips page)."
    echo "These will not have an entry in yazi package.toml"
    echo ""
    echo "You can run these commands to verify manually:"
    echo "    'ls .config/yazi/plugins'"
    echo "    'cat .config/yazi/package.toml | rg use | sed \"s .*/  \" | tr --delete '\"' | sed \"s/plugins://\" | xargs -I {} echo \"{}.yazi\" | sort'"
fi
