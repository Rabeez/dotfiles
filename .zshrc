# Performance profiler (paired line at end of file)
# zmodload zsh/zprof

# rather than "~/Library/Application\ Support/"
export XDG_CONFIG_HOME="$HOME/.config"

# Ensure user-installed thirdparty tools are in path
export PATH="/usr/local/bin:$PATH"

# Override builtin binaries with GNU ones installed via homebrew
export PATH="$HOMEBREW_PREFIX/opt/grep/libexec/gnubin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/make/libexec/gnubin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/unzip/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/gzip/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/bc/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/ccache/libexec:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/curl/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
export LIBGCCJIT_LIBRARY_PATH=$(brew --prefix libgccjit)/lib

#Ensure binary packages for languages are in path
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export DYLD_LIBRARY_PATH="$HOMEBREW_PREFIX/lib:$DYLD_LIBRARY_PATH"

# For openblas
export LDFLAGS="-L/opt/homebrew/opt/openblas/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openblas/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/openblas/lib/pkgconfig"

# For curl (from brew instructions)
export LDFLAGS="-L/opt/homebrew/opt/curl/lib $LDFLAGS"
export CPPFLAGS="-I/opt/homebrew/opt/curl/include $CPPFLAGS"
export PKG_CONFIG_PATH="/opt/homebrew/opt/curl/lib/pkgconfig:$PKG_CONFIG_PATH"

# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

    zstyle ':completion:*' rehash true
    zstyle ':completion:*' use-cache on
    zstyle ':completion:*' cache-path ~/.zsh/cache
    autoload -Uz compinit
    compinit -C
    # https://stackoverflow.com/questions/29196718/zsh-highlight-on-tab
    zstyle ':completion:*' menu select
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
function conda() {
    unset -f conda
    if [ -f "/opt/homebrew/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/anaconda3/etc/profile.d/conda.sh"
        conda activate base
    else
        export PATH="/opt/homebrew/anaconda3/bin:$PATH"
    fi
    conda "$@"
}
# <<< conda initialize <<<

# Custom LS/Eza colors
export LS_COLORS="$(vivid generate catppuccin-mocha)"

# Aliases
alias sz='source $HOME/.zshrc'
alias ls='eza -l --color=always --icons --header --classify --group-directories-first'
alias la='eza -al --color=always --icons --header --classify --group-directories-first'
alias tree='eza --tree --icons -a'
alias cp='cp -i'                         # confirm before overwriting
alias df='df -h'                         # human readable sizes
alias free='free -m'                     # sizes in MB
alias cloc='tokei --hidden --sort files' # fast CLOC implementation with nice defaults
alias ee="yazi"
alias gg="lazygit"
alias g="git"
alias p="pixi"
alias codi="codium"


# Use y instead of yazi to start, and press q to quit, you'll see the CWD changed.
# Sometimes, you don't want to change, press Q to quit.
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Fuzzy finder + conda env activation
# https://waylonwalker.com/quickly-change-conda-env-with-fzf/
cdc() {
    if [ "$CONDA_DEFAULT_ENV" != 'base' ]; then
        conda deactivate
    fi
}
ca() {
    # TODO: Add support for executing while in non-base environment
    selection=$(command ls "$CONDA_PREFIX/envs" | fzf --height 40% --border --reverse)
    if [[ -z $selection ]]; then
        return
    fi
    cdc
    conda activate $selection
}

# Faster NVM
eval "$(fnm env --use-on-cd --shell zsh)"

# # Use ;; as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER=';;'
# FZF Catppuccin colors
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi --border"
# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS="
--walker-skip .git,node_modules,target
--preview 'bat -n --color=always {}'
--bind 'ctrl-/:change-preview-window(down|hidden|)' --border"
# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS="
--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
--color header:italic
--header 'Press CTRL-Y to copy command into clipboard' --border --reverse"
# Print tree structure in the preview window
export FZF_ALT_C_OPTS="
--walker-skip .git,node_modules,target
--preview 'tree -C {}' --border"

# bat can be used as a colorizing pager for man
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Startup header
# fastfetch --logo macos
# pokeget random --hide-name | fastfetch --file-raw -

# ART=(
#     ""
#     ".·:'''''''''''''''''''':·."
#     ": :                    : :"
#     ": :  ██████╗ ██████╗   : :"
#     ": :  ██╔══██╗██╔══██╗  : :"
#     ": :  ██████╔╝██████╔╝  : :"
#     ": :  ██╔══██╗██╔══██╗  : :"
#     ": :  ██║  ██║██║  ██║  : :"
#     ": :  ╚═╝  ╚═╝╚═╝  ╚═╝  : :"
#     ": :                    : :"
#     "'·:....................:·'"
# )
# printf "%s\n" "${ART[@]}" | fastfetch --file-raw -

CLR_BORDER="\033[35m"
CLR_CONTENTS="\033[96m"
CLR_RESET="\033[0m"

# ASCII Art with embedded ANSI codes
ART=(
    ""
    "${CLR_BORDER}.·:'''''''''''''''''''':·.${CLR_RESET}"
    "${CLR_BORDER}: :${CLR_RESET}                    ${CLR_BORDER}: :${CLR_RESET}"
    "${CLR_BORDER}: :  ${CLR_CONTENTS}██████╗ ██████╗${CLR_BORDER}   : :${CLR_RESET}"
    "${CLR_BORDER}: :  ${CLR_CONTENTS}██╔══██╗██╔══██╗${CLR_BORDER}  : :${CLR_RESET}"
    "${CLR_BORDER}: :  ${CLR_CONTENTS}██████╔╝██████╔╝${CLR_BORDER}  : :${CLR_RESET}"
    "${CLR_BORDER}: :  ${CLR_CONTENTS}██╔══██╗██╔══██╗${CLR_BORDER}  : :${CLR_RESET}"
    "${CLR_BORDER}: :  ${CLR_CONTENTS}██║  ██║██║  ██║${CLR_BORDER}  : :${CLR_RESET}"
    "${CLR_BORDER}: :  ${CLR_CONTENTS}╚═╝  ╚═╝╚═╝  ╚═╝${CLR_BORDER}  : :${CLR_RESET}"
    "${CLR_BORDER}: :${CLR_RESET}                    ${CLR_BORDER}: :${CLR_RESET}"
    "${CLR_BORDER}'·:....................:·'${CLR_RESET}"
)
oneline=$(
    IFS=$'\n'
    echo "${ART[*]}"
)
echo "$oneline" | fastfetch --file-raw -

# Setup starship prompt
eval "$(starship init zsh)"

# Zoxide completions, cache etc
eval "$(zoxide init zsh)"

# Setup ZSH plugins
source "$HOME"/.config/fsh/fast-syntax-highlighting.plugin.zsh
source "$(brew --prefix)"/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source "$HOME/.config/fzf-tab/fzf-tab.plugin.zsh"

# API keys and secrets
export OPENAI_API_KEY=$(cat "$HOME"/dotfiles/Secrets/openai_api_key)
export OPENAI_API_KEY_PRO=$(cat "$HOME"/dotfiles/Secrets/openai_api_key_pro)

# Matplotlib config directory
export MPLCONFIGDIR=$HOME/.matplotlib

# Local Neovim
export PATH="$HOME/Documents/Programming/ThirdParty/neovim/build/bin:$PATH"
export EDITOR=nvim

# Pixi completions
eval "$(pixi completion --shell zsh)"

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"

# pnpm
export PNPM_HOME="/Users/rabeezriaz/Library/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# ZSH vi mode
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
# NOTE: Need to re-apply keybind customizations, to ensure these are available in Insert mode
# The plugin will auto execute this zvm_after_init function
zvm_after_init() {
    # Set up fzf key bindings and fuzzy completion
    source <(fzf --zsh)
}

# Longer shell history
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=1000000000
export SAVEHIST=1000000000
setopt EXTENDED_HISTORY

# Performance profiler (paired line at start of file)
# zprof

