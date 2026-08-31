# AGENTS.md — repo map for future edits

This file is for AI agents (and future-me). It documents where things live and how they connect, focused on the systems that break when you touch them without understanding the coupling.

Repo root: `~/dotfiles`. Deployed to `$HOME` via `stow .`. `.stow-local-ignore` keeps `scripts/`, `Other/`, `Secrets/`, `Obsidian/`, `README.md` out of the stow tree.

---

## 0. Work-specific — check first

Before doing anything else, check for `~/dotfiles/INSTRUCTIONS_FOR_WORK.md`.

- **If it exists** → this is a work machine. That file contains work-specific context (extra tools, paths, credentials layout, corporate networks, sync rules, work-only aliases, etc.) that overrides or extends anything in this AGENTS.md. Read it in full before making changes, and follow its rules wherever they conflict with the personal defaults documented here.
- **If it does not exist** → this is a personal machine. Everything below applies as-is. Do not invent work-only paths or tools.

`INSTRUCTIONS_FOR_WORK.md` is gitignored on the personal machine and only present on the work machine's clone. Never commit it from a personal machine.

---

## 1. Theme system (Catppuccin Mocha ↔ Latte)

### State

- **Source of truth:** `~/.local/state/theme-mode` — plain text, `dark` or `light`. Every component reads this file.
- **Machine-local overrides:** `scripts/themes/local.sh` (gitignored). Sets `WALLPAPER_DARK` / `WALLPAPER_LIGHT`.

### Entry point

`scripts/set-theme.sh [dark|light|toggle]` — the only thing that should mutate theme state. Bound to `prefix+T` in tmux (`.config/tmux/tmux.conf:157`) and `prefix+shift+t` in herdr (`.config/herdr/config.toml:242`).

Each `switch_<tool>()` function edits its config with `sed -i ''` (BSD sed, macOS-only) and, where possible, live-reloads the running instance. `main()` at `set-theme.sh:454` calls them in sequence.

### Tools it drives

| Tool | Config touched | Live reload? |
|---|---|---|
| macOS appearance | — | `osascript` |
| wallpaper | — | `osascript` |
| tmux | `.config/tmux/tmux.conf` + re-sources catppuccin flavor conf | yes |
| neovim | writes `~/.config/nvim/colorscheme` (gitignored) + sends `:colorscheme` to every socket under `$TMPDIR/nvim*/nvim.*` | yes |
| wezterm | writes `~/.config/wezterm/colorscheme` (gitignored) | auto (wezterm watches file) |
| kitty | swaps `include` line for `catppuccin-{mocha,latte}.conf` | `pkill -SIGUSR1 -f "MacOS/kitty"` |
| ghostty | none — reads macOS appearance directly (see `theme = dark:...,light:...` in `.config/ghostty/config`) | auto |
| herdr | bulk hex swap in `.config/herdr/config.toml` | `herdr server reload-config` |
| bat | `--theme=` line in `~/.config/bat/config` | on next invocation |
| delta | `features = catppuccin-...` in `~/.gitconfig` | on next invocation |
| starship | `palette` line in `.config/starship.toml` | on next prompt |
| lazygit | bulk hex swap in `~/.config/lazygit/config.yml` | on relaunch |
| **yazi** | **file copy** from `scripts/themes/yazi-{mocha,latte}.toml` → `~/.config/yazi/theme.toml` | on relaunch |
| btop, zellij, spotify_player, vim, superfile, glow | in-file sed | on relaunch |
| vivid / LS_COLORS | regenerates `~/.cache/vivid-ls-colors` | see `_refresh_theme_env` below |
| sketchybar | bulk hex swap in `.config/sketchybar/colors.sh` → `sketchybar --bar/--set/--default` (**not** `--reload`, which breaks aliases) | yes |
| borders | `active_color`/`inactive_color` in `.config/borders/bordersrc` | `pkill borders && exec bordersrc` |
| fzf | (via shell hook) | see `_refresh_theme_env` |

### Shell live-reload (`_refresh_theme_env`)

`.zshrc:91–104` — precmd hook that runs every prompt:

1. If `stat -f %m ~/.cache/vivid-ls-colors` changed → re-export `LS_COLORS`.
2. If `~/.local/state/theme-mode` changed → source `scripts/themes/fzf-${mode}.sh` (which sets `FZF_DEFAULT_OPTS`).

