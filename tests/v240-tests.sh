# v2.4.0 tests: learning loop (predictions, evidence, lessons, adoption), new warn-only checks. Sourced by run-tests.sh
TP="$KIT/templates"
# 1. templates / skills / docs content
expect 0 "ADR template has expected outcome, check date, proves-wrong, score" bash -c "grep -q '^- Expected outcome:' '$TP/adr.md' && grep -q '^- Check date:' '$TP/adr.md' && grep -q '^- What would prove it wrong:' '$TP/adr.md' && grep -q '^- Score: unscored' '$TP/adr.md'"
expect 0 "retro template: predictions scored + made, hit-rate, waste, time per phase, lessons, adoption" bash -c "for h in '## Predictions scored' '## Predictions made now' '^- Review hit-rate:' '## Which step felt like waste?' '## Time per phase' '## Kit lessons proposed' '## Design adoption' 'right/wrong/unclear'; do grep -q \"\$h\" '$TP/retro.md' || { echo missing \$h; exit 1; }; done"
expect 0 "review-findings template requires evidence for rejected" grep -q 'reason + EVIDENCE required' "$TP/review-findings.md"
expect 0 "process-feedback template tracks design adoption rules" bash -c "f='$TP/process-feedback.md'; grep -q '^## Design adoption' \$f && grep -q 'informed-owner: yes) is recorded but NOT counted' \$f && grep -q 'Two counted non-safety skips' \$f && grep -q 'safety gate.*escalate to Rob' \$f"
expect 0 "plan template has Demo script; architecture template has owner-legibility question" bash -c "grep -q '^## Demo script' '$TP/plan.md' && grep -q \"Can the owner judge this frontend's behaviour and code? If not, what reduces that gap?\" '$TP/architecture.md'"
expect 0 "kit-lesson template: when/do/because, origin, confirmations, hypothesis, Rob approval" bash -c "f='$TP/kit-lesson.md'; grep -q 'When <situation X>, do <action Y>, because <reason Z>' \$f && grep -q '^- Origin:' \$f && grep -q '^- Confirmations: 1' \$f && grep -q '^- Status: hypothesis' \$f && grep -q '^- Approved by Rob:' \$f && test -f '$KIT/LESSONS.md'"
expect 0 "CI checklist is opt-in, size-dependent, lists lint/typecheck/axe/bundle/Lighthouse" bash -c "f='$TP/ci-checklist.md'; grep -q 'Not enforced by eng-check' \$f && for k in Lint Typecheck axe 'Bundle budget' Lighthouse Small Medium Large; do grep -q \"\$k\" \$f || exit 1; done"
expect 0 "eng-init vendors kit-lesson + ci-checklist templates" test -f "$G/.eng/templates/kit-lesson.md" -a -f "$G/.eng/templates/ci-checklist.md"
expect 0 "eng-retro skill scores predictions, hit-rate, adoption flags, lessons" bash -c "f='$KIT/skills/eng-retro/SKILL.md'; grep -q 'right / wrong / unclear' \$f && grep -q 'Review hit-rate' \$f && grep -q 'redesign flag' \$f && grep -q 'escalate to Rob' \$f && grep -q 'When X, do Y, because Z' \$f && grep -q 'Rob approves every kit lesson' \$f && grep -q 'which step felt like waste' \$f"
expect 0 "architecture skill asks the owner-legibility question; plan skill asks for demo script" bash -c "grep -q \"Can the owner judge this frontend's behaviour and code\" '$KIT/skills/eng-architecture-review/SKILL.md' && grep -q 'Demo script' '$KIT/skills/eng-plan/SKILL.md'"
expect 0 "PROCESS.md documents learning loop + provenance; SOURCES.md has the convention" bash -c "grep -q '^## 12. Learning loop' '$KIT/PROCESS.md' && grep -q 'staleness diff' '$KIT/PROCESS.md' && grep -q '^## Research provenance convention' '$KIT/SOURCES.md' && grep -q 'Snapshot' '$KIT/SOURCES.md'"
expect 0 "eng-new adr / plan / retro from new templates pass eng-check" bash -c "cp -r '$G' '$T/nt' && eng-new adr pred --repo '$T/nt' --agent t >/dev/null && eng-new retro r2 --repo '$T/nt' --agent t >/dev/null && eng-new plan p2 --repo '$T/nt' --agent t >/dev/null && eng-check '$T/nt'"

