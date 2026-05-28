# Git-aware prompt, robbyrussell-style.

setopt PROMPT_SUBST

_bbzsh_git_branch() {
  local ref
  ref=$(command git symbolic-ref --short HEAD 2>/dev/null) \
    || ref=$(command git rev-parse --short HEAD 2>/dev/null) \
    || return
  print -r -- "$ref"
}

_bbzsh_git_dirty() {
  local status_line
  status_line=$(command git status --porcelain --ignore-submodules=dirty 2>/dev/null | tail -n1)
  [[ -n $status_line ]]
}

_bbzsh_prompt_path() {
  local path=$PWD
  if [[ -n $HOME && $path == "$HOME" ]]; then
    path='~'
  elif [[ -n $HOME && $path == "$HOME"/* ]]; then
    path="~/${path#$HOME/}"
  fi
  print -r -- "${path//\%/%%}"
}

_bbzsh_set_git_prompt() {
  local branch
  branch=$(_bbzsh_git_branch) || { _bbzsh_git_prompt=''; return; }
  local segment="%F{yellow}git:%F{blue}(%F{red}${branch}%F{blue})%f"
  if _bbzsh_git_dirty; then
    segment+=" %F{yellow}✗%f"
  fi
  _bbzsh_git_prompt=" $segment"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _bbzsh_set_git_prompt

PROMPT='%(?:%F{green}➜:%F{red}➜)%f %F{cyan}$(_bbzsh_prompt_path)%f${_bbzsh_git_prompt} %F{magenta}$%f '