Initial load: `.zshrc:76–86` reads the state file, generates the vivid cache if missing, exports `LS_COLORS`. Line 204 sources the fzf theme.

Also the "RR" ASCII banner (`.zshrc:255–289`) picks blue tones per theme; skipped when `$HERDR_ENV` is set (else it would repaint in every herdr pane).

### Adding a new tool to the theme system

1. Write a `switch_<tool>()` function in `scripts/set-theme.sh` (follow the pattern of an existing one).
2. Call it from `main()`.
3. If the tool has multiple theme files, put them in `scripts/themes/<tool>-{mocha,latte}.<ext>` and copy them (like `switch_yazi`); otherwise sed the config in place.
4. Consider live-reload: signal-based (`pkill -SIGUSR1`), IPC (`--server ... --remote-send`), file-watch (wezterm), or none.

### Missing tools

Not every machine has every tool in the switcher table. `switch_<tool>()` functions should be defensive — if the binary or config path is missing, log a warning and return, don't fail the whole toggle. When adding a new switcher, guard with `check_cmd` (from `scripts/lib/checks.sh`) or `[[ -f "$config" ]]` before running sed / signalling / IPC. A machine without e.g. `borders`, `sketchybar`, `spotify_player`, or `lazygit` installed should still be able to toggle themes for everything else.

### Theme system gotchas

- Editing `.config/yazi/theme.toml` directly is pointless — it's overwritten. Edit `scripts/themes/yazi-{mocha,latte}.toml`.
- `set_state` writes state **before** switchers run; a mid-run failure leaves the state file lying. No rollback.
- LSP reference highlights in Neovim are hardcoded to mocha's `surface1` (`.config/nvim/lua/plugins/lsp.lua:338`) even in light mode.

---

## 2. Workspace / session management (tmux + sesh + herdr)

Two parallel systems with the same key layout. Use one or the other; not both simultaneously.

### tmux — `tt()` in `.zshrc:363`

- Requires `tmux` + `sesh`. Refuses to nest.
- Always attaches to session named `main`; creates via `sesh connect main` (falls back to `tmux new-session`).

### herdr — `th()` in `.zshrc:387`

- Requires `herdr` + `jq`. Refuses to nest (`$HERDR_ENV`).
- Starts detached server if not running, waits up to 5s.
- Ensures workspace `main` exists; focuses it only if session came up empty (else respects restored focus).
- Forwards args to `herdr` when given (so `th workspace list` etc. work).

### Popup keybinds — mirrored between tmux and herdr

| Key | tmux (`.config/tmux/tmux.conf`) | herdr (`.config/herdr/config.toml`) |
|---|---|---|
| `prefix+f` | line 177 — `scripts/tmux-pick-project.sh` | lines 201-206 — `scripts/herdr-pick-project.sh` |
| `prefix+w` | lines 180-184 — inline `sesh list \| gum filter \| sesh connect` | lines 210-215 — `scripts/herdr-pick-workspace.sh` |
| `prefix+a` | line 179 — `scripts/tmux-agent/pick.sh` | lines 226-231 — `scripts/herdr-pick-agent.sh` |
| `prefix+n` | lines 199-215 — inline bash creates `~/Programming/Probe/<name>` + `git init` + `sesh connect` | lines 234-239 — `scripts/herdr-new-project.sh` (same) |
| `prefix+g` | line 178 — `lazygit` popup | — (nvim `<leader>gg` uses snacks.lazygit) |
| `prefix+T` | line 157 — theme toggle | lines 242-245 — theme toggle |
| `prefix+L` | line 154 — `sesh last` | — |
| `prefix+I` | (tpm) install plugins | — |

Splits: `prefix+h` / `prefix+v` inherit `#{pane_current_path}` (tmux only — herdr has plugin-managed splits). Window jumps: `prefix+1..5`.

Non-prefix pane nav (both): `C-h/j/k/l`. In tmux via `smart-splits.nvim`, in herdr via the local `herdr-splits` plugin (`.config/herdr/plugins-local/herdr-splits/`). Both detect Neovim (`@pane-is-vim` / equivalent) and delegate.

### sesh config

`.config/sesh/sesh.toml` — five hard-coded named sessions (`Downloads`, `Screenshots`, `dotfiles`, `Obsidian Main Vault`, `Spotify Music`).

### Project picker (`scripts/tmux-pick-project.sh`)

