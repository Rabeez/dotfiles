# Personal dotfiles collections

Various dotfiles from my mac setup including terminal, shell, prompt, nvim, window manager, status bar and some CLI tools.

## Setup

After [homebrew](https://brew.sh) is installed execute these commands:
```bash
cd ~
brew install git stow
git clone git@github.com:Rabeez/dotfiles.git
cd dotfiles
stow .
```

Some configurations depend on other tools (e.g. `jq`, `rg` etc.) 
