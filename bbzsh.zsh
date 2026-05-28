# bbzsh entry point. Sourced from ~/.zshrc.
_bbzsh_dir="${0:A:h}"
source "${_bbzsh_dir}/ls.zsh"
source "${_bbzsh_dir}/completions.zsh"
source "${_bbzsh_dir}/prompt.zsh"
unset _bbzsh_dir