- Feeds `sesh list -i -c -z -t -H -d` (merges sesh sessions + zoxide + tmux sessions + home dirs) into `gum filter` with theme-aware colors.
- If selection starts with `~/` or `/`: creates a fresh tmux session named `<basename>-<N>` (N auto-increments).
- If bare name: `sesh connect $name`.

### tmux-agent picker (`scripts/tmux-agent/`)

Finds and focuses tmux panes running OpenCode. Pipeline: `extract.sh | colorize.sh | fzf`.

- `extract.sh` — Emits TSV per opencode pane: `pane_id | marker | state | dir | session | title | mru_key`. Discovers sessions via (A) `~/.tmux-scout/status.json`, (B) walking process tree (cached `ps`, max depth 5), (C) `—`. Titles come from `$HOME/.local/share/opencode/opencode.db` via batched sqlite3.
- `colorize.awk` — colors per state (BUSY/WAIT/IDLE/DONE/DEAD).
- `pick.sh` — `tmux switch-client` + `select-window` + `select-pane` to selected pane. Timing debug via `TMUX_AGENT_TIME=1`.

### herdr scripts (`scripts/herdr-*.sh`)

- `herdr-fzf-common.sh` — shared `_herdr_fzf_opts()` (theme colors).
- `herdr-project-list.sh` — merges `~/.config/sesh/sesh.toml` (parsed via inline `python3 -c "import tomllib..."`) with `zoxide query -l`, dedupes by path.
- `herdr-pick-project.sh` / `-pick-workspace.sh` / `-pick-agent.sh` — pickers.
- `herdr-new-project.sh` — scaffolds a new project dir.
- `herdr-bootstrap-workspaces.sh` — **template** for a nuclear reset of herdr state. Edit the Paths section (~line 106) before running. Deletes `session.json` + `session-history.json`, restarts server, recreates workspaces via `create_ws()` / `create_ws_3pane()`.
- `herdr-setup-plugins.sh` — idempotently `unlink`s + `link`s every plugin under `.config/herdr/plugins-local/*/`. Run with `-f`.

### tmux-resurrect / continuum

`.config/tmux/tmux.conf:37-49`:
- `@resurrect-strategy-nvim 'session'`, `@resurrect-processes 'true'`, `@resurrect-capture-pane-contents 'on'`, `@resurrect-dir '$HOME/.tmux/resurrect'`.
- `@continuum-restore 'on'`.
- Hooks: `resurrect-post-restore.sh` (waits 3s, sends `cd $dir && clear` to shell panes to fix CWD), `resurrect-cleanup.sh` (keeps 10 most recent saves).
- `default-command "${SHELL}"` — non-login shell inside tmux (fixes CWD reset).

### tmux plugins

Listed at `.config/tmux/tmux.conf:219-228`. TPM is **brew-installed**, entry point at `$HOMEBREW_PREFIX/opt/tpm/share/tpm/tpm` (line 241) — NOT `~/.tmux/plugins/tpm/tpm`. Actual plugin dirs (`.config/tmux/plugins/*`) are tracked as gitlinks but populated by TPM on demand.

---

## 3. Terminal / window management / keyboard focus

Not every machine runs AeroSpace. Some machines skip a real WM entirely and rely on **direct app-launch hotkeys** (Leader Key, Raycast, Karabiner complex mods, macOS Spotlight) to pull specific apps to the foreground — an "almost-fake WM" where focus jumps between fullscreen/floating windows on demand instead of being tiled. When editing this section:

- Treat AeroSpace as **optional**. If `.aerospace.toml` isn't loaded on a given machine, the sketchybar `aerospace_workspace_change` event never fires, and the "Focus flow" chain below effectively starts at step 3 (kitty/Ghostty).
- Direct-launch machines lean on `.config/leader_key/config.json` and Raycast hotkeys as the primary focus mechanism. Adding a keybind for "focus X app" should probably go there rather than into `.aerospace.toml`.
- `switch_sketchybar` / `switch_borders` are still safe on a WM-less machine — they no-op if the daemons aren't running (see §1 "Missing tools").

### Focus flow (outer → inner)

