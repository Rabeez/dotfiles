#!/usr/bin/env bash

# NOTE: Ensure `emacs-plus@30` matches the actual version installed.
# This command is from the "caveats" section printed by `brew install`
osascript -e 'tell application "Finder" to make alias file to posix file "/opt/homebrew/opt/emacs-plus@30/Emacs.app" at posix file "/Applications" with properties {name:"Emacs.app"}'
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/dotfiles/.config/emacs
stow .
~/dotfiles/.config/emacs/bin/doom install
