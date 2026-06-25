#!/bin/sh
# Install the repo's .gitconfig snapshot as ~/.gitconfig, prompting for
# identity so user.name / user.email are never committed to this repo.
#
# Run it directly:  sh install-gitconfig.sh
set -eu

here="$(cd "$(dirname "$0")" && pwd)"
src="$here/.gitconfig"
dest="${HOME}/.gitconfig"

[ -r "$src" ] || { echo "error: $src not found" >&2; exit 1; }

# Prompt on stderr so the answer (stdout) can be captured cleanly. Falls back
# to the supplied default when the reply is empty.
ask() { # label default
  _label="$1"; _default="$2"
  if [ -n "$_default" ]; then
    printf '%s [%s]: ' "$_label" "$_default" >&2
  else
    printf '%s: ' "$_label" >&2
  fi
  IFS= read -r _ans || _ans=""
  [ -n "$_ans" ] || _ans="$_default"
  printf '%s' "$_ans"
}

# Pre-fill from any existing global identity.
default_name="$(git config --global user.name 2>/dev/null || true)"
default_email="$(git config --global user.email 2>/dev/null || true)"

name="$(ask 'Git user.name' "$default_name")"
email="$(ask 'Git user.email' "$default_email")"

[ -n "$name" ]  || { echo "error: user.name is required"  >&2; exit 1; }
[ -n "$email" ] || { echo "error: user.email is required" >&2; exit 1; }

# Replace a symlinked ~/.gitconfig with a fresh regular file rather than
# writing through it, which would mutate the link's target (e.g. a dotfiles
# repo, or this repo's own .gitconfig). Back up a real file before overwriting.
if [ -L "$dest" ]; then
  echo "note: $dest is a symlink to $(readlink "$dest"); replacing it with a regular file"
  rm -f "$dest"
elif [ -e "$dest" ]; then
  backup="$(mktemp "${dest}.backup.XXXXXX")"
  cp "$dest" "$backup"
  echo "backed up existing $dest -> $backup"
fi

cp "$src" "$dest"
git config --file "$dest" user.name  "$name"
git config --file "$dest" user.email "$email"

echo "installed $dest"
echo "identity: $name <$email>"
