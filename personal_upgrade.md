# Upgrade Plan: `~/dotfiles` (Personal) from `~/dotfiles_WORK`

## Repos

- **Personal**: `~/dotfiles` (remote: github.com:Rabeez/dotfiles)
- **Work**: `~/dotfiles_WORK` (this repo)

---

## Things NOT to Port (work-specific)

- `Secrets/`, `.claude/`, `.opencode/`, `.pip/`, `raycast_scripts/`
- Work env vars (`BOLTML_DS_REPO_PATH`, `DATABRICKS_TOKEN`, `DATAHUB_TOKEN`, etc.)
- Work completions (AWS CLI, Databricks CLI, `syncher`)
- Work-only aliases (`s="syncher"`, `bh`)
- Work-only scripts (`scripts/db-new-project.sh`, `scripts/db-open-project.sh`, `scripts/s3-syncer.sh`)
- `.config/syncer-databricks-local/`, `.config/syncher/`
- `.config/github-copilot/` (personal uses Supermaven)
- Work planning docs (`backblaze_plan.md`, `ext_tools_backup_plan.md`, `mac_scripts_plan.md`)

---

## Phase 1: Shell (`.zshrc`)

| # | Change | Source (work) | Target (personal) |
|---|--------|---------------|-------------------|
| 1 | Replace hardcoded `/opt/homebrew/...` with `$HOMEBREW_PREFIX` | `~/dotfiles_WORK/.zshrc` | `~/dotfiles/.zshrc` |
| 2 | Add `ZVM_VI_YANK_CLIP=1`, `ZVM_VI_PUT_CLIP=1` | `~/dotfiles_WORK/.zshrc` | `~/dotfiles/.zshrc` |
| 3 | Add `clip()` function (copy file to clipboard) | `~/dotfiles_WORK/.zshrc` | `~/dotfiles/.zshrc` |
| 4 | Add `mdopen()` function (markdown preview) | `~/dotfiles_WORK/.zshrc` | `~/dotfiles/.zshrc` |
| 5 | Refactor secrets loading to `_load_secret` helper | `~/dotfiles_WORK/.zshrc` | `~/dotfiles/.zshrc` |
| 6 | Add `~/.local/bin` to PATH | `~/dotfiles_WORK/.zshrc` | `~/dotfiles/.zshrc` |
| 7 | Replace auto-start tmux with `tt()` function | `~/dotfiles_WORK/.zshrc` (lines 315-327) | `~/dotfiles/.zshrc` (replace lines 252-263) |
| 8 | Add `tmux_sesh_info` alias | `~/dotfiles_WORK/.zshrc` (line 106) | `~/dotfiles/.zshrc` |
| 9 | Update `cloc` alias (sort by code, commas) | `~/dotfiles_WORK/.zshrc` | `~/dotfiles/.zshrc` |
| 10 | Add `cl="claude"` alias | `~/dotfiles_WORK/.zshrc` | `~/dotfiles/.zshrc` |

---

## Phase 2: Starship + Ghostty + IdeaVim

| # | Change | Source | Target |
|---|--------|--------|--------|
| 1 | Add Python env `format` line | `~/dotfiles_WORK/.config/starship.toml` | `~/dotfiles/.config/starship.toml` |
| 2 | Add `maximize = true` | `~/dotfiles_WORK/.config/ghostty/config` | `~/dotfiles/.config/ghostty/config` |
| 3 | Create `.ideavimrc` | `~/dotfiles_WORK/.ideavimrc` | `~/dotfiles/.ideavimrc` |

---

## Phase 3: Tmux

| # | Change | Source | Target |
|---|--------|--------|--------|
| 1 | Add tmux-resurrect (nvim strategy, custom dir) | `~/dotfiles_WORK/.config/tmux/tmux.conf` | `~/dotfiles/.config/tmux/tmux.conf` |
| 2 | Add tmux-continuum (`@continuum-boot 'on'`) | same | same |
| 3 | Prepend `pane_current_path` (blue) to status bar | same | same |

---

## Phase 4: Yazi (full overhaul)

