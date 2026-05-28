# AGENTS.md

## Project Notes

- This repo is a minimal zsh configuration, not a general shell framework.
- `bbzsh.zsh` is the entry point and should stay small.
- Keep scripts zsh-specific when useful; they are sourced by zsh, not POSIX sh.
- Prefer small, readable modules over abstractions or plugin-manager behavior.
- Keep machine-specific settings out of git; use `local.zsh`, which is ignored.

## Checks

- Run `zsh -n bbzsh.zsh ls.zsh completions.zsh prompt.zsh` after editing shell files.
