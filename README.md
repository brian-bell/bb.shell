# bb.zsh / bb.bash

A small personal shell setup that replaces the parts of oh-my-zsh this repo
needs: completions and a git-aware prompt. It has no plugin manager, theme
engine, background updater, or generated config.

Two parallel ports ship the same behavior:

- **zsh** — `bb.zsh` (`*.zsh` modules)
- **bash** — `bb.bash` (`*.bash` modules), works on Linux and macOS
  (compatible with bash 3.2+)

## Install

### zsh

Source the entry point from `~/.zshrc`:

```zsh
source "$HOME/dev/bb.shell/bb.zsh"
```

### bash

Source the entry point from `~/.bashrc`:

```bash
source "$HOME/dev/bb.shell/bb.bash"
```

Open a new shell, or reload your current one (`source ~/.zshrc` or
`source ~/.bashrc`).

## What It Does

- Bootstraps the completion system: `compinit` with Homebrew `fpath`
  directories on zsh, the `bash-completion` package on bash.
- Enables menu-style, case-insensitive completion (plus substring matching on
  zsh, which has no native bash equivalent).
- Enables colorized `ls` output on macOS, BSD, and Linux.
- Sets a robbyrussell-style prompt with the current path and git branch.
- Shows a dirty marker in the prompt when the current git worktree has changes.
- Sources `local.zsh` / `local.bash` for machine-specific overrides if present.

## Files

zsh:

- `bb.zsh`: entry point sourced by `.zshrc`.
- `ls.zsh`: colorized `ls` setup and common aliases.
- `completions.zsh`: completion bootstrap and completion styles.
- `prompt.zsh`: prompt setup plus small git helper functions.
- `local.zsh`: optional local-only overrides; ignored by git.
- `.gitconfig`: reference snapshot of the maintainer's personal git config
  (aliases, identity, `gh` credential helper). Not loaded by the shell setup.

bash:

- `bb.bash`: entry point sourced by `.bashrc`.
- `ls.bash`: colorized `ls` setup and common aliases.
- `completions.bash`: `bash-completion` bootstrap and readline tweaks.
- `prompt.bash`: prompt setup plus small git helper functions.
- `local.bash`: optional local-only overrides; ignored by git.

## Customization

Add shared modules as sibling `.zsh` / `.bash` files and source them from the
matching entry point:

```zsh
source "${_bbzsh_dir}/something.zsh"
```

```bash
source "${_bbbash_dir}/something.bash"
```

Put machine-specific or private settings in `local.zsh` / `local.bash`.

## Validation

Check syntax without loading the files, and run the bash prompt tests:

```zsh
zsh -n bb.zsh ls.zsh completions.zsh prompt.zsh
```

```bash
bash -n bb.bash ls.bash completions.bash prompt.bash
bash tests/test_prompt.bash
```