1. **Karabiner** — `.config/karabiner/karabiner.json`. Single rule: caps_lock → left_control if held, escape if tapped.
2. **AeroSpace** (`.aerospace.toml`) — tiling WM.
   - `ctrl-alt-h/j/k/l` focus, `ctrl-shift-h/j/k/l` move.
   - `ctrl-1..5` workspaces, `ctrl-shift-1..5` move node to workspace.
   - `ctrl-/` tiles, `ctrl-,` accordion.
   - `ctrl-shift-;` → service mode (esc reload, r flatten, f floating, backspace close-others).
   - Auto-placement rules at lines 185–280: WS1 browsers, WS2 terminals/editors, WS3 Finder, WS4 notes, WS5 media.
   - Launches `sketchybar` and `borders` at startup (lines 20–23). Triggers `sketchybar --trigger aerospace_workspace_change` on workspace change (line 26).
3. **kitty** (`.config/kitty/kitty.conf:64–73`) → sends `\x01<key>` (i.e. `C-a` + key) so `cmd+t/w/z/l/1..5` become herdr prefix chords.
4. **Ghostty** → same trick to feed tmux prefix.
5. **tmux/herdr pane nav** → `C-h/j/k/l` via smart-splits.nvim or herdr-splits.
6. **Neovim pane nav** → same keys fall through via smart-splits or herdr-splits (chosen by `HERDR_ENV`; see `.config/nvim/lua/plugins/multiplexer.lua`).

### Leader Key app

