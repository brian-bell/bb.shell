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
  # The branch name is baked into PS1 as literal text, which bash re-expands on
  # every draw while `promptvars` is on (see below). Strip the only characters
  # that can trigger expansion there -- $, backtick, backslash -- so a hostile
  # branch like `p$(rm -rf ~)` renders as inert text instead of executing.
  ref=${ref//[\$\`\\]/}
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

# Keep `promptvars` on (its default). Shell integrations -- ghostty, iTerm2,
# kitty, atuin, etc. -- register their preexec hook as a $(...) in PS0/PS1 and
# rely on this option to run it; with it off the hook prints literally instead.
#
# The flip side is that promptvars makes bash re-expand $(...), `...`, and
# ${...} in PS1 on every draw. The one piece of attacker-controlled text we bake
# in as literal text is the git branch name, which is why _bb_git_branch strips
# the expansion characters from it. The cwd (\w) is safe: bash quotes the value
# it substitutes for \w before that re-expansion pass, so a directory named
# `$(...)` renders inert (verified by the cwd test in tests/test_prompt.bash).
shopt -s promptvars

# Register the hook without clobbering an existing PROMPT_COMMAND. This assumes
# the scalar form; if a distro uses the bash 5.1+ array form the worst case is a
# duplicate registration, which is harmless.
case ";${PROMPT_COMMAND:-};" in
  *";_bb_set_prompt;"*) ;;
  *) PROMPT_COMMAND="_bb_set_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
esac
