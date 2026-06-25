# bb.bash entry point. Sourced from ~/.bashrc.
_bbbash_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_bbbash_dir}/ls.bash"
source "${_bbbash_dir}/completions.bash"
source "${_bbbash_dir}/prompt.bash"
# Optional machine-specific overrides, kept out of git.
[ -r "${_bbbash_dir}/local.bash" ] && source "${_bbbash_dir}/local.bash"
unset _bbbash_dir