| # | Change | Source | Target |
|---|--------|--------|--------|
| 1 | Replace `yazi.toml` (new schema, previewers) | `~/dotfiles_WORK/.config/yazi/yazi.toml` | `~/dotfiles/.config/yazi/yazi.toml` |
| 2 | Replace `keymap.toml` (zoxide, fzf, chmod, zoom, utils, perms) | `~/dotfiles_WORK/.config/yazi/keymap.toml` | `~/dotfiles/.config/yazi/keymap.toml` |
| 3 | Replace `theme.toml` (new schema) | `~/dotfiles_WORK/.config/yazi/theme.toml` | `~/dotfiles/.config/yazi/theme.toml` |
| 4 | Replace `package.toml` (add types, zoxide, fzf, chmod, diff, zoom) | `~/dotfiles_WORK/.config/yazi/package.toml` | `~/dotfiles/.config/yazi/package.toml` |
| 5 | Update `init.lua` (`order = 1500`) | `~/dotfiles_WORK/.config/yazi/init.lua` | `~/dotfiles/.config/yazi/init.lua` |
| 6 | Update Catppuccin Mocha tmTheme | `~/dotfiles_WORK/.config/yazi/Catppuccin Mocha.tmTheme` | `~/dotfiles/.config/yazi/Catppuccin Mocha.tmTheme` |
| 7 | Add `.luarc.json` | `~/dotfiles_WORK/.config/yazi/.luarc.json` | `~/dotfiles/.config/yazi/.luarc.json` |
| 8 | Replace `scripts/update_yazi_plugins.sh` (uses lib/, preserves local plugins) | `~/dotfiles_WORK/scripts/update_yazi_plugins.sh` | `~/dotfiles/scripts/update_yazi_plugins.sh` |

---

## Phase 5: Neovim

| # | Change | Source | Target |
|---|--------|--------|--------|
| 1 | Migrate `nvim-web-devicons` → `mini.icons` with compat shim | `~/dotfiles_WORK/.config/nvim/lua/plugins/visuals.lua` | `~/dotfiles/.config/nvim/lua/plugins/visuals.lua` |
| 2 | Port `core.lua`: `YankFileLine`, `QfSort`, `ToggleWrap`, enhanced `gf`, Pixi python provider | `~/dotfiles_WORK/.config/nvim/lua/config/core.lua` | `~/dotfiles/.config/nvim/lua/config/core.lua` |
| 3 | Port `keymaps.lua`: `<leader>un` (TODO comment), `ToggleScrollWheel` | `~/dotfiles_WORK/.config/nvim/lua/config/keymaps.lua` | `~/dotfiles/.config/nvim/lua/config/keymaps.lua` |
| 4 | AI: Keep Supermaven, align keymaps to match work Copilot style. Add lualine indicator (already exists). | `~/dotfiles_WORK/.config/nvim/lua/plugins/ai.lua` (reference only) | `~/dotfiles/.config/nvim/lua/plugins/ai.lua` |
| 5 | Port `ToggleAutoFormat` + path-disable system (empty paths list for personal) | `~/dotfiles_WORK/.config/nvim/lua/plugins/linting_formatting.lua` | `~/dotfiles/.config/nvim/lua/plugins/linting_formatting.lua` |
| 6 | Port treesitter simplification (`branch = "main"`, stripped deps) | `~/dotfiles_WORK/.config/nvim/lua/plugins/treesitter.lua` | `~/dotfiles/.config/nvim/lua/plugins/treesitter.lua` |
| 7 | Add `after/queries/` injection files (SQL-in-Python etc.) — **NOTE**: personal `.gitignore` already ignores this path; remove that ignore line first | `~/dotfiles_WORK/.config/nvim/after/queries/` | `~/dotfiles/.config/nvim/after/queries/` |
| 8 | Port snacks.lua visual-mode `<leader>gl` (line-range git log) | `~/dotfiles_WORK/.config/nvim/lua/plugins/snacks.lua` | `~/dotfiles/.config/nvim/lua/plugins/snacks.lua` |
| 9 | Port neo-tree git status symbols | `~/dotfiles_WORK/.config/nvim/lua/plugins/filetree.lua` | `~/dotfiles/.config/nvim/lua/plugins/filetree.lua` |
| 10 | Add `sessions.lua` (vim-obsession) | `~/dotfiles_WORK/.config/nvim/lua/plugins/sessions.lua` | `~/dotfiles/.config/nvim/lua/plugins/sessions.lua` |
| 11 | Port catppuccin snacks integration | `~/dotfiles_WORK/.config/nvim/lua/plugins/color_schemes.lua` | `~/dotfiles/.config/nvim/lua/plugins/color_schemes.lua` |
| 12 | Move `flash.nvim` from `navigation.lua` to `editing.lua` | `~/dotfiles_WORK/.config/nvim/lua/plugins/editing.lua` | `~/dotfiles/.config/nvim/lua/plugins/editing.lua` |
| 13 | Port path-based autoformat disable (with empty personal paths list) | `~/dotfiles_WORK/.config/nvim/lua/plugins/linting_formatting.lua` | `~/dotfiles/.config/nvim/lua/plugins/linting_formatting.lua` |

---

## Phase 6: Bat Theme

| # | Change | Source | Target |
|---|--------|--------|--------|
| 1 | Update `Catppuccin Mocha.tmTheme` | `~/dotfiles_WORK/.config/bat/themes/Catppuccin Mocha.tmTheme` | `~/dotfiles/.config/bat/themes/Catppuccin Mocha.tmTheme` |

---

## Phase 7: fzf-tab

