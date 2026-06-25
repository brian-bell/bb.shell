# Completion bootstrap. Bash port of completions.zsh.
#
# zsh uses compinit + fpath + zstyle; bash uses the bash-completion package
# plus readline settings. We approximate menu-style, case-insensitive
# completion via readline bindings.

# Load the bash-completion package from the first location that exists.
# Covers Homebrew (Apple Silicon / Intel) and common Linux paths.
for _bb_bc in \
  /opt/homebrew/etc/profile.d/bash_completion.sh \
  /usr/local/etc/profile.d/bash_completion.sh \
  /usr/share/bash-completion/bash_completion \
  /etc/bash_completion; do
  if [ -r "$_bb_bc" ]; then
    # shellcheck disable=SC1090
    . "$_bb_bc"
    break
  fi
done
unset _bb_bc

# Readline tweaks (interactive shells only; `bind` needs a terminal).
case $- in
  *i*)
    # Case-insensitive completion, akin to the zsh matcher-list.
    bind 'set completion-ignore-case on' 2>/dev/null
    # Treat - and _ as interchangeable while matching.
    bind 'set completion-map-case on' 2>/dev/null
    # Show all candidates at once instead of beeping, then cycle through them.
    bind 'set show-all-if-ambiguous on' 2>/dev/null
    bind 'set menu-complete-display-prefix on' 2>/dev/null
    bind 'TAB:menu-complete' 2>/dev/null
    bind '"\e[Z":menu-complete-backward' 2>/dev/null
    # Colorize completion candidates using LS_COLORS, like list-colors.
    bind 'set colored-stats on' 2>/dev/null
    bind 'set colored-completion-prefix on' 2>/dev/null
    ;;
esac
