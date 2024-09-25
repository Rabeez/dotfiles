export EDITOR=code

export PATH="$HOMEBREW_PREFIX/opt/grep/libexec/gnubin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/make/libexec/gnubin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/unzip/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/gzip/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('$HOMEBREW_PREFIX/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOMEBREW_PREFIX/anaconda3/etc/profile.d/conda.sh" ]; then
        . "$HOMEBREW_PREFIX/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOMEBREW_PREFIX/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Aliases
alias sz='source $HOME/.zshrc'
alias ls='eza -l --color=always --icons --header --classify --group-directories-first'
alias la='eza -al --color=always --icons --header --classify --group-directories-first'
alias cp='cp -i'  # confirm before overwriting
alias df='df -h'  # human readable sizes
alias free='free -m'  # sizes in MB
# alias grep='ggrep'  # uses GNU grep (instead of built-in grep) installed via homebrew

# Fuzzy finder + conda env activation
# https://waylonwalker.com/quickly-change-conda-env-with-fzf/
ca () {
    # TODO: Add support for executing while in non-base environment
    # conda activate "$(conda info --envs | fzf | awk '{print $1}')"
    env_dir=`printf "%s/envs" $CONDA_PREFIX`
    conda activate "$(command ls $env_dir | fzf --height 40% --border)"
}
cdc () {
    if [ $CONDA_DEFAULT_ENV != 'base' ]; then
        conda deactivate
    fi
}

# NVM bash completions
export NVM_DIR="$HOME/.nvm"
  [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"


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
  --header 'Press CTRL-Y to copy command into clipboard' --border"
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
pokeget random --hide-name | fastfetch --file-raw -

# Setup starship prompt
eval "$(starship init zsh)"

# Setup ZSH plugins
source $HOME/.config/fsh/fast-syntax-highlighting.plugin.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