`.config/leader_key/config.json` (107 lines) — global launcher (the [Leader Key](https://github.com/mikker/LeaderKey.app) app; hotkey is set inside the app, not this file). Keys: `t` Ghostty, `b` Chrome Canary, `p` PyCharm, `f` Finder, `w` window mgmt group, `l` listen group, `c` communication group, `m` Raycast Keychron.

### sketchybar

`.config/sketchybar/`:
- `sketchybarrc` (91 lines) — entry point. Sources `colors.sh` + `icons.sh`. Bar: height 46, top, `topmost=window`. Loads items in order: `apple.sh`, `spaces.sh`, `front_app.sh`, then right side `calendar.sh`, `volume.sh`, `battery.sh`. Ends with `--hotload off` + `--update`.
- `colors.sh` — Catppuccin palette; **modified in-place by `switch_sketchybar()`**. Uses alpha in `BG0`/`BG1` (`0x80...`).
- `items/*.sh` — one per widget. `items/spaces.sh:3` registers custom event `aerospace_workspace_change`.
- `plugins/*.sh` — receive events. `plugins/aerospace.sh` recolors labels: MAUVE if focused, WHITE if has windows, GREY otherwise.

### borders

`.config/borders/bordersrc` — 10-line bash script invoking JankyBorders with `active_color`, `inactive_color`, `width=1.0`, `hidpi=on`. Modified by `switch_borders()`; restarts daemon via `pkill borders && exec bordersrc`.

### linearmouse

`.config/linearmouse/linearmouse.json` — per-device mouse config. Notable: `Keychron Ultra-Link 8K` scheme with `reverse: true` scroll.

---

## 4. Neovim architecture

### Bootstrap chain

- `init.lua` (48 lines) — defines global `AVAILABLE_COLORSCHEMES` table (nvim ↔ wezterm name map). Loads `config.core` → `config.keymaps` → `config.lazy` → `config.custom`. Reads `~/.config/nvim/colorscheme` state file; fallback `DEFAULT_SCHEME = "catppuccin-mocha"`.
- `lua/config/lazy.lua` — clones `folke/lazy.nvim@stable` to `stdpath("data")/lazy/lazy.nvim` if missing. `spec = { import = "plugins" }`, `install.colorscheme = { "catppuccin" }`, checker enabled hourly without notify.
- `lua/config/core.lua` — vim opts (relativenumber, cursorline, mouse=a, undofile, splitright/below, inccommand=split), custom `scrolloff=10` with near-EOF padding autocmd, commands `YankFileLine` / `QfSort` / `ToggleWrap`, custom `gf` for `file:line`. Python provider disabled unless inside a Pixi env (lines 143–150).
- `lua/config/keymaps.lua` — `mapleader = " "`; window nav `C-h/j/k/l`, `<leader>wv/wh` splits, `[t/]t` bufnav, `<C-u/d>` centered, `U` = redo, `<leader>un` inserts `TODO(rabeez)`, `ToggleScrollWheel` command.
- `lua/config/custom.lua` — floating terminal (`<leader>tt`).

### Plugin files (`lua/plugins/`)

| File | Purpose |
|---|---|
| `ai.lua` | **Supermaven only** (no Copilot). `M-l` accept, `C-]` clear, `M-w` accept word; `<leader>aa` toggle. |
| `color_schemes.lua` | catppuccin/nvim (transparent bg, no italic, follows `vim.o.background`). Others commented out. |
| `completions.lua` | blink.cmp v1 + mini.icons + lspkind + nvim-autopairs. `<CR>` and `<Tab>` explicitly unbound. |
| `debugging.lua` | nvim-dap + mason-nvim-dap + dap-ui + dap-python/go. |
| `editing.lua` | substitute.nvim (`s/ss/S`), nvim-surround, sleuth, undotree, todo-comments, mini.move, quicker.nvim, neogen, ts-comments, matchup, flash.nvim. |
| `filetree.lua` | neo-tree + yazi.nvim (`<leader>ew` opens yazi in cwd; hijacks netrw for directory buffers). |
| `folds.lua` | nvim-ufo, custom statuscolumn with clickable arrows. |
| `git.lua` | gitsigns + git-blame (lazygit.nvim replaced by snacks.lazygit). |
| `greeter.lua` | alpha-nvim dashboard. |
| `lazydev.lua` | lazydev + luvit-meta + wezterm-types. |
| `linting_formatting.lua` | colorizer, render-markdown, conform.nvim (see §4.2), nvim-lint (vale, djlint). |
| `lsp.lua` | Mason + mason-lspconfig + nvim-lspconfig + mason-tool-installer + trouble + fidget (see §4.1). |
| `multiplexer.lua` | **Conditional**: `smart-splits.nvim` if `HERDR_ENV` unset; else `herdr-splits.nvim`. Both bind `C-h/j/k/l`. |
| `navigation.lua` / `notebook.lua` | Entirely commented-out. |
| `sessions.lua` | tpope/vim-obsession. |
| `snacks.lua` | folke/snacks — indent guides, picker (`<leader>f*`), notifier, `<leader>gg` lazygit. |
| `terminal.lua` | toggleterm (`C-\`). |
| `testing.lua` | neotest + neotest-python (`<leader>rt`). |
| `treesitter.lua` | nvim-treesitter (main branch, async install), textobjects, ts-context, ts-autotag, tree-sitter-language-injection.nvim. **`;`/`,` remapped** to repeatable motion (wraps f/F/t/T + gitsigns nav). |
| `typst.lua` | typst-preview (needs tinymist). |
| `visuals.lua` | mini.icons (with `nvim-web-devicons` compat shim), dressing, lualine + harpoon-lualine + lualine-pretty-path, noice, zen-mode. |
| `whichkey.lua` | which-key groups + `<leader>?` shows global. |

### 4.1 LSP / Mason

`lua/plugins/lsp.lua`:
- `ensure_installed` (lines 59–82): `lua_ls`, `rust_analyzer`, `gopls`, `templ`, `htmx`, `html`, `cssls`, `tailwindcss`, `bashls`, `ts_ls`, `jsonls`, `ruff`, `pyrefly`, `yamlls`, `taplo`, `clangd`, `tinymist`, `ols`.
- `mason-tool-installer` (lines 83–95): `stylua`, `shellcheck`, `sleek`, `jsonlint`, `glow`, `prettierd`, `shfmt`, `clang-format`, `mdformat`.
- Per-server config via `vim.lsp.config(name, {...})` at lines 162–238.
- `LspAttach` autocmd (lines 241–363): `<leader>ld/li/lu/lt/K/la/lr/lh`, `<C-e>` diag hover, `<C-s>` signature. Uses `Snacks.picker.lsp_references` for `<leader>lu`.

### 4.2 Autoformat (conform.nvim)

`lua/plugins/linting_formatting.lua`:
- `ToggleAutoFormat` command flips `vim.g.disable_autoformat`.
- `disabled_paths` list (currently empty) + autocmd disables autoformat per path prefix.
- `format_on_save` skips if `vim.g.disable_autoformat` or bufname matches `config/opencode/` (hardcoded).
- Formatters by ft (lines 92-119): `stylua`/`ruff_format`/`rustfmt`/`goimports+gofmt`/`templ`/`prettierd`/`jsonlint`/`odinfmt` (custom)/`sql-formatter`/`beautysh`/`clang-format`/`mdformat`/`taplo`/`djlint`.
- `<leader>lf` — manual format. Templ has BufWritePre autocmd calling global `Templ_format` (shells out to `templ fmt` async).

### 4.3 Colorscheme sync

- `init.lua:34-48` reads `~/.config/nvim/colorscheme` (gitignored, written by `switch_neovim()`).
- Running instances get `:colorscheme <name>` sent via `nvim --server $sock --remote-send` (set-theme.sh finds sockets under `$TMPDIR/nvim*/nvim.*`).
- `AVAILABLE_COLORSCHEMES` in `init.lua` lists many schemes but only **catppuccin** is installed. Other picks silently fall back to nvim builtins.

### Editing pointers

- Add plugin → new file in `lua/plugins/`.
- Add LSP → append to `ensure_installed` in `lsp.lua:59-82`, add `vim.lsp.config(...)` block if custom.
- Add formatter → `formatters_by_ft` in `linting_formatting.lua:92-119`.
- `after/queries/` referenced in `.gitignore:26` is **aspirational/stale** — no such dir exists.
- Snippets: `.config/nvim/snippets/{go,lua,python,package}.json` (LuaSnip format).

---

## 5. Shell — `.zshrc` structure

Order matters. Load sequence (line refs):

1. **Env & PATH** (1-52) — XDG, `/usr/local/bin`, `~/dotfiles/scripts/`, GNU tool overrides (grep/gawk/make/tar/curl/coreutils), rustup/cargo/go/lm-studio/openblas/curl flags.
2. **Brew completion + compinit** (59-70) — cached, `compinit -C`.
3. **herdr completion** (73).
4. **Theme cache + hook** (76-104) — vivid LS_COLORS cache + `_refresh_theme_env` precmd hook.
5. **`~/.local/bin` PATH** (106).
6. **Aliases + functions** (108-196) — see §5.1.
7. **fnm** (199) — `--use-on-cd`.
8. **FZF env** (202-218) — `FZF_COMPLETION_TRIGGER=';;'`, sources theme file, sets CTRL_T/R/ALT_C opts. Actual bindings sourced later at line 344.
9. **Pager** (221-230) — `MANPAGER="nvim +Man!"`, help-flag bat pipe (`-h` and `--help` globally aliased).
10. **Tealdeer** (233).
11. **ASCII banner** (255-289) — theme-colored, skipped in herdr.
12. **zoxide** (292) — `--cmd cd` **replaces cd**.
13. **Zsh plugins** (295-297) — fsh, zsh-autosuggestions (brew), fzf-tab.
14. **Secrets** (300-306) — from `~/dotfiles/Secrets/` via `_load_secret`. Missing files → empty strings, silent.
15. **Env misc** (309-335) — Matplotlib, **built-from-source nvim PATH prepend**, `EDITOR=nvim`, MASON_BIN_PATH, Odin, Pixi, Android SDK, pnpm.
16. **zsh-vi-mode** (337-341) — with `ZVM_INIT_MODE=sourcing`. **Must precede fzf bindings and starship.**
17. **fzf bindings** (344) — `source <(fzf --zsh)`.
18. **starship** (347).
19. **History** (350-353) — 1B entries, extended history.
20. **stty -ixon** (360) — disables XON/XOFF, frees `C-s` for herdr sidebar.

### 5.1 Custom functions

| Name | Location | Purpose |
|---|---|---|
| `tt` | `.zshrc:363` | tmux "main" session launcher |
| `th` | `.zshrc:387` | herdr launcher, ensures "main" workspace |
| `y` | `.zshrc:189` | yazi with cwd sync on quit |
| `clip` | `.zshrc:138` | Copy file references (not contents) to macOS clipboard via AppleScript. Handles multiple files. |
| `mdopen` | `.zshrc:128` | pandoc → HTML → open |
| `_load_secret` | `.zshrc:300` | cat if exists else empty |
| `_refresh_theme_env` | `.zshrc:91` | precmd hook — reload LS_COLORS + fzf on theme change |

### 5.2 Coupling notes

- zsh-vi-mode MUST init before fzf (else keybindings collide) and before starship (recursive `zle-keymap-select`). See comments at lines 342-347.
- `_refresh_theme_env` reads `_current_theme` initialized at line 90; do not move.
- `HERDR_ENV=1` guards the banner (line 287) — herdr uses login shells (`.config/herdr/config.toml:46`), so the banner would otherwise repaint per pane. Contrast tmux: `default-command "${SHELL}"` (non-login), so `.zprofile` doesn't run for tmux panes.

---

## 6. Scripts organization

### `scripts/lib/`

- `log.sh` — `log_debug/info/warn/error` (wrap `gum log`), `log_header` (`gum style --border rounded`).
- `checks.sh` — `require_cmd`, `check_cmd`, `macos_version`, `macos_major`.

### `scripts/external_tools/` — package manifests

- `backup.sh` — dumps to `backups/`:
  - `Brewfile` via `brew bundle dump --force --mas --tap --cask --formula --no-vscode`
  - `Cargofile` via `cargo install --list`
  - `Gofile` via `go version -m ~/go/bin/*` (extracts `path` field)
  - `UVfile` via `uv tool list`
  - `untracked_report.txt` — cross-checks `/Applications`, `/usr/local/bin`, `~/.local/bin` against tracked manifests + `Miscfile`.
- `restore.sh` — reverse; dry-run by default, `-f` to execute. Reminds about Neovim source build at end.
- `backups/Miscfile` — manual-install list not handled by any package manager.

### `scripts/mac_system/` — macOS `defaults`

- `backup.sh` — exports `defaults` per domain to `backups/<domain>.plist`, normalized via `lib/sort_plist.py` for stable diffs. Also snapshots Dock `persistent-apps` to `plists/dock-apps.plist`.
- `restore.sh` — two phases:
  1. `defaults_import_domain` for each `backups/<domain>.plist`.
  2. Source every `modules/[0-9]*.sh` in numeric order (curated deltas on top of import).
  Then `killall Dock Finder SystemUIServer`.
- `DOMAINS` array (13): NSGlobalDomain, dock, finder, trackpads, universalaccess, screencapture, controlcenter, menuextra.clock, HIToolbox, loginwindow, ActivityMonitor, CloudSubscriptionFeatures.
- `modules/`: `01-global.sh` ... `09-keyboard.sh`.

### Top-level `scripts/`

- `set-theme.sh` (§1), `update_yazi_plugins.sh` (§7), `tmux-pick-project.sh` (§2).
- `browser-memory.sh` — browser mem monitoring.
- `opencode_usage.sh` — OpenCode usage analytics.
- `backup_firefox.sh` / `backup_obsidian.sh` / `backup_programming.sh` — misc backups.

---

## 7. yazi

### Layout

`.config/yazi/`:
- `yazi.toml`, `keymap.toml`, `init.lua`, `package.toml`, `theme.toml` (overwritten by set-theme)
- `Catppuccin-{mocha,latte}.tmTheme` — syntax themes referenced from `theme.toml`
- `plugins/` — 21 dirs

### Plugin management

- **Managed** (declared in `package.toml`, installed via `ya pkg upgrade`): rich-preview, piper, jump-to-char, git, no-status, smart-enter, full-border, toggle-pane, types, chmod, diff, zoom, starship, eza-preview, what-size, system-clipboard.
- **Local** (checked in directly, NOT in package.toml): `bat-preview.yazi`, `exif-preview.yazi`, `pdf-preview.yazi`, `toggle-status.yazi`, `zoom-toggle.yazi`.
- `scripts/update_yazi_plugins.sh -f` — wipes only managed plugins + clears `~/.cache/yazi/packages/` + `ya pkg upgrade`. Local plugins preserved.

### `init.lua`

- `full-border` (rounded), `git` (order 1500), `starship`, `toggle-status`, `eza-preview` (level 2, custom ignore glob).
- Custom status right child showing `user:group` (magenta).
- Overrides `Status:name()` to show ` name` and `-> target` for symlinks.

---

## 8. Footguns & non-obvious things

### 8.1 Broken submodules (no `.gitmodules`)

These are tracked as gitlinks with no config to resolve them. `git submodule update --init` does **nothing**:

```
.config/fsh                              # zsh-fast-syntax-highlighting
.config/fzf-tab
.config/tmux/plugins/*                   # populated by TPM on demand
Obsidian/.obsidian/themes/AnuPpuccin
```

Fixes:
- `.config/fsh` and `.config/fzf-tab` — clone manually (see README §5).
- tmux plugins — `prefix+I` or `~/.config/tmux/plugins/tpm/bin/install_plugins`.

### 8.2 Neovim built from source

`.zshrc:311` prepends `~/Documents/Programming/ThirdParty/neovim/build/bin` to PATH. If that dir doesn't exist, brew's `neovim` is used instead (already in Brewfile). To use the source build:

```
git clone https://github.com/neovim/neovim ~/Documents/Programming/ThirdParty/neovim
cd ~/Documents/Programming/ThirdParty/neovim
make CMAKE_BUILD_TYPE=Release && sudo make install
```

### 8.3 Gitignored state files that are critical

| Path | Purpose | Where written |
|---|---|---|
| `~/.local/state/theme-mode` | theme state | `set-theme.sh` |
| `~/.config/nvim/colorscheme` | nvim scheme | `set-theme.sh` |
| `~/.config/wezterm/colorscheme` | wezterm scheme | `set-theme.sh` |
| `scripts/themes/local.sh` | wallpaper paths | manual |
| `Secrets/*` | API keys | manual |

### 8.4 BSD sed everywhere

`switch_*` functions use `sed -i ''`. Will break on Linux. This is a macOS-only repo.

### 8.5 Hard-coded paths

- Wallpapers in `scripts/themes/local.sh`.
- `~/Programming/Probe/<name>` in `prefix+n` handlers (tmux + herdr).
- `PROG="$HOME/Programming"` in `herdr-bootstrap-workspaces.sh:106` (template).
- Mocha `surface1` in `lsp.lua:338` LSP-reference highlight (even in light mode).

### 8.6 Theme toggle side effects

- `set_state` is called **before** switchers run. Mid-run failure = state file lies. No rollback.
- `switch_borders` `pkill && re-exec` — if `borders` was launchd/pm2-managed, that manager may fight it.
- `switch_kitty` matches `MacOS/kitty` by process path — custom kitty builds may not match.

### 8.7 Shell mode differs between multiplexers

- **tmux**: `default-command "${SHELL}"` (non-login). `.zprofile` does NOT run per pane. Put universal env in `.zshrc` / `.zshenv`.
- **herdr**: `shell_mode = "login"`. `.zprofile` runs per pane. Startup ASCII banner guards with `HERDR_ENV` check.

### 8.8 stty -ixon

`.zshrc:360` disables XON/XOFF, so `C-s` doesn't freeze the terminal. Herdr uses `C-s` for sidebar toggle. Don't re-enable flow control in subshells or you'll fight this.

### 8.9 neo-tree hijacks directory buffers only when netrw disabled

`filetree.lua` sets `vim.g.loaded_netrwPlugin = 1` in an `init` hook — required for yazi.nvim's `open_for_directories=true` to work.

### 8.10 Misc

- `AVAILABLE_COLORSCHEMES` in `init.lua` lists many schemes; only catppuccin is installed. Others silently fall back.
- `.gitignore:26` mentions `.config/nvim/after/queries/` — that dir doesn't exist; aspirational.
- Karabiner auto-backups pile up in `.config/karabiner/automatic_backups/`; not gitignored. Watch commit size.

---

## Quick reference — where to edit what

| Concern | File |
|---|---|
| Add tool to theme switcher | `scripts/set-theme.sh` — add `switch_<tool>()`, call from `main()` |
| Change tmux popup | `.config/tmux/tmux.conf:157-215` |
| Change herdr popup | `.config/herdr/config.toml:154-245` |
| Add nvim plugin | new file in `.config/nvim/lua/plugins/` |
| Add LSP server | `.config/nvim/lua/plugins/lsp.lua:59-82` (`ensure_installed`) |
| Add formatter | `.config/nvim/lua/plugins/linting_formatting.lua:92-119` |
| Change theme colors for one tool | edit `scripts/themes/<tool>-{mocha,latte}.<ext>` if it exists, otherwise the hex map in `scripts/set-theme.sh` `switch_<tool>()` |
| Add sesh session | `.config/sesh/sesh.toml` |
| Change window manager rules | `.aerospace.toml` |
| Change status bar | `.config/sketchybar/` |
| Change shell startup | `.zshrc` (respect §5 order) |
| Add package to install | `scripts/external_tools/backups/{Brewfile,Cargofile,Gofile,UVfile,Miscfile}` (or run `backup.sh` after installing) |
| Add macOS default | `scripts/mac_system/modules/*.sh` (curated) or re-run `backup.sh` after changing in System Settings |
