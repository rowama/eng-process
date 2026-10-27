#!/usr/bin/env bash
# Smoke tests for the eng-process scripts. Usage: tests/run-tests.sh   (uses /tmp, cleans up)
set -u
KIT="$(cd "$(dirname "$0")/.." && pwd)"; export PATH="$KIT/bin:$PATH"
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.invalid GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.invalid
T="$(mktemp -d /tmp/eng-test.XXXX)"; fails=0
# Windows (Git Bash): native Python cannot open /d/... MSYS paths, so use mixed D:/... form for
# KIT/T everywhere; upath() converts back for colon-separated PATH entries.
WIN=; if command -v cygpath >/dev/null 2>&1; then WIN=1; KIT="$(cygpath -m "$KIT")"; T="$(cygpath -m "$T")"; fi
upath(){ if [ -n "$WIN" ]; then cygpath -u "$1"; else printf '%s\n' "$1"; fi; }
PYDIR="$(upath "$(dirname "$(command -v python3)")")"
LOG="$T/log"; : >"$LOG"
ok(){ echo "PASS $1" | tee -a "$LOG"; }; bad(){ echo "FAIL $1"; fails=$((fails+1)); }
expect(){ local want=$1 name=$2; shift 2; "$@" >"$T/out" 2>&1; local got=$?
  if { [ "$want" = 0 ] && [ $got = 0 ]; } || { [ "$want" = 1 ] && [ $got != 0 ]; }; then ok "$name"; else bad "$name (exit $got)"; cat "$T/out"; fi; }

for s in eng-init eng-check eng-status eng-new eng-run; do expect 0 "$s --help" $s --help; done

# 1. fresh repo passes
G="$T/good"; mkdir "$G"; git -C "$G" init -q; git -C "$G" commit -q --allow-empty -m init
expect 0 "eng-init" eng-init "$G" --agent tester
expect 0 "eng-check fresh repo" eng-check "$G"
expect 0 "eng-init idempotent" eng-init "$G"
for t in design architecture vision adr research market-research brief plan slice handoff review verification retro changelog; do
  expect 0 "eng-new $t" eng-new "$t" "demo-$t" --repo "$G" --agent tester; done
expect 0 "eng-check after eng-new" eng-check "$G"
expect 0 "eng-init scaffolds owner guide, feedback log, review notes" test -f "$G/OWNER-GUIDE.md" -a -f "$G/thoughts/shared/process-feedback.md" -a -f "$G/thoughts/shared/review-notes/rob-review-notes.md" -a -d "$G/docs/vision"
expect 1 "changelog entry has no placeholders" grep -nE '<[^>!]+>|^- *$' "$G/CHANGELOG.md"
expect 1 "script output is ASCII (no mojibake)" bash -c "{ eng-init '$G'; eng-check '$G'; eng-status '$G'; } | grep -P '[^\\x00-\\x7F]'"
expect 0 "eng-init Next says eng-triage when triage unset" bash -c "eng-init '$G' | grep -q 'then run eng-triage'"
expect 0 "eng-status" eng-status "$G"
expect 1 "eng-new bad type rejected" eng-new bogus x --repo "$G"

