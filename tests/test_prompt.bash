#!/usr/bin/env bash
# Behavioral tests for prompt.bash. Run with: bash tests/test_prompt.bash
set -u

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(cd "$here/.." && pwd)"

# shellcheck source=../prompt.bash
source "$repo/prompt.bash"

fails=0
ok()   { printf 'ok   - %s\n' "$1"; }
fail() { printf 'FAIL - %s\n' "$1"; fails=$((fails + 1)); }

assert_contains() { # haystack needle desc
  case "$1" in
    *"$2"*) ok "$3" ;;
    *)      fail "$3 (missing: $2)" ;;
  esac
}
assert_not_contains() { # haystack needle desc
  case "$1" in
    *"$2"*) fail "$3 (unexpected: $2)" ;;
    *)      ok "$3" ;;
  esac
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# --- non-git directory --------------------------------------------------
mkdir -p "$tmp/plain"
cd "$tmp/plain"
( exit 0 ); _bbbash_set_prompt
assert_not_contains "$PS1" "git:" "non-git dir has no git segment"
assert_contains "$PS1" '\[\e[32m\]➜' "exit 0 renders green arrow"

# --- non-zero exit status -----------------------------------------------
( exit 3 ); _bbbash_set_prompt
assert_contains "$PS1" '\[\e[31m\]➜' "non-zero exit renders red arrow"

# --- clean git repo -----------------------------------------------------
mkdir -p "$tmp/clean"
cd "$tmp/clean"
git init -q
git config user.email t@t.t
git config user.name t
git checkout -q -b main 2>/dev/null || true
( exit 0 ); _bbbash_set_prompt
assert_contains "$PS1" "git:" "git repo shows git segment"
assert_contains "$PS1" "main" "git segment shows branch name"
assert_not_contains "$PS1" $'\xe2\x9c\x97' "clean repo has no dirty marker"

# --- dirty git repo -----------------------------------------------------
echo change > "$tmp/clean/file.txt"
( exit 0 ); _bbbash_set_prompt
assert_contains "$PS1" $'\xe2\x9c\x97' "dirty repo shows dirty marker"

# --- detached HEAD falls back to short sha -------------------------------
git -C "$tmp/clean" add -A
git -C "$tmp/clean" commit -qm first
sha="$(git -C "$tmp/clean" rev-parse --short HEAD)"
git -C "$tmp/clean" checkout -q "$sha" 2>/dev/null
( exit 0 ); _bbbash_set_prompt
assert_contains "$PS1" "$sha" "detached HEAD shows short sha"

echo
if [ "$fails" -eq 0 ]; then
  echo "All prompt tests passed."
else
  echo "$fails test(s) failed."
  exit 1
fi
