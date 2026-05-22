# bbzsh

A tiny personal replacement for oh-my-zsh. Two modules: a git-aware prompt and a completion bootstrap.

## Install

Source the entry point from `~/.zshrc`:

```zsh
source "$HOME/dev/shell-tools/bbzsh.zsh"
```

That's it. No plugin manager, no theme engine, no autoupdates.

## Layout

- `bbzsh.zsh` — entry point, sources the other modules.
- `prompt.zsh` — robbyrussell-style prompt with `git:(branch)✗` segment.
- `completions.zsh` — adds Homebrew completion dirs to `fpath`, runs `compinit`, enables menu-select and case-insensitive matching.

## Adding a module

Drop a new `something.zsh` next to the existing files and source it from `bbzsh.zsh`:

```zsh
source "${_bbzsh_dir}/something.zsh"
```

Local-only overrides go in `local.zsh` (gitignored).
