# Personal dotfiles

macOS dotfiles: shell, terminals, prompt, tmux, Neovim, window manager, status bar and CLI tools. Managed with GNU `stow`; external toolchains and macOS defaults are restored via helper scripts in `scripts/`.

---

## What's in here

- **Shell** — `.zshrc`, `.zprofile`, `starship.toml`
- **Terminals** — `ghostty`, `kitty`, `wezterm`
- **Multiplexers** — `tmux` (with TPM plugins) and `sesh`; experimental `herdr` config
- **Editors** — Neovim (`lazy.nvim`), Vim (`vim-plug`), IdeaVim (`.ideavimrc`)
- **File manager** — `yazi` with a large plugin set (managed via `package.toml`)
- **Window manager / bar** — `aerospace`, `sketchybar`, `borders`, `karabiner`, `linearmouse`
- **Zsh plugins (tracked as git submodules / gitlinks)** — `fast-syntax-highlighting` (in `.config/fsh`) and `fzf-tab` (in `.config/fzf-tab`). These have no working `.gitmodules`, so they must be cloned manually — see below.
- **Tmux plugins (also tracked as gitlinks under `.config/tmux/plugins/`)** — TPM, catppuccin/tmux, tmux-sensible, tmux-yank, tmux-resurrect, tmux-continuum, tmux-prefix-highlight, smart-splits.nvim. Installed on-demand by TPM at first tmux launch.
- **Scripts** — `scripts/external_tools/` (Brew/Cargo/Go/UV manifests + restore), `scripts/mac_system/` (macOS `defaults` backup/restore), `scripts/themes/` (dark/light switcher), plus various helper scripts.

Work-specific items (`Secrets/`, `.claude/`, `.opencode/`, `raycast_scripts/`, some scripts) are gitignored or present only on the work machine.

---

## New machine setup (end-to-end)

Run in order. Steps 1–3 are prerequisites; the rest can be re-run any time.

### 1. Prerequisites

