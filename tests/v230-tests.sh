# v2.3.0 tests: eng-run (fake claude/codex on PATH) and Farmer feedback fixes. Sourced by run-tests.sh
# (uses $KIT $T $G $M expect ok bad).
FK="$T/fakebin"; mkdir -p "$FK"; export FAKE_LOG="$T/fake.log"
cat > "$FK/fake-agent" <<'PY'
#!/usr/bin/env python3
# fake claude/codex: logs argv + stdin, prints FAKE_STDOUT, writes FAKE_OUT to the -o file, exits FAKE_RC
import os, re, sys
name = os.environ.pop("FAKE_NAME", "") or re.sub(r"(?i)\.exe$", "", os.path.basename(sys.argv[0])); a = sys.argv[1:]
stdin = "" if sys.stdin is None or sys.stdin.isatty() else sys.stdin.read()
with open(os.environ["FAKE_LOG"], "a") as f:
    f.write("%s ARGV %r\n%s STDIN %d %s\n" % (name, a, name, len(stdin), stdin[:60].replace("\n", " ")))
out = os.environ.get("FAKE_OUT", "1. [medium] src/a.py:3 - weak test - add a case\n")
if "-o" in a and not os.environ.get("FAKE_NO_O"):
    open(a[a.index("-o") + 1], "w").write(out)
if "--out" in a:
    open(a[a.index("--out") + 1], "w").write("generic tool result\n" + open(a[a.index("--in") + 1]).read()[:40])
if os.environ.get("FAKE_TOUCH"):   # v2.5: simulate an agent editing a file
    open(os.environ["FAKE_TOUCH"], "a").write("\n# edited by agent\n")
print(os.environ.get("FAKE_STDOUT", "working... done"))
if "-o" not in a and "--out" not in a and not os.environ.get("FAKE_STDOUT"):
    print(out)
sys.exit(int(os.environ.get("FAKE_RC", "0")))
PY
chmod +x "$FK/fake-agent"; for n in claude codex mytool tool.cmd; do cp "$FK/fake-agent" "$FK/$n"; done
if [ -n "$WIN" ]; then
  # real Windows: CreateProcess cannot run extensionless scripts. Build .exe launchers (same
  # mechanism pip uses for console scripts) and a real .cmd batch shim, like npm's claude.cmd.
  rm -f "$FK/claude" "$FK/codex" "$FK/mytool" "$FK/tool.cmd"
  python3 - "$FK" <<'PY'
import os, shutil, sys
from pip._vendor.distlib.scripts import ScriptMaker
d = sys.argv[1]; m = ScriptMaker(d, os.path.join(d, "build")); m.executable = sys.executable; m.variants = {""}
exe = [f for f in m.make("fake-agent") if f.lower().endswith(".exe")][0]
for n in ("claude", "codex", "mytool"):
    shutil.copy(exe, os.path.join(d, n + ".exe"))
with open(os.path.join(d, "tool.cmd"), "w") as f:
    f.write('@set FAKE_NAME=tool.cmd\r\n@"%s" "%s" %%*\r\n' % (sys.executable, os.path.join(d, "fake-agent")))
