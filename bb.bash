# bb.bash entry point. Sourced from ~/.bashrc.
_bb_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_bb_dir}/ls.bash"
source "${_bb_dir}/completions.bash"
source "${_bb_dir}/prompt.bash"
# Optional machine-specific overrides, kept out of git.
[ -r "${_bb_dir}/local.bash" ] && source "${_bb_dir}/local.bash"
unset _bb_dir