Install Homebrew (see https://brew.sh), then:

```bash
brew install git stow
```

### 2. Clone the repo

```bash
cd ~
git clone git@github.com:Rabeez/dotfiles.git
cd dotfiles
```

### 3. Stow the config into `$HOME`

```bash
stow .
```

`.stow-local-ignore` keeps `scripts/`, `Other/`, `Secrets/`, `Obsidian/`, etc. out of the stow tree.

### 4. Install external tools (Homebrew, Cargo, Go, UV)

The Brewfile installs everything: CLI tools, GUI casks, and the required nerd fonts (`Maple Mono NF`, `CaskaydiaCove Nerd Font`, `Symbols Only Nerd Font`, `SF Pro`, `Noto Color Emoji`).

```bash
# Dry-run first to see what would be installed
./scripts/external_tools/restore.sh
# Actually install
./scripts/external_tools/restore.sh -f
```

Manifests live under `scripts/external_tools/backups/` (`Brewfile`, `Cargofile`, `Gofile`, `UVfile`, `Miscfile`). `Miscfile` lists manual installs the script can't handle — read it and install those separately.

> Neovim is intentionally built from source (see `.zshrc` — it puts `~/Documents/Programming/ThirdParty/neovim/build/bin` first on `PATH`):
> ```bash
> git clone https://github.com/neovim/neovim ~/Documents/Programming/ThirdParty/neovim
> cd ~/Documents/Programming/ThirdParty/neovim
> make CMAKE_BUILD_TYPE=Release
> sudo make install
> ```

### 5. Clone the Zsh plugins (broken submodules)

`.config/fsh` and `.config/fzf-tab` are tracked as gitlinks with no `.gitmodules` file, so `git submodule update --init` will not resolve them. Clone them by hand:

```bash
# fast-syntax-highlighting → sourced from ~/.config/fsh/fast-syntax-highlighting.plugin.zsh
rm -rf ~/dotfiles/.config/fsh
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ~/dotfiles/.config/fsh

# fzf-tab → sourced from ~/.config/fzf-tab/fzf-tab.plugin.zsh
rm -rf ~/dotfiles/.config/fzf-tab
git clone https://github.com/Aloxaf/fzf-tab.git ~/dotfiles/.config/fzf-tab
```

`zsh-autosuggestions` and `zsh-vi-mode` are installed via Brew (already in the Brewfile) and sourced from `$(brew --prefix)/share/…`.

### 6. Initialize tmux plugins (TPM)

TPM itself is installed via Brew (`tpm` formula, sourced from `$HOMEBREW_PREFIX/opt/tpm/share/tpm/tpm`). On first tmux launch, install the plugins listed in `tmux.conf`:

```bash
# Start tmux (creates the "main" session via the tt() function)
tt

# Inside tmux, press: prefix + I   (prefix is C-a)
# Or from the shell, without entering tmux:
~/.config/tmux/plugins/tpm/bin/install_plugins
```

Plugins installed: `catppuccin/tmux`, `tmux-sensible`, `tmux-yank`, `tmux-resurrect`, `tmux-continuum`, `tmux-prefix-highlight`, `smart-splits.nvim`, `tmux-menus`, `tmux-scout`.

### 7. Neovim — first launch (lazy.nvim, Mason, Treesitter)

Neovim uses `lazy.nvim` to bootstrap itself. On first launch, it clones lazy, then installs every plugin, LSP server, formatter, linter and Treesitter parser. Just wait for it to finish.

```bash
nvim
# Wait until the Lazy popup reports "done". Then :q.
# Optional headless equivalents (useful for scripting a new machine):
nvim --headless "+Lazy! sync" +qa
nvim --headless "+MasonToolsInstall" +qa
nvim --headless "+TSUpdateSync" +qa
```

AI completion is [Supermaven](https://supermaven.com). On first use, run `:SupermavenUseFree` (or `:SupermavenUsePro` if you have a key) and follow the browser auth flow.

### 8. Vim — install plugins (vim-plug)

`vim-plug` itself is vendored at `.config/vim/autoload/plug.vim`, so no bootstrap needed.

```bash
vim +PlugInstall +qa
```

### 9. Yazi plugins

`package.toml` in `.config/yazi/` lists the managed plugins; `plugins/` also contains a few local ones (`no-status.yazi`, `types.yazi`, `zoom.yazi`, `piper.yazi`) that are checked in directly.

```bash
./scripts/update_yazi_plugins.sh -f
```

The script wipes only *managed* plugins (those referenced by `package.toml`) and re-installs them via `ya pkg upgrade`; local plugins are preserved.

### 10. Bat theme cache

```bash
bat cache --build
```

### 11. macOS system preferences

Restores `defaults` for Dock, Finder, trackpad, screencapture, etc., and runs curated modules under `scripts/mac_system/modules/`.

```bash
# Dry-run first
./scripts/mac_system/restore.sh --dry-run
# Apply
./scripts/mac_system/restore.sh
```

### 12. Secrets

Populate `~/dotfiles/Secrets/` (gitignored) with the API-key files referenced in `.zshrc` (`openai_api_key`, `anthropic_api_key`, `google_api_key`, `deepseek_api_key`, `backblaze_api_key`, `openai_api_key_pro`). Missing files are silently treated as empty by `_load_secret`, so this step is optional per key.

### 13. Reload the shell

```bash
exec zsh
```

You should see the "RR" ASCII art plus `fastfetch` output, and `starship` should be active.

---

## One-shot copy-paste (assumes prerequisites done)

```bash
cd ~/dotfiles && \
stow . && \
./scripts/external_tools/restore.sh -f && \
rm -rf .config/fsh .config/fzf-tab && \
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git .config/fsh && \
git clone https://github.com/Aloxaf/fzf-tab.git .config/fzf-tab && \
~/.config/tmux/plugins/tpm/bin/install_plugins && \
nvim --headless "+Lazy! sync" +qa && \
vim +PlugInstall +qa && \
./scripts/update_yazi_plugins.sh -f && \
bat cache --build && \
./scripts/mac_system/restore.sh && \
exec zsh
```

---

## Ongoing maintenance

- **Sync tool manifests before committing**: `./scripts/external_tools/backup.sh`
- **Sync macOS defaults**: `./scripts/mac_system/backup.sh`
- **Update Yazi plugins**: `./scripts/update_yazi_plugins.sh -f`
- **Update Neovim plugins**: `:Lazy sync` inside nvim
- **Update tmux plugins**: `prefix + U` inside tmux
- **Toggle dark/light theme**: `./scripts/set-theme.sh toggle` (or `prefix + T` in tmux)
