export BROWSER="$(which zen-browser)"
export EDITOR="$(which nvim)"
export VISUAL="$(which nvim)"
export GTK_THEME=Adwaita:dark

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_RUNTIME_DIR="/run/user/$UID"
export XDG_STATE_HOME="$HOME/.local/state"

export SAVEHIST=10000

# PATH settings
export PATH="$PATH:/home/molyi/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:$HOME/.pesde/bin"

### Scripts Variables ###
export INTERNET_MAX_RETRIES=30
export MONKEYTYPE_API_KEY=""