PY
fi
export PATH="$(upath "$FK"):$PATH"
RN="$T/run"; cp -r "$M" "$RN"; PL=$(cd "$RN" && ls thoughts/shared/plans/*.md); SID=$(cd "$RN" && sed -n 's/^id: //p' thoughts/shared/slices/*.md | head -1)
er(){ (cd "$RN" && python3 .eng/bin/eng-run "$@"); }

# A. vendoring
expect 0 "eng-init vendors eng-run, prompts, runners.toml" test -x "$G/.eng/bin/eng-run" -a -f "$G/.eng/prompts/plan-review.md" -a -f "$G/.eng/prompts/implement.md" -a -f "$G/.eng/prompts/code-review.md" -a -f "$G/.eng/runners.toml"
expect 0 "prompt templates are versioned and name their skill" bash -c "for r in plan-review implement code-review; do grep -q '^prompt_version: ' '$G/.eng/prompts/'\$r.md && grep -q '^skill: eng-' '$G/.eng/prompts/'\$r.md || exit 1; done"
expect 0 "--upgrade ships eng-run + prompts, keeps edited runners.toml" bash -c "cp -r '$G' '$T/u3' && cd '$T/u3' && rm .eng/bin/eng-run && rm -r .eng/prompts && echo '# mine' >> .eng/runners.toml && eng-init . --upgrade >/dev/null && test -x .eng/bin/eng-run -a -f .eng/prompts/code-review.md && grep -q '^# mine' .eng/runners.toml"
expect 0 "eng-init does not vendor template subdirs as files" bash -c "test ! -e '$G/.eng/templates/prompts' && test -f '$G/.eng/templates/runners.toml'"

# dry run
expect 0 "dry-run plan-review prints exact codex command, writes nothing" bash -c "cd '$RN' && out=\$(python3 .eng/bin/eng-run plan-review $PL --dry-run) && echo \"\$out\" | grep -q '^codex exec --sandbox read-only -o thoughts/shared/runs/.*-plan-review-.*last-message.txt ' && ! ls thoughts/shared/runs/*.md 2>/dev/null | grep -q . && [ ! -s '$FAKE_LOG' ]"
expect 0 "dry-run implement defaults to claude -p (text, acceptEdits)" bash -c "cd '$RN' && python3 .eng/bin/eng-run implement $PL $SID --dry-run | tr '\\n' ' ' | grep -qE \"claude -p ['\\\"]You are the implementer.*['\\\"] --output-format text --permission-mode acceptEdits\""
expect 0 "dry-run code-review --base uses codex review --base" bash -c "cd '$RN' && python3 .eng/bin/eng-run code-review --base develop --dry-run --allow-self-review | grep -qx 'codex review --base develop'"
expect 0 "env ENG_RUNNER_PLAN_REVIEW overrides config" bash -c "cd '$RN' && ENG_RUNNER_PLAN_REVIEW=claude python3 .eng/bin/eng-run plan-review $PL --dry-run | grep -q '^claude -p '"
expect 0 "runners.toml [roles] overrides default" bash -c "cp -r '$RN' '$T/rc' && cd '$T/rc' && sed -i 's/^plan-review = .*/plan-review = \"claude\"/' .eng/runners.toml && python3 .eng/bin/eng-run plan-review $PL --dry-run | grep -q '^claude -p '"
expect 1 "unknown runner is a clean config error" bash -c "cd '$RN' && python3 .eng/bin/eng-run plan-review $PL --runner nosuch --dry-run 2>&1 | grep -q Traceback || python3 .eng/bin/eng-run plan-review $PL --runner nosuch --dry-run"
expect 0 "toml fallback parser equals tomllib" python3 -c "
import sys; sys.path.insert(0,'$KIT/bin'); import englib as L
try: import tomllib
except ImportError: tomllib = None   # Python < 3.11: check the fallback parses known-good values
want = {'roles': {'code-review': 'x'}, 'runners': {'my tool': {'type': 'command', 'command': 't --p {prompt} ' + chr(34) + 'q' + chr(34), 'args': ['a', 'b,c'], 'n': 3, 'ok': False}}}
for t in [open('$KIT/templates/runners.toml').read(), '[roles]\n\"code-review\" = \"x\" # c\n[runners.\"my tool\"]\ntype = \"command\"\ncommand = \"t --p {prompt} \\\\\"q\\\\\"\"\nargs = [\"a\", \\'b,c\\']\nn = 3\nok = false\n']:
    got = L.parse_toml_min(t)
    if tomllib: assert got == tomllib.loads(t), (got, tomllib.loads(t))
    elif t.startswith('[roles]'): assert got == want, got
    else: assert got['roles']['implement'] == 'claude', got"
expect 0 "eng-run works with the fallback TOML parser" bash -c "cd '$RN' && ENG_TOML_FALLBACK=1 python3 .eng/bin/eng-run plan-review $PL --dry-run | grep -q '^codex exec'"

# plan-review integrates with the plan_review gate
PR="$T/pr"; cp -r "$RN" "$PR"; (cd "$PR" && sed -i 's/^plan_review: .*/plan_review:/' $PL)
expect 0 "plan-review (fake codex) writes run log + review file, links plan_review" bash -c "cd '$PR' && FAKE_OUT='1. [high] plan Phase 2 - missing auth test - add one
2. [low] naming - x | y' python3 .eng/bin/eng-run plan-review $PL && R=\$(ls thoughts/shared/runs/*-plan-review-*.md) && V=\$(ls thoughts/shared/verification/\$(date +%F)-*-plan-review.md) && grep -q \"^plan_review: \$V\" $PL && grep -q '^| 1 | high | plan Phase 2 | missing auth test - add one | open |' \$V && grep -q '^## Prompt' \$R && grep -q '^## Output' \$R && grep -q '^## Summary' \$R && grep -q 'codex progress\\|working' \$R"
expect 0 "plan review with open high finding fails eng-check gate" bash -c "cd '$PR' && ! eng-check . >/dev/null && eng-check . | grep -q 'high finding still open'"
expect 0 "dispositioning the finding passes the gate" bash -c "cd '$PR' && V=\$(ls thoughts/shared/verification/\$(date +%F)-*-plan-review.md) && sed -i 's/| missing auth test - add one | open | |/| missing auth test - add one | fixed | slice 1 |/; s/| x \\/ y | open | |/| x \\/ y | rejected | naming is fine, see test_naming |/' \$V && eng-check ."
expect 0 "No findings. review passes gate; existing plan_review kept" bash -c "cp -r '$RN' '$T/nf' && cd '$T/nf' && sed -i 's/^plan_review: .*/plan_review: none/' $PL && FAKE_OUT='No findings.' python3 .eng/bin/eng-run plan-review $PL >/dev/null && eng-check . && FAKE_OUT='No findings.' python3 .eng/bin/eng-run plan-review $PL | grep -q 'already thoughts/shared/verification'"
expect 0 "second run same day gets a new file (no overwrite)" bash -c "cd '$T/nf' && [ \$(ls thoughts/shared/runs/*-plan-review-*.md | wc -l) = 2 ] && [ \$(grep -l '^owner_agent: eng-run' thoughts/shared/verification/*.md | wc -l) = 2 ]"
expect 0 "review written from stdout when codex writes no -o file (never terminal only)" bash -c "cp -r '$RN' '$T/no' && cd '$T/no' && FAKE_NO_O=1 FAKE_STDOUT='1. [low] x - y' python3 .eng/bin/eng-run code-review --base main --allow-self-review >/dev/null && grep -q '^| 1 | low | x | y | open |' thoughts/shared/verification/*-base-main-review.md"
expect 0 "template braces in agent output do not break eng-check" bash -c "cp -r '$RN' '$T/br' && cd '$T/br' && FAKE_STDOUT='use {{ID}} here' python3 .eng/bin/eng-run implement $PL $SID >/dev/null && eng-check ."

# implement + code-review + self-review guard
IM="$T/im"; cp -r "$RN" "$IM"
expect 0 "implement (fake claude) writes run log with runner + slice" bash -c "cd '$IM' && : > '$FAKE_LOG' && python3 .eng/bin/eng-run implement $PL $SID >/dev/null && R=\$(ls thoughts/shared/runs/*-implement-*.md) && grep -q '^runner: claude' \$R && grep -qi \"^slice: $SID\" \$R && grep -q '^status: ok' \$R && grep -q \"claude ARGV \\['-p', 'You are the implementer\" '$FAKE_LOG' && eng-check ."
expect 0 "implement prompt names skill, slice and plan" bash -c "cd '$IM' && grep -q \"eng-implement-slice.*$SID\" thoughts/shared/runs/*-implement-*.md && grep -q 'per plan $PL' thoughts/shared/runs/*-implement-*.md"
expect 0 "self-review refused: code-review by claude after claude implemented (exit 3)" bash -c "cd '$IM' && ENG_RUNNER_CODE_REVIEW=claude python3 .eng/bin/eng-run code-review $SID >/dev/null 2>&1; [ \$? = 3 ]"
expect 0 "--allow-self-review overrides the guard" bash -c "cd '$IM' && ENG_RUNNER_CODE_REVIEW=claude python3 .eng/bin/eng-run code-review $SID --allow-self-review >/dev/null 2>&1"
expect 0 "code-review by codex after claude implement writes verification file" bash -c "cd '$IM' && : > '$FAKE_LOG' && python3 .eng/bin/eng-run code-review $SID >/dev/null && ls thoughts/shared/verification/\$(date +%F)-*-review.md | grep -vq plan-review && grep -q \"codex ARGV \\['review', '--base', 'main'\" '$FAKE_LOG' && eng-check ."
expect 0 "self-review guard falls back to PROJECT_STATE implementer" bash -c "cd '$RN' && python3 .eng/bin/eng-run code-review $SID --runner claude --dry-run >/dev/null 2>&1; [ \$? = 3 ]"
expect 0 "guard sees through command runner wrapping the same tool" bash -c "cp -r '$IM' '$T/wr' && cd '$T/wr' && printf '[runners.cl2]\ntype = \"command\"\ncommand = \"claude -p {prompt}\"\n' >> .eng/runners.toml && python3 .eng/bin/eng-run code-review $SID --runner cl2 --dry-run >/dev/null 2>&1; [ \$? = 3 ]"

# generic command runner, failures, Windows cases
expect 0 "generic command runner is config-only (prompt_file/output_file)" bash -c "cp -r '$IM' '$T/gen' && cd '$T/gen' && printf '[runners.mytool]\ntype = \"command\"\ncommand = \"mytool --in {prompt_file} --out {output_file}\"\n' >> .eng/runners.toml && ENG_RUNNER_CODE_REVIEW=mytool python3 .eng/bin/eng-run code-review $SID >/dev/null && grep -q 'generic tool result' thoughts/shared/runs/*-code-review-*.md && ! ls thoughts/shared/runs/*.txt 2>/dev/null | grep -q ."
expect 0 "runner failure: exit code propagated, run log status failed, no review file" bash -c "cp -r '$RN' '$T/fl' && cd '$T/fl' && FAKE_RC=5 python3 .eng/bin/eng-run code-review --base main --allow-self-review >/dev/null; [ \$? = 5 ] && grep -q '^status: failed' thoughts/shared/runs/*.md && ! ls thoughts/shared/verification/*base-main* 2>/dev/null | grep -q . && eng-check ."
expect 0 "missing executable exits 127 with a hint" bash -c "cd '$RN' && PATH=/usr/bin:/bin python3 .eng/bin/eng-run implement $PL $SID 2>&1 | grep -q 'not found on PATH'; PATH=/usr/bin:/bin python3 .eng/bin/eng-run implement $PL $SID >/dev/null 2>&1; [ \$? = 127 ]"
expect 0 "win: backslash plan path argument accepted" bash -c "cd '$RN' && python3 .eng/bin/eng-run plan-review \$(echo $PL | tr / '\\\\\\\\') --dry-run | grep -q 'Review $PL and'"
expect 0 "win: absolute plan path normalized to repo-relative" bash -c "cd '$RN' && python3 .eng/bin/eng-run plan-review '$RN/'$PL --dry-run | grep -q 'Review $PL and'"
expect 0 "win: .cmd shim gets the prompt on stdin (no cmd.exe quoting)" bash -c "cp -r '$RN' '$T/cm' && cd '$T/cm' && printf '[runners.shim]\ntype = \"command\"\ncommand = \"tool.cmd run\"\n' >> .eng/runners.toml && : > '$FAKE_LOG' && python3 .eng/bin/eng-run implement $PL $SID --runner shim >/dev/null && grep -q \"tool.cmd ARGV \\['run'\\]\" '$FAKE_LOG' && grep -q 'tool.cmd STDIN [1-9][0-9]* You are the implementer' '$FAKE_LOG'"
expect 0 "win: agent names normalize (claude-code, C:\\...\\claude.cmd, codex.exe)" python3 -c "
import sys
src = open('$KIT/bin/eng-run').read()
g = {'__file__': '$KIT/bin/eng-run'}; exec(src[:src.index('ap = argparse.ArgumentParser(prog')], g)
n = g['norm_agent']
assert n('claude-code') == 'claude' and n('Claude Code') == 'claude' and n(r'C:\\Users\\rob\\AppData\\Roaming\\npm\\claude.cmd') == 'claude' and n('codex.exe') == 'codex' and n('codex-cli') == 'codex', [n('claude-code'), n(r'C:\\x\\claude.cmd')]
import subprocess; assert subprocess.list2cmdline(['codex', 'exec', '-o', 'thoughts/shared/runs/a b.txt']) == 'codex exec -o \"thoughts/shared/runs/a b.txt\"'"
expect 0 "eng-status mentions eng-run for the plan review" bash -c "cd '$T/cx' 2>/dev/null || { cp -r '$M' '$T/cx' && cd '$T/cx' && sed -i 's/^status: approved/status: in-review/' thoughts/shared/plans/*.md; }; eng-status . | grep -q 'eng-run plan-review thoughts/shared/plans/'"

# B1. stray approvals: fewer false positives, warn-only for one version
expect 0 "stray check ignores struck-through and history lines" bash -c "cp -r '$G' '$T/st' && cd '$T/st' && sed -i 's/^## Next action/## Next action\n~~CP-R~~ approved 2026-10-22\n- ~~CP-A approved 2026-10-01~~ done/' PROJECT_STATE.md && printf '\n## History\nCP-B approved 2026-09-01 by Rob\n' >> PROJECT_STATE.md && ! eng-check --strict . | grep -q 'outside the Approval log'"
expect 0 "real stray approval is an error from v2.4.0 (was warn-only in 2.3.x)" bash -c "cp -r '$G' '$T/st2' && cd '$T/st2' && sed -i 's/^## Next action/## Next action\nCP-C approved 2026-01-02 by Rob/' PROJECT_STATE.md && ! eng-check . >/dev/null && eng-check . | grep -q '^ERROR .*outside the Approval log'"
expect 1 "real stray approval errors with --strict" bash -c "cd '$T/st2' && eng-check --strict ."
expect 1 "table row outside log errors with --strict" bash -c "cp -r '$G' '$T/st3' && cd '$T/st3' && sed -i 's/^## Next action/## Next action\n| 2026-01-02 | CP-A | docs\/design\/x.md | approved |/' PROJECT_STATE.md && eng-check --strict ."
expect 0 "warn-only expires at the listed version" python3 -c "
import sys; sys.path.insert(0,'$KIT/bin'); import englib as L
L.KIT_VERSION = '2.3.2'; assert L.warn_only('stray-approval') and not L.warn_only('stray-approval', strict=True)
L.KIT_VERSION = '2.4.0'; assert not L.warn_only('stray-approval')"

# B2. stale-section report names the section and shows a diff
expect 0 "stale (top) section shows its first line and a short diff" bash -c "cp -r '$G' '$T/sd' && cd '$T/sd' && sed -i '0,/^# /s/^\(# .*\)/\1\nOLD KIT INTRO/' .eng/templates/AGENTS.md && sed -i '0,/^# /s/^\(# .*\)/\1\nOWNER INTRO/' AGENTS.md && out=\$(eng-init . --upgrade) && echo \"\$out\" | grep -q \"AGENTS.md: section '(top, before the first '## ' heading: \" && echo \"\$out\" | grep -q '^      -OWNER INTRO' && grep -q 'OWNER INTRO' AGENTS.md"
expect 0 "stale named section shows diff lines" bash -c "cd '$T/up2' 2>/dev/null && true; cp -r '$G' '$T/sd2' && cd '$T/sd2' && sed -i 's/^## Commands/## Commands\nOLD KIT CMD/' .eng/templates/AGENTS.md && sed -i 's/^## Commands/## Commands\nOWNER CMD/' AGENTS.md && eng-init . --upgrade | grep -A3 \"section '## Commands'\" | grep -q '^      +\|^      -OWNER CMD'"

# B3. .gitignore dedupe
expect 0 "gitignore block only adds missing lines" bash -c "R='$T/gd' && mkdir \$R && printf '__pycache__/\n*.pyc\nnode_modules/\n' > \$R/.gitignore && eng-init \$R >/dev/null && [ \$(grep -c '^__pycache__/\$' \$R/.gitignore) = 1 ] && [ \$(grep -c '^\*\.pyc\$' \$R/.gitignore) = 1 ] && grep -q '^\.venv/' \$R/.gitignore && cp \$R/.gitignore \$R/g1 && eng-init \$R --upgrade >/dev/null && cmp \$R/.gitignore \$R/g1"
expect 0 "gitignore: no block when every default exists" bash -c "R='$T/gd2' && mkdir \$R && printf '__pycache__\n*.pyc\n*.pyo\n.venv/\nvenv/\n.env\n.DS_Store\nThumbs.db\n' > \$R/.gitignore && eng-init \$R >/dev/null && ! grep -q 'eng-process defaults' \$R/.gitignore"
expect 0 "gitignore: old full block shrinks when user lines duplicate it" bash -c "R='$T/gd3' && mkdir \$R && eng-init \$R >/dev/null && printf '.env\n' >> \$R/.gitignore && eng-init \$R --upgrade >/dev/null && [ \$(grep -c '^\.env\$' \$R/.gitignore) = 1 ]"

# B4. --upgrade lists tracked files matched by ignore rules (does not run git rm)
expect 0 "--upgrade prints git rm --cached for tracked .pyc, does not run it" bash -c "R='$T/tr' && mkdir -p \$R/pkg/__pycache__ && git -C \$R init -q && touch \$R/pkg/__pycache__/m.cpython-311.pyc \$R/a.pyc \$R/keep.py && git -C \$R add -A && git -C \$R commit -qm x && eng-init \$R >/dev/null && out=\$(eng-init \$R --upgrade) && echo \"\$out\" | grep -q '^  git rm -r --cached -- a.pyc pkg/__pycache__/m.cpython-311.pyc\$' && git -C \$R ls-files | grep -q a.pyc"
expect 0 "--upgrade prints nothing about tracked files when clean" bash -c "cd '$T/tr' && git rm -rq --cached a.pyc pkg && git commit -qm y && ! eng-init . --upgrade | grep -q 'git rm'"
