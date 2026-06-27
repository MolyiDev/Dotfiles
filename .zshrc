unsetopt PROMPT_SP
setopt PROMPT_CR
export PROMPT_EOL_MARK=""

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# Automatically start tmux if not already inside
if [[ -z "$TMUX" && -n "$PS1" ]]; then
  exec tmux
fi

[[ $- != *i* ]] && return


# Title
function osc7-pwd() {
    emulate -L zsh # also sets localoptions for us
    setopt extendedglob
    local LC_ALL=C
    printf '\e]7;file://%s%s\e\' $HOST ${PWD//(#m)([^@-Za-z&-;_~])/%${(l:2::0:)$(([##16]#MATCH))}}
}

function chpwd-osc7-pwd() {
    (( ZSH_SUBSHELL )) || osc7-pwd
}

add-zsh-hook -Uz chpwd chpwd-osc7-pwd

# ZSH Config
setopt interactivecomments    # Allow comments in interactive mode
setopt complete_aliases       # Allows auto-completion with aliases
setopt magicequalsubst        # Enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch              # Hide error message if there is no match for the pattern
setopt notify                 # Report the status of background jobs immediately
setopt numericglobsort        # Sort filenames numerically when it makes sense
setopt promptsubst            # Enable command substitution in prompt
setopt hist_expire_dups_first # Delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # Ignore duplicated commands history list
setopt hist_ignore_space      # Ignore commands that start with space
setopt hist_verify            # Show command with history expansion to user before running it
setopt nocaseglob
setopt nocasematch

autoload -Uz compinit
compinit

# Case‑insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# Optional: select with arrow‑keys or Tab
zstyle ':completion:*' menu select

# Aliases
alias s='sudo '
alias ls='eza --icons'
alias ll='eza --icons -l'
alias la='eza --icons -A'
alias grep='grep --color=auto'
alias gs='git status'
alias .='cd'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias y='yazi'
alias rsv='rojo serve'
alias rmap='rojo sourcemap --watch --output sourcemap.json'

# vi mode
bindkey -v
bindkey -M vicmd -r ":"
export KEYTIMEOUT=1

source "$HOME/.local/bin/env"

# Codex installer
export PATH="/home/molyi/.local/bin:$PATH"
