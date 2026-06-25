# Git-aware prompt, robbyrussell-style. Bash port of prompt.zsh.

# Color codes wrapped in \[ \] so bash excludes them from prompt width.
# These stay literal in PS1; bash expands \e, \[ and \] when rendering.
_bb_c_green='\[\e[32m\]'
_bb_c_red='\[\e[31m\]'
_bb_c_cyan='\[\e[36m\]'
_bb_c_blue='\[\e[34m\]'
_bb_c_yellow='\[\e[33m\]'
_bb_c_magenta='\[\e[35m\]'
_bb_c_reset='\[\e[0m\]'

_bb_git_branch() {
  local ref
  ref=$(command git symbolic-ref --short HEAD 2>/dev/null) \
    || ref=$(command git rev-parse --short HEAD 2>/dev/null) \
    || return 1
  printf '%s' "$ref"
}

_bb_git_dirty() {
  local status_line
  status_line=$(command git status --porcelain --ignore-submodules=dirty 2>/dev/null | tail -n1)
  [ -n "$status_line" ]
}

# Echoes a leading-space git segment, or nothing when not in a repo.
_bb_git_segment() {
  local branch
  branch=$(_bb_git_branch) || return 0
  local segment="${_bb_c_yellow}git:${_bb_c_blue}(${_bb_c_red}${branch}${_bb_c_blue})${_bb_c_reset}"
  if _bb_git_dirty; then
    segment="${segment} ${_bb_c_yellow}✗${_bb_c_reset}"
  fi
  printf ' %s' "$segment"
}

# PROMPT_COMMAND hook: rebuilds PS1 each prompt. Must read $? first.
_bb_set_prompt() {
  local exit=$?
  local arrow="${_bb_c_green}➜${_bb_c_reset}"
  [ "$exit" -eq 0 ] || arrow="${_bb_c_red}➜${_bb_c_reset}"
  PS1="${arrow} ${_bb_c_cyan}\w${_bb_c_reset}$(_bb_git_segment) ${_bb_c_magenta}\$${_bb_c_reset} "
}

# Security: with `promptvars` on (the default), bash re-expands $(...), `...`,
# and ${...} found in PS1 on every render. Since we bake the live git branch
# name into PS1, a branch like `p$(rm -rf ~)` would execute on prompt draw.
# We never rely on promptvars (PS1 holds only literal \-escapes built via real
# command substitution in PROMPT_COMMAND), so disable it. Do not re-enable.
shopt -u promptvars

# Register the hook without clobbering an existing PROMPT_COMMAND. This assumes
# the scalar form; if a distro uses the bash 5.1+ array form the worst case is a
# duplicate registration, which is harmless.
case ";${PROMPT_COMMAND:-};" in
  *";_bb_set_prompt;"*) ;;
  *) PROMPT_COMMAND="_bb_set_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
esac
