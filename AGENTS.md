# AGENTS.md

## Project Notes

- This repo is a minimal shell configuration, not a general shell framework.
- There are two parallel ports that should stay behaviorally in sync:
  - zsh: `bbzsh.zsh` entry point + `*.zsh` modules.
  - bash: `bbbash.bash` entry point + `*.bash` modules (targets Linux; also
    works on macOS). Kept compatible with bash 3.2+.
- Each entry point should stay small.
- Keep scripts shell-specific when useful; `.zsh` files are sourced by zsh and
  `.bash` files by bash, neither is POSIX sh.
- Prefer small, readable modules over abstractions or plugin-manager behavior.
- Keep machine-specific settings out of git; use `local.zsh` / `local.bash`,
  which are ignored.
- `.gitconfig` is a checked-in reference snapshot of the maintainer's personal
  git config; it is not part of the shell setup and nothing sources it.

## Checks

- zsh: `zsh -n bbzsh.zsh ls.zsh completions.zsh prompt.zsh`
- bash: `bash -n bbbash.bash ls.bash completions.bash prompt.bash`
- bash prompt tests: `bash tests/test_prompt.bash`
