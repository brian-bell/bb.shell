# Git-aware prompt, robbyrussell-style. Bash port of prompt.zsh.

# Color codes wrapped in \[ \] so bash excludes them from prompt width.
# These stay literal in PS1; bash expands \e, \[ and \] when rendering.
_bbbash_c_green='\[\e[32m\]'
_bbbash_c_red='\[\e[31m\]'
_bbbash_c_cyan='\[\e[36m\]'
_bbbash_c_blue='\[\e[34m\]'
_bbbash_c_yellow='\[\e[33m\]'
_bbbash_c_magenta='\[\e[35m\]'
_bbbash_c_reset='\[\e[0m\]'

_bbbash_git_branch() {
  local ref
  ref=$(command git symbolic-ref --short HEAD 2>/dev/null) \
    || ref=$(command git rev-parse --short HEAD 2>/dev/null) \
    || return 1
  printf '%s' "$ref"
}

_bbbash_git_dirty() {
  local status_line
  status_line=$(command git status --porcelain --ignore-submodules=dirty 2>/dev/null | tail -n1)
  [ -n "$status_line" ]
}

# Echoes a leading-space git segment, or nothing when not in a repo.
_bbbash_git_segment() {
  local branch
  branch=$(_bbbash_git_branch) || return 0
  local segment="${_bbbash_c_yellow}git:${_bbbash_c_blue}(${_bbbash_c_red}${branch}${_bbbash_c_blue})${_bbbash_c_reset}"
  if _bbbash_git_dirty; then
    segment="${segment} ${_bbbash_c_yellow}✗${_bbbash_c_reset}"
  fi
  printf ' %s' "$segment"
}

# PROMPT_COMMAND hook: rebuilds PS1 each prompt. Must read $? first.
_bbbash_set_prompt() {
  local exit=$?
  local arrow="${_bbbash_c_green}➜${_bbbash_c_reset}"
  [ "$exit" -eq 0 ] || arrow="${_bbbash_c_red}➜${_bbbash_c_reset}"
  PS1="${arrow} ${_bbbash_c_cyan}\w${_bbbash_c_reset}$(_bbbash_git_segment) ${_bbbash_c_magenta}\$${_bbbash_c_reset} "
}

# Register the hook without clobbering an existing PROMPT_COMMAND.
case ";${PROMPT_COMMAND:-};" in
  *";_bbbash_set_prompt;"*) ;;
  *) PROMPT_COMMAND="_bbbash_set_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
esac
