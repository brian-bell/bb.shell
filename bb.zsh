# bb.zsh entry point. Sourced from ~/.zshrc.
_bb_dir="${0:A:h}"
source "${_bb_dir}/ls.zsh"
source "${_bb_dir}/completions.zsh"
source "${_bb_dir}/prompt.zsh"
# Optional machine-specific overrides, kept out of git.
[[ -r "${_bb_dir}/local.zsh" ]] && source "${_bb_dir}/local.zsh"
unset _bb_dir