# 2. rejected finding needs evidence (warn-only until 2.5.0)
RJ="$T/rj"; cp -r "$M" "$RJ"; RV=$(cd "$RJ" && ls thoughts/shared/verification/*-plan-review.md)
expect 0 "rejected finding with a test reference: no evidence warning" bash -c "cd '$RJ' && eng-check . && ! eng-check . | grep -q 'without evidence'"
expect 0 "rejected finding without evidence is an error from 2.5.0" bash -c "cd '$RJ' && sed -i 's#contract first is intended, see tests/test_contract.py#contract first is intended#' $RV && ! eng-check . && eng-check . | grep -q '^ERROR $RV: finding 2 rejected without evidence'"
expect 1 "rejected finding without evidence errors with --strict" bash -c "cd '$RJ' && eng-check --strict ."
expect 0 "file:line evidence accepted" bash -c "cd '$RJ' && sed -i 's#contract first is intended |#contract first is intended (src/api/contract.ts:42) |#' $RV && ! eng-check . | grep -q 'without evidence'"
expect 0 "evidence regex: file:line, pytest node, *_test, .spec, plain prose" python3 -c "
import sys; sys.path.insert(0,'$KIT/bin'); import englib as L
ok = ['src/a.py:12', 'see app.ts:3-9', 'tests/test_x.py::test_y', 'covered by test_login', 'auth_test.go', 'Login.spec.tsx', 'C:\\\\r\\\\x.py:7']
bad = ['intended', 'we disagree', 'see plan', 'not a bug, by design']
assert all(L.EVIDENCE.search(x) for x in ok), [x for x in ok if not L.EVIDENCE.search(x)]
assert not any(L.EVIDENCE.search(x) for x in bad), [x for x in bad if L.EVIDENCE.search(x)]"

# 3. plan/slice drafts before CP-A (warn-only)
expect 0 "plan/slice drafts without approved design error (medium, 2.5.0)" bash -c "cp -r '$G' '$T/dd' && cd '$T/dd' && sed -i 's/^triage: .*/triage: medium/' PROJECT_STATE.md && ! eng-check . && eng-check . | grep -q '^ERROR PROJECT_STATE.md: plan/slice drafts exist but no design doc is approved (CP-A)'"
expect 0 "no drafts-before-design warning once design approved" bash -c "! eng-check '$M' | grep -q 'drafts exist but no design'"
expect 0 "no drafts-before-design warning for triage small" bash -c "cp -r '$T/dd' '$T/dds' && cd '$T/dds' && sed -i 's/^triage: .*/triage: small/' PROJECT_STATE.md && ! eng-check . | grep -q 'drafts exist but no design'"

# 4. design changed after CP-A (warn-only; git dates or sha256 in the decision)
DC="$T/dc"; cp -r "$M" "$DC"; DD=$(cd "$DC" && ls docs/design/*.md)
(cd "$DC" && git add -A && GIT_COMMITTER_DATE=2026-01-01T12:00:00 git commit -qm base && echo "edit" >> "$DD" && git commit -qam "edit design" )
expect 0 "design committed after CP-A approval errors (2.5.0)" bash -c "cd '$DC' && ! eng-check . && eng-check . | grep -q '^ERROR $DD: design doc committed changes after CP-A approval on 2026-01-01'"
expect 0 "commit on the approval day itself does not warn" bash -c "cp -r '$DC' '$T/dc0' && cd '$T/dc0' && git reset -q --hard HEAD~1 && ! eng-check . | grep -q 'after CP-A approval'"
expect 0 "design change during discover is not flagged" bash -c "cp -r '$DC' '$T/dc1' && cd '$T/dc1' && sed -i 's/^phase: implement/phase: discover/' PROJECT_STATE.md && ! eng-check . | grep -q 'after CP-A approval'"
expect 0 "a newer CP-A re-approval row clears the warning" bash -c "cp -r '$DC' '$T/dc2' && cd '$T/dc2' && printf '| %s | CP-A | %s | approved (re-approval) |\n' \$(date +%F) '$DD' >> PROJECT_STATE.md && ! eng-check . | grep -q 'after CP-A approval'"
expect 0 "sha256 in decision: match passes, edit warns" bash -c "cp -r '$DC' '$T/dc3' && cd '$T/dc3' && h=\$(python3 -c \"import sys; sys.path.insert(0,'.eng/bin'); import englib as L; print(L.file_sha('$DD')[:16])\") && printf '| %s | CP-A | %s | approved sha256:%s |\n' \$(date +%F) '$DD' \$h >> PROJECT_STATE.md && ! eng-check . | grep -q 'CP-A approval' && echo more >> '$DD' && eng-check . | grep -q 'content differs from the sha256 recorded at CP-A approval'"
expect 1 "design changed after approval errors with --strict" bash -c "cd '$DC' && eng-check --strict ."
expect 0 "new checks are warn-only until 2.5.0" python3 -c "
import sys; sys.path.insert(0,'$KIT/bin'); import englib as L
L.KIT_VERSION = '2.4.0'
for c in ('rejected-no-evidence', 'draft-before-design', 'design-changed-after-approval'):
    assert L.warn_only(c) and not L.warn_only(c, strict=True), c
L.KIT_VERSION = '2.5.0'; assert not any(L.warn_only(c) for c in ('rejected-no-evidence', 'draft-before-design', 'design-changed-after-approval'))"