# parser: commas inside quoted list items
expect 0 "parser keeps quoted commas" python3 -c "
import sys; sys.path.insert(0,'$KIT/bin'); import englib as L
assert L.parse_value('[\"a, b\", c]')==['a, b','c'], L.parse_value('[\"a, b\", c]')
assert L.parse_value(\"['x,y', 'z'] # c\")==['x,y','z']
assert L.parse_value('\"q # not comment\"')=='q # not comment'
assert L.parse_value('[]')==[] and L.parse_value('plain # c')=='plain'"

# 1b. a consistent medium project at implement: passes and prints the ready-to-implement message
M="$T/med"; cp -r "$G" "$M"; (cd "$M"
  D=$(ls docs/design/*.md); R=$(ls thoughts/shared/research/*.md); P=$(ls thoughts/shared/plans/*.md); S=$(ls thoughts/shared/slices/*.md)
  sed -i "s/^status: draft.*/status: approved/" "$D" "$R" "$P"
  sed -i "s#^plan: .*#plan: $P#" "$S"
  sed -i "s/^phase: discover/phase: implement/; s/^triage: .*/triage: medium/; s#^active_slice: none#active_slice: $S#" PROJECT_STATE.md
  printf '| 2026-01-01 | CP-A | %s | approved |\n| 2026-01-02 | CP-C | %s | approved |\n' "$D" "$P" >> PROJECT_STATE.md
  sed -i "s/^status: draft.*/status: approved/" "$R"; printf '| 2026-01-02 | CP-R | %s | approved |\n' "$R" >> PROJECT_STATE.md
  eng-new plan-review demo --agent test >/dev/null; V=$(ls thoughts/shared/verification/*-plan-review.md)
  printf '| 1 | high | plan 2 | missing auth test | fixed | added to slice 1 |\n| 2 | medium | plan 3 | order | rejected | contract first is intended, see tests/test_contract.py |\n| 3 | low | plan | naming | accepted-risk | Rob 2026-01-02 |\n' > /tmp/rows
  sed -i "/^|---|---|---|---|---|---|/r /tmp/rows" "$V"; sed -i "s#^plan_review: .*#plan_review: $V#" "$P")
expect 0 "eng-check consistent medium project at implement" eng-check "$M"
expect 0 "eng-status prints ready-to-implement message" bash -c "eng-status '$M' | grep -q 'eng-run implement .* SLICE-' && eng-status '$M' | grep -q 'Fallback (interactive Claude)' && eng-status '$M' | grep -q 'Run eng-resume, then eng-implement-slice for SLICE-'"
expect 0 "eng-init Next respects known triage" bash -c "eng-init '$M' | grep -q \"triage is already 'medium'\""
expect 0 "later checkpoint may be pending early" bash -c "cp -r '$G' '$T/early' && cd '$T/early' && sed -i \"s#^pending_approvals: \\[\\]#pending_approvals: [\\\"CP-B: \$(ls docs/design/*.md) - auth, hosting\\\"]#\" PROJECT_STATE.md && eng-check ."
expect 0 "ADR deferred status valid" bash -c "cp -r '$G' '$T/def' && cd '$T/def' && sed -i 's/^status: proposed.*/status: deferred/' docs/decisions/0001-*.md && eng-check ."
expect 0 "readiness reports earliest incomplete phase" bash -c "cp -r '$G' '$T/rd' && cd '$T/rd' && sed -i 's/^phase: discover/phase: implement/; s/^triage: .*/triage: large/' PROJECT_STATE.md && eng-status . | grep -q 'earliest incomplete phase: discover'"
expect 0 "eng-init --brownfield flags legacy ADRs" bash -c "B='$T/bf'; mkdir -p \$B/docs/adr && echo x > \$B/docs/adr/001-old.md && eng-init \$B --brownfield | grep -q 'docs/adr/001-old.md  -> docs/decisions'"

expect 0 "eng-status prints codex plan-review command" bash -c "cp -r '$M' '$T/cx' && cd '$T/cx' && sed -i 's/^status: approved/status: in-review/' thoughts/shared/plans/*.md && eng-status . | grep -q 'codex exec .* -o thoughts/shared/verification/.*plan-review.md$'"
expect 0 "small triage exempt from plan review" bash -c "cp -r '$M' '$T/sm' && cd '$T/sm' && sed -i 's/^plan_review: .*/plan_review: none/' thoughts/shared/plans/*.md && sed -i 's/^triage: .*/triage: small/' PROJECT_STATE.md && ! eng-check . | grep -q 'mandatory plan review'"
expect 0 "brownfield suggests destination per doc" bash -c "B='$T/bf2'; mkdir -p \$B/notes && echo x > \$B/notes/payments-spec.md && eng-init \$B --brownfield | grep -q 'notes/payments-spec.md  -> docs/design'"
expect 0 "doc without id is a clean error" bash -c "cp -r '$G' '$T/noid' && cd '$T/noid' && sed -i '/^id:/d' thoughts/shared/plans/*.md thoughts/shared/research/*.md; eng-check . 2>&1 | grep -q 'missing' && ! eng-check . 2>&1 | grep -q Traceback"

# 1c. the kit travels with the repo
expect 0 "eng-init vendors skills + scripts" test -f "$G/.claude/skills/eng-plan/SKILL.md" -a -x "$G/.eng/bin/eng-check" -a -f "$G/.eng/bin/englib.py" -a -f "$G/.eng/VERSION"
expect 0 "vendored skill keeps name/description frontmatter" bash -c "head -3 '$G/.claude/skills/eng-plan/SKILL.md' | grep -q '^name: eng-plan' && head -3 '$G/.claude/skills/eng-plan/SKILL.md' | grep -q '^description: '"
expect 1 "vendored skills/docs have no kit-source paths" grep -rlE "/workspace|eng-process/bin" "$G/.claude/skills" "$G/.eng/PROCESS.md" "$G/AGENTS.md"
expect 0 "vendored scripts run with no kit access" bash -c "cp -r '$KIT' '$T/kitsrc' && R='$T/vend' && mkdir \$R && git -C \$R init -q && '$T/kitsrc/bin/eng-init' \$R --agent t >/dev/null && mv '$T/kitsrc' '$T/kitsrc-gone' && cp -r \$R /tmp/eng-vend-\$\$ && cd /tmp/eng-vend-\$\$ && env -i PATH=/usr/bin:/bin:$PYDIR HOME=/tmp bash -c 'python3 .eng/bin/eng-check . && .eng/bin/eng-status . >/dev/null && python3 .eng/bin/eng-new plan demo --agent t >/dev/null && python3 .eng/bin/eng-check .'; rc=\$?; rm -rf /tmp/eng-vend-\$\$; exit \$rc"
expect 0 "old vendored version warns" bash -c "cp -r '$G' '$T/old' && echo 1.0.0 > '$T/old/.eng/VERSION' && eng-check '$T/old' | grep -q 'older than kit'"
expect 0 "eng-init --upgrade refreshes kit files only" bash -c "cd '$T/old' && h=\$(md5sum PROJECT_STATE.md AGENTS.md) && echo junk > .eng/bin/eng-check && rm -r .claude/skills/eng-plan && eng-init . --upgrade >/dev/null && [ \"\$(md5sum PROJECT_STATE.md AGENTS.md)\" = \"\$h\" ] && grep -q '$(cat VERSION)' .eng/VERSION && test -f .claude/skills/eng-plan/SKILL.md && ! eng-check . | grep -q 'older than kit'"

# 1d. v2.2.1: Windows paths (SIMULATED on Linux), grandfathering, upgrade hygiene
expect 0 "win-sim: ntpath relpath + backslash sep still passes" python3 -c "
import os, ntpath, runpy, sys
os.path.relpath = ntpath.relpath; os.sep = '\\\\'
sys.argv = ['eng-check', '$M']
try: runpy.run_path('$KIT/bin/eng-check', run_name='__main__')
except SystemExit as e: sys.exit(e.code)"
expect 0 "win-sim: posix() normalizes backslash paths" python3 -c "
import sys; sys.path.insert(0,'$KIT/bin'); import englib as L, ntpath, os
assert L.posix('docs\\\\design\\\\a.md')=='docs/design/a.md' and L.posix('.\\\\x\\\\y.md')=='x/y.md'
os.path.relpath = ntpath.relpath
assert L.rel('/r/thoughts/shared/plans/p.md','/r')=='thoughts/shared/plans/p.md', L.rel('/r/thoughts/shared/plans/p.md','/r')
assert all('\\\\' not in k for k in L.load_artifacts('$M'))"
expect 0 "win-sim: backslash paths in log, links and front matter pass" bash -c "cp -r '$M' '$T/bs' && cd '$T/bs' && sed -i '/^| 20/s#/#\\\\#g' PROJECT_STATE.md && sed -i '/^active_slice:/s#/#\\\\#g' PROJECT_STATE.md && sed -i '/^plan:/s#/#\\\\#g' thoughts/shared/slices/*.md && sed -i '/^plan_review:/s#/#\\\\#g' thoughts/shared/plans/*.md && grep -q 'docs.design.20' PROJECT_STATE.md && eng-check ."
expect 0 "scripts run as 'python <script>' (no shebang reliance)" bash -c "cd '$M' && python3 .eng/bin/eng-check . >/dev/null && python3 .eng/bin/eng-status . >/dev/null"
expect 0 "grandfather: Rob waiver row replaces plan review" bash -c "cp -r '$M' '$T/gf' && cd '$T/gf' && P=\$(ls thoughts/shared/plans/*.md) && sed -i 's/^plan_review: .*/plan_review: none/' \$P && eng-check . | grep -q 'Grandfather' ; printf '| 2026-01-03 | CP-C | %s | waiver: plan review - approved by Rob |\n' \$P >> PROJECT_STATE.md && eng-check ."
expect 0 "eng-status latest handoff by date, not filename" bash -c "cp -r '$G' '$T/ho' && cd '$T/ho' && H=thoughts/shared/handoffs && f=\$(ls \$H/*.md | head -1) && sed 's/^date: .*/date: 2020-01-01/' \$f > \$H/zzzz-old.md && sed 's/^date: .*/date: 2030-01-01/' \$f > \$H/aaaa-new.md && eng-status . | grep -E '^  handoff ' | grep -q aaaa-new.md"
expect 1 "eng-status codex command has no absolute cd" bash -c "cd '$T/cx' && eng-status . | grep -E '^cd /|codex exec.*/tmp/'"
expect 0 "eng-status codex command says from the repo root" bash -c "cd '$T/cx' && eng-status . | grep -q '^# from the repo root:'"
expect 0 "gitignore block added once, existing lines kept" bash -c "R='$T/gi' && mkdir \$R && printf 'node_modules/\n' > \$R/.gitignore && eng-init \$R >/dev/null && eng-init \$R --upgrade >/dev/null && grep -q '^node_modules/' \$R/.gitignore && [ \$(grep -c '>>> eng-process defaults' \$R/.gitignore) = 1 ] && grep -q '^__pycache__/' \$R/.gitignore"
expect 0 "no __pycache__/.pyc vendored" bash -c "cp -r '$KIT' '$T/kp' && mkdir -p '$T/kp/bin/__pycache__' && touch '$T/kp/bin/__pycache__/x.pyc' '$T/kp/bin/y.pyc' && R='$T/np' && mkdir \$R && '$T/kp/bin/eng-init' \$R >/dev/null && ! find \$R/.eng \$R/.claude -name '*.pyc' -o -name __pycache__ | grep -q ."
expect 0 "--upgrade adds empty plan_review: to plans lacking it" bash -c "cp -r '$G' '$T/up1' && cd '$T/up1' && sed -i '/^plan_review:/d' thoughts/shared/plans/*.md && eng-init . --upgrade | grep -q 'add     plan_review:' && grep -q '^plan_review:\$' thoughts/shared/plans/*.md"
expect 0 "--upgrade refreshes unchanged boilerplate, lists owner-edited sections" bash -c "cp -r '$G' '$T/up2' && cd '$T/up2' && sed -i 's/^## Working agreements/## Working agreements\nOLD KIT LINE/' .eng/templates/AGENTS.md AGENTS.md && sed -i 's/^## Commands/## Commands\nOLD KIT CMD/' .eng/templates/AGENTS.md && sed -i 's/^## Commands/## Commands\nOWNER CMD/' AGENTS.md && cp AGENTS.md /tmp/ag.\$\$ && out=\$(eng-init . --upgrade) && ! grep -q 'OLD KIT LINE' AGENTS.md && grep -q 'OWNER CMD' AGENTS.md && echo \"\$out\" | grep -q \"AGENTS.md: section '## Commands'\"; rc=\$?; rm -f /tmp/ag.\$\$; exit \$rc"

# 2. each breakage must fail
brk(){ local name=$1 cmd=$2; local B="$T/b-$name"; cp -r "$G" "$B"; (cd "$B" && eval "$cmd"); expect 1 "eng-check fails: $name" eng-check "$B"; grep -m1 ERROR "$T/out" | sed 's/^/      /'; }
brkm(){ local name=$1 cmd=$2; local B="$T/m-$name"; cp -r "$M" "$B"; (cd "$B" && eval "$cmd"); expect 1 "eng-check fails: $name" eng-check "$B"; grep -m1 ERROR "$T/out" | sed 's/^/      /'; }
brkm plan-review-missing  'sed -i "s/^plan_review: .*/plan_review: none/" thoughts/shared/plans/*.md'
brkm plan-review-high-open 'sed -i "s/| fixed | added to slice 1 |/| open | |/" thoughts/shared/verification/*-plan-review.md'
brkm plan-review-critical-open 'sed -i "s/| high | plan 2 | missing auth test | fixed |/| critical | plan 2 | missing auth test | open |/" thoughts/shared/verification/*-plan-review.md'
brkm accepted-risk-no-rob 'sed -i "s/| Rob 2026-01-02 |/| seems fine |/" thoughts/shared/verification/*-plan-review.md'
brkm rejected-no-reason   'sed -i "s/| contract first is intended, see tests\/test_contract.py |/| |/" thoughts/shared/verification/*-plan-review.md'
brkm slice-in-progress-no-review 'sed -i "s/^plan_review: .*/plan_review: none/" thoughts/shared/plans/*.md; sed -i "s/^phase: implement/phase: plan/" PROJECT_STATE.md; sed -i "s/^status: todo.*/status: in-progress/" thoughts/shared/slices/*.md'
brk pseudo-approval    'sed -i "s/^status: draft.*/status: approved-for-review/" thoughts/shared/research/*.md'
brk no-vendored-bin   'rm -r .eng/bin'
brk no-vendored-skills 'rm -r .claude/skills'
brk missing-state      'rm PROJECT_STATE.md'
brk missing-field      'sed -i "/^owner_agent:/d" thoughts/shared/plans/*.md'
brk bad-status         'sed -i "s/^status: draft.*/status: finished/" thoughts/shared/research/*.md'
brk broken-link        'echo "- [x](thoughts/shared/plans/nope.md)" >> PROJECT_STATE.md'
brk plan-section       'sed -i "s/^## What We.re NOT Doing/## Notes/" thoughts/shared/plans/*.md'
brk pending-approval   'sed -i "s/^phase: discover/phase: implement/; s/^triage: .*/triage: medium/; s|^pending_approvals: \[\]|pending_approvals: [\"CP-C: $(ls thoughts/shared/plans/*.md) - approve\"]|" PROJECT_STATE.md; sed -i "s/^status: draft.*/status: approved/" thoughts/shared/plans/*.md; printf "| d | CP-C | %s | approved |\n" thoughts/shared/plans/*.md >> PROJECT_STATE.md'
brk unapproved-plan    'sed -i "s/^phase: discover/phase: implement/" PROJECT_STATE.md'
brk wip-limit          'f=$(ls thoughts/shared/slices/*.md); cp $f ${f%.md}-2.md; sed -i "s/^id: .*/id: SLICE-2/" ${f%.md}-2.md; sed -i "s/^status: todo.*/status: in-progress/" thoughts/shared/slices/*.md'
brk unfilled-token     'echo "{{ID}}" >> docs/design/*.md'

brk unset-triage-research 'sed -i "s/^phase: discover/phase: research/" PROJECT_STATE.md'
brk research-gate      'sed -i "s/^phase: discover/phase: research/; s/^triage: .*/triage: medium/" PROJECT_STATE.md'
brk plan-gate-large    'sed -i "s/^phase: discover/phase: plan/; s/^triage: .*/triage: large/" PROJECT_STATE.md; sed -i "s/^status: draft.*/status: approved/" docs/design/*.md; printf "| d | CP-A | %s | approved |\n" docs/design/*.md >> PROJECT_STATE.md'
brk earlier-cp-pending 'sed -i "s/^phase: discover/phase: research/; s/^triage: .*/triage: medium/" PROJECT_STATE.md; sed -i "s#^pending_approvals: \[\]#pending_approvals: [\"CP-A: $(ls docs/design/*.md) - approve\"]#" PROJECT_STATE.md; sed -i "s/^status: draft.*/status: approved/" docs/design/*.md; printf "| d | CP-A | %s | approved |\n" docs/design/*.md >> PROJECT_STATE.md'
brk pending-path       'sed -i "s#^pending_approvals: \[\]#pending_approvals: [\"CP-B: docs/design/nope.md - auth\"]#" PROJECT_STATE.md'
brk pending-body-drift 'sed -i "s#^pending_approvals: \[\]#pending_approvals: [\"CP-B: $(ls docs/design/*.md) - auth\"]#" PROJECT_STATE.md; sed -i "/^## Pending approvals/a - CP-B: docs/design/other.md - hosting" PROJECT_STATE.md'
brk adr-id-mismatch    'sed -i "s/^id: ADR-0001/id: ADR-001/" docs/decisions/0001-*.md'
brk adr-filename       'git mv -f docs/decisions/0001-demo-adr.md docs/decisions/001-demo-adr.md 2>/dev/null || mv docs/decisions/0001-demo-adr.md docs/decisions/001-demo-adr.md'
brk adr-partial-noparts 'sed -i "s/^status: proposed.*/status: partially-accepted/; s/^## Parts/## Notes/" docs/decisions/0001-*.md; printf "| d | CP-B | %s | partially accepted |\n" docs/decisions/0001-*.md >> PROJECT_STATE.md'
brk log-vs-status      'printf "| d | CP-A | %s | approved |\n" docs/design/*.md >> PROJECT_STATE.md'
brk approved-unlogged  'sed -i "s/^status: draft.*/status: approved/" docs/design/*.md'
brk changelog-placeholder 'printf "### Added\n- <summary>\n- \n" >> CHANGELOG.md'
brk bad-pending-format 'sed -i "s#^pending_approvals: \[\]#pending_approvals: [approve the plan please]#" PROJECT_STATE.md'
brk input-not-approved 'sed -i "s/^phase: discover/phase: implement/; s/^triage: .*/triage: medium/" PROJECT_STATE.md; sed -i "s/^status: draft.*/status: input/" thoughts/shared/plans/*.md docs/design/*.md'

. "$KIT/tests/v230-tests.sh"
. "$KIT/tests/v240-tests.sh"
. "$KIT/tests/v250-tests.sh"
. "$KIT/tests/v253-tests.sh"
. "$KIT/tests/v254-tests.sh"
. "$KIT/tests/v255-tests.sh"
. "$KIT/tests/v256-tests.sh"
. "$KIT/tests/v257-tests.sh"

n=$(grep -c "^PASS" "$LOG"); rm -rf "$T"; echo; [ $fails = 0 ] && echo "ALL TESTS PASSED ($n checks)" || { echo "$fails TEST(S) FAILED"; exit 1; }
