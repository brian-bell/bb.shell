#!/usr/bin/env bash
# Behavioral tests for install-gitconfig.sh.
# Run with: bash tests/test_install_gitconfig.bash
set -u

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(cd "$here/.." && pwd)"
script="$repo/install-gitconfig.sh"

fails=0
ok()   { printf 'ok   - %s\n' "$1"; }
fail() { printf 'FAIL - %s\n' "$1"; fails=$((fails + 1)); }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# --- the committed snapshot carries no identity -------------------------
if grep -Eq '^[[:space:]]*(name|email)[[:space:]]*=' "$repo/.gitconfig"; then
  fail "committed .gitconfig still has user.name/user.email"
else
  ok "committed .gitconfig has no identity"
fi

# --- fresh install with provided identity -------------------------------
home1="$tmp/home1"; mkdir -p "$home1"
printf 'Ada Lovelace\nada@example.com\n' | HOME="$home1" sh "$script" >/dev/null 2>&1
got_name="$(git config --file "$home1/.gitconfig" user.name)"
got_email="$(git config --file "$home1/.gitconfig" user.email)"
[ "$got_name" = "Ada Lovelace" ]  && ok "writes user.name"  || fail "user.name (got: $got_name)"
[ "$got_email" = "ada@example.com" ] && ok "writes user.email" || fail "user.email (got: $got_email)"
[ "$(git config --file "$home1/.gitconfig" alias.s)" = "status" ] \
  && ok "preserves aliases from snapshot" || fail "aliases not preserved"

# --- empty input is rejected --------------------------------------------
home2="$tmp/home2"; mkdir -p "$home2"
if printf '\n\n' | HOME="$home2" sh "$script" >/dev/null 2>&1; then
  fail "empty identity should be rejected"
else
  ok "rejects empty identity"
fi

# --- existing ~/.gitconfig is backed up, with no conflict on reruns ------
home3="$tmp/home3"; mkdir -p "$home3"; printf 'old\n' > "$home3/.gitconfig"
printf 'Grace Hopper\ngrace@example.com\n' | HOME="$home3" sh "$script" >/dev/null 2>&1
printf 'Grace Hopper\ngrace@example.com\n' | HOME="$home3" sh "$script" >/dev/null 2>&1
n_backups="$(ls -d "$home3"/.gitconfig.backup.* 2>/dev/null | wc -l | tr -d ' ')"
if [ "$n_backups" -ge 1 ]; then
  ok "backs up existing ~/.gitconfig"
else
  fail "did not back up existing ~/.gitconfig"
fi
if [ "$n_backups" -eq 2 ]; then
  ok "two runs produce two distinct backups (no conflict)"
else
  fail "expected 2 distinct backups, got $n_backups"
fi

# --- a symlinked ~/.gitconfig is detached, not written through ----------
home4="$tmp/home4"; mkdir -p "$home4"
printf 'pristine target\n' > "$tmp/external-gitconfig"
ln -s "$tmp/external-gitconfig" "$home4/.gitconfig"
printf 'Alan Turing\nalan@example.com\n' | HOME="$home4" sh "$script" >/dev/null 2>&1
if [ -L "$home4/.gitconfig" ]; then
  fail "symlink ~/.gitconfig should be replaced with a regular file"
else
  ok "replaces symlinked ~/.gitconfig with a regular file"
fi
[ "$(cat "$tmp/external-gitconfig")" = "pristine target" ] \
  && ok "leaves symlink target untouched" || fail "symlink target was mutated"
[ "$(git config --file "$home4/.gitconfig" user.email)" = "alan@example.com" ] \
  && ok "writes identity to the new regular file" || fail "identity not written after detach"

# --- a symlink pointing at the repo snapshot does not taint the repo -----
home5="$tmp/home5"; mkdir -p "$home5"
ln -s "$repo/.gitconfig" "$home5/.gitconfig"
printf 'Edsger Dijkstra\nedsger@example.com\n' | HOME="$home5" sh "$script" >/dev/null 2>&1
if grep -Eq '^[[:space:]]*(name|email)[[:space:]]*=' "$repo/.gitconfig"; then
  fail "install wrote identity into the repo's tracked .gitconfig"
else
  ok "self-pointing symlink leaves repo .gitconfig clean"
fi

printf '\n%d failure(s)\n' "$fails"
[ "$fails" -eq 0 ]
