# bbzsh

`bbzsh` is a small personal zsh setup that replaces the parts of
oh-my-zsh this repo needs: completions and a git-aware prompt. It has no
plugin manager, theme engine, background updater, or generated config.

## Install

Source the entry point from `~/.zshrc`:

```zsh
source "$HOME/dev/shell-tools/bbzsh.zsh"
```

Open a new shell, or reload your current one:

```zsh
source ~/.zshrc
```

## What It Does

- Adds Homebrew zsh completion directories to `fpath` when they exist.
- Runs `compinit`.
- Enables menu selection for completions.
- Enables case-insensitive and substring completion matching.
- Enables colorized `ls` output on macOS, BSD, and Linux.
- Sets a robbyrussell-style prompt with the current path and git branch.
- Shows a dirty marker in the prompt when the current git worktree has changes.

## Files

- `bbzsh.zsh`: entry point sourced by `.zshrc`.
- `ls.zsh`: colorized `ls` setup and common aliases.
- `completions.zsh`: completion bootstrap and completion styles.
- `prompt.zsh`: prompt setup plus small git helper functions.
- `local.zsh`: optional local-only overrides; ignored by git.

## Customization

Add shared modules as sibling `.zsh` files and source them from `bbzsh.zsh`:

```zsh
source "${_bbzsh_dir}/something.zsh"
```

Put machine-specific or private settings in `local.zsh`.

## Validation

Check zsh syntax without loading the files:

```zsh
zsh -n bbzsh.zsh ls.zsh completions.zsh prompt.zsh
```
