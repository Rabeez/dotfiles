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

    # TODO: add fzf-tab here
    autoload -Uz compinit
    compinit
    # https://stackoverflow.com/questions/29196718/zsh-highlight-on-tab
    zstyle ':completion:*' menu select
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/anaconda3/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Aliases
alias sz='source $HOME/.zshrc'
alias ls='eza -l --color=always --icons --header --classify --group-directories-first'
alias la='eza -al --color=always --icons --header --classify --group-directories-first'
alias tree='eza --tree --icons -a'
alias cp='cp -i'                         # confirm before overwriting
alias df='df -h'                         # human readable sizes
alias free='free -m'                     # sizes in MB
alias cloc='tokei --hidden --sort files' # fast CLOC implementation with nice defaults

# Fuzzy finder + conda env activation
# https://waylonwalker.com/quickly-change-conda-env-with-fzf/
ca() {
    # TODO: Add support for executing while in non-base environment
    # conda activate "$(conda info --envs | fzf | awk '{print $1}')"
    env_dir=$(printf "%s/envs" "$CONDA_PREFIX")
    conda activate "$(command ls "$env_dir" | fzf --height 40% --border --reverse)"
}
cdc() {
    if [ "$CONDA_DEFAULT_ENV" != 'base' ]; then
        conda deactivate
    fi
}

# NVM bash completions
export NVM_DIR="$HOME/.nvm"
[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" # This loads nvm
[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"

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
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

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

# Setup ZSH plugins
source "$HOME"/.config/fsh/fast-syntax-highlighting.plugin.zsh
source "$(brew --prefix)"/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# API keys and secrets
export OPENAI_API_KEY=$(cat "$HOME"/dotfiles/Secrets/openai_api_key)
export OPENAI_API_KEY_PRO=$(cat "$HOME"/dotfiles/Secrets/openai_api_key_pro)

# Matplotlib config directory
export MPLCONFIGDIR=$HOME/.matplotlib

# Local Neovim
export PATH="$HOME/Documents/Programming/ThirdParty/neovim/build/bin:$PATH"
export EDITOR=nvim
