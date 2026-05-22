# Completion system bootstrap.

# Homebrew-provided completion directories (git, gh, docker, kubectl, mise, ...).
if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi
if [[ -d /opt/homebrew/share/zsh-completions ]]; then
  fpath=(/opt/homebrew/share/zsh-completions $fpath)
fi

autoload -Uz compinit
compinit

# Menu-select navigation and case-insensitive / substring fuzzy matching.
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|=*' \
  'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
