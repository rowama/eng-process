#!/usr/bin/env bash
# Install the package with pipx (falls back to a venv + pip), then `eng init` a temp git repo and `eng check` it.
set -eu
export GIT_AUTHOR_NAME=ci GIT_AUTHOR_EMAIL=ci@example.invalid GIT_COMMITTER_NAME=ci GIT_COMMITTER_EMAIL=ci@example.invalid
SRC="$(cd "$(dirname "$0")/.." && pwd)"
PY=$(command -v python3 || command -v python)
W="$(mktemp -d)"; trap 'rm -rf "$W"' EXIT
if "$PY" -m pip install -q pipx 2>/dev/null; then
  export PIPX_HOME="$W/pipx" PIPX_BIN_DIR="$W/bin"
  "$PY" -m pipx install --python "$PY" "$SRC"
  ENG="$W/bin/eng"
else
  "$PY" -m venv "$W/venv"; "$W/venv/bin/python" -m pip install -q "$SRC"; ENG="$W/venv/bin/eng"
fi
[ -x "$ENG" ] || [ -x "$ENG.exe" ] || { ls -la "$W/bin" 2>/dev/null; echo "eng not installed"; exit 1; }
"$ENG" version
R="$W/repo"; mkdir "$R"; git -C "$R" init -q; git -C "$R" commit -q --allow-empty -m init
cd "$R"
"$ENG" init . --agent ci
"$ENG" check .
"$ENG" upgrade .
"$ENG" check
"$ENG" status >/dev/null
"$ENG" new research smoke --agent ci
"$ENG" check .
# vendored scripts work without the package
python3 .eng/bin/eng-check . 2>/dev/null || python .eng/bin/eng-check .
"$ENG" run plan-review "$(ls thoughts/shared/research/*.md | head -1)" --dry-run --allow-self-review >/dev/null 2>&1 || true
test -f .claude/skills/eng-plan/SKILL.md -a -f .eng/bin/eng-run -a -f .eng/prompts/implement.md -a -f .eng/runners.toml
echo "SMOKE OK"
