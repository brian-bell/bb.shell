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
( exit 0 ); _bb_set_prompt
assert_not_contains "$PS1" "git:" "non-git dir has no git segment"
assert_contains "$PS1" '\[\e[32m\]➜' "exit 0 renders green arrow"

# --- non-zero exit status -----------------------------------------------
( exit 3 ); _bb_set_prompt
assert_contains "$PS1" '\[\e[31m\]➜' "non-zero exit renders red arrow"

# --- clean git repo -----------------------------------------------------
mkdir -p "$tmp/clean"
cd "$tmp/clean"
git init -q
git config user.email t@t.t
git config user.name t
git checkout -q -b main 2>/dev/null || true
( exit 0 ); _bb_set_prompt
assert_contains "$PS1" "git:" "git repo shows git segment"
assert_contains "$PS1" "main" "git segment shows branch name"
assert_not_contains "$PS1" $'\xe2\x9c\x97' "clean repo has no dirty marker"

# --- dirty git repo -----------------------------------------------------
echo change > "$tmp/clean/file.txt"
( exit 0 ); _bb_set_prompt
assert_contains "$PS1" $'\xe2\x9c\x97' "dirty repo shows dirty marker"

# --- detached HEAD falls back to short sha -------------------------------
git -C "$tmp/clean" add -A
git -C "$tmp/clean" commit -qm first
sha="$(git -C "$tmp/clean" rev-parse --short HEAD)"
git -C "$tmp/clean" checkout -q "$sha" 2>/dev/null
( exit 0 ); _bb_set_prompt
assert_contains "$PS1" "$sha" "detached HEAD shows short sha"

# --- prompt escape markers are balanced ---------------------------------
# Every \[ must have a matching \] or bash miscounts prompt width and corrupts
# line wrapping. Count without rendering so this runs on any bash.
cd "$tmp/clean" 2>/dev/null || cd "$tmp"
( exit 0 ); _bb_set_prompt
no_open=${PS1//\\\[/}
no_close=${PS1//\\\]/}
opens=$(( (${#PS1} - ${#no_open}) / 2 ))
closes=$(( (${#PS1} - ${#no_close}) / 2 ))
if [ "$opens" -eq "$closes" ] && [ "$opens" -gt 0 ]; then
  ok "prompt \\[ and \\] markers are balanced ($opens each)"
else
  fail "prompt \\[/\\] markers unbalanced ($opens open, $closes close)"
fi

# --- a malicious branch name cannot execute commands --------------------
# bash re-expands $(...) in PS1 unless promptvars is disabled. Render the
# prompt the way bash draws it and assert the payload never runs.
marker="$tmp/PWNED"
rm -f "$marker"
mkdir -p "$tmp/evil"
cd "$tmp/evil"
git init -q
git config user.email t@t.t
git config user.name t
echo x > seed && git add -A && git commit -qm seed
# Branch name contains a command substitution; ${IFS} avoids a literal space.
evil_branch='p$(touch${IFS}'"$marker"')'
git checkout -q -b "$evil_branch" 2>/dev/null
( exit 0 ); _bb_set_prompt
if [ "${BASH_VERSINFO[0]}" -gt 4 ] || { [ "${BASH_VERSINFO[0]}" -eq 4 ] && [ "${BASH_VERSINFO[1]}" -ge 4 ]; }; then
  # ${PS1@P} expands exactly as the prompt is drawn, side effects included.
  : "${PS1@P}"
  [ -e "$marker" ] && fail "branch name injected a command (PS1@P)" \
                   || ok "malicious branch name does not execute (PS1@P)"
elif command -v script >/dev/null 2>&1 && [ "$(uname)" = "Darwin" ]; then
  printf 'true\nexit\n' | script -q /dev/null /bin/bash \
    --rcfile <(printf 'cd %q\nsource %q\n' "$tmp/evil" "$repo/prompt.bash") -i \
    >/dev/null 2>&1
  [ -e "$marker" ] && fail "branch name injected a command (pty)" \
                   || ok "malicious branch name does not execute (pty)"
else
  printf 'skip - injection render test (bash %s, no @P/pty path)\n' "$BASH_VERSION"
fi
rm -f "$marker"

echo
if [ "$fails" -eq 0 ]; then
  echo "All prompt tests passed."
else
  echo "$fails test(s) failed."
  exit 1
fi