| # | Change | Source | Target |
|---|--------|--------|--------|
| 1 | Fix broken submodule state — remove orphaned gitlink (no `.gitmodules`), re-add as proper submodule or vendor like work | `~/dotfiles_WORK/.config/fzf-tab` (commit `fc6f0dc`) | `~/dotfiles/.config/fzf-tab` |

---

## Phase 8: Scripts & Unified Backup System

| # | Change | Source | Target |
|---|--------|--------|--------|
| 1 | Add `scripts/lib/` (checks.sh, log.sh) | `~/dotfiles_WORK/scripts/lib/` | `~/dotfiles/scripts/lib/` |
| 2 | Port `scripts/external_tools/` backup system | `~/dotfiles_WORK/scripts/external_tools/` | `~/dotfiles/scripts/external_tools/` |
| 3 | Port `scripts/mac_system/` backup system | `~/dotfiles_WORK/scripts/mac_system/` | `~/dotfiles/scripts/mac_system/` |
| 4 | Remove redundant old scripts: `backup_brewfile.sh`, `backup_gotools_file.sh`, `backup_rusttools_file.sh`, `backup_systemtools_files.sh`, `reinstall_gotools.sh`, `reinstall_rusttools.sh` | — | `~/dotfiles/scripts/` |
| 5 | Remove root-level manifests (will live in `scripts/external_tools/backups/`): `Brewfile`, `go_tools.txt`, `rust_tools.txt` | — | `~/dotfiles/` |

---

## Phase 9: POSIX Compliance — `scripts/browser-memory.sh`

Ensure `scripts/browser-memory.sh` is fully POSIX-compliant and works on any macOS machine regardless of bash/zsh version.

**Current issues (in `~/dotfiles_WORK/scripts/browser-memory.sh`):**
- Shebang is `#!/usr/bin/env bash` with `set -euo pipefail` (bashism) — contradicts the "POSIX sh compatible" comment
- Uses `${BASH_SOURCE[0]}` (bash-only) for script dir detection
- Uses `source` keyword (bash/zsh — POSIX equivalent is `.`)
- The inner collection script (`$_collect_script`) correctly uses `#!/bin/sh` and POSIX constructs

**Fixes needed:**
1. Change shebang to `#!/bin/sh` or keep bash but remove the misleading "POSIX compatible" comment
2. Replace `${BASH_SOURCE[0]}` with `$0` (acceptable for direct execution) or a POSIX-safe alternative
3. Replace `source` with `.` (dot-source)
4. Replace `set -euo pipefail` with `set -eu` (pipefail is not POSIX)
5. Verify all remaining constructs (trap, mktemp, while IFS read, case, arithmetic) — these are all POSIX-safe already

**Target**: Both `~/dotfiles_WORK/scripts/browser-memory.sh` and `~/dotfiles/scripts/browser-memory.sh`

---

## Notes from Latest Personal Repo State

- Personal recently added `.config/raycast-x/extensions` to `.gitignore` — raycast config is being set up there too
- `.config/nvim/after/queries` is already in personal `.gitignore` — must remove that line before committing the injection query files
- `lazy-lock.json` and `.aerospace.toml` got minor updates from another machine — no conflict with this plan

---

## Decision Points (resolve before executing)

1. **Tmux session name**: Work uses `main`, personal uses `root-default`. Change personal to `main`?
2. **Old scripts removal**: Confirm OK to delete individual `backup_*.sh` / `reinstall_*.sh` and root-level `Brewfile`, `go_tools.txt`, `rust_tools.txt` once unified system is in place?
3. **Supermaven keymaps**: Keep current (`<Tab>` accept, `<C-]>` clear, `<C-j>` word) or change?
4. **ASCII art**: Keep "RR" branding in personal or change?

---

## Post-Pull Steps (after changes are pushed to personal repo and pulled on target machine)

Run these on the personal machine after `git pull`:

```bash
# 1. Re-stow dotfiles (if using GNU stow)
cd ~/dotfiles && stow .

# 2. fzf-tab submodule — initialize after fixing
git submodule update --init --recursive

# 3. Yazi plugins — reinstall with new package.toml
cd ~/dotfiles && ./scripts/update_yazi_plugins.sh -f

# 4. Bat theme rebuild
bat cache --build

# 5. Neovim — sync plugins (lazy-lock changed, new plugins added)
nvim --headless "+Lazy sync" +qa

# 6. Neovim — Mason tool updates (if needed)
nvim --headless "+MasonToolsUpdate" +qa

# 7. Tmux — install new plugins (resurrect, continuum)
# Press prefix + I inside tmux (TPM install), or:
~/.config/tmux/plugins/tpm/bin/install_plugins

# 8. Verify secrets loading
# Ensure secret files referenced by _load_secret exist at expected paths

# 9. Verify browser-memory.sh works
./scripts/browser-memory.sh

# 10. Source new shell config
exec zsh
```
