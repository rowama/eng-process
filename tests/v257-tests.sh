# v2.5.7 tests: stay-attached / empty-hooks warnings. Sourced by run-tests.sh after v256.
V257="$T/v257"; rm -rf "$V257"; python3 "$KIT/bin/eng-init" "$V257" >/dev/null
# Minimal plan so eng-run plan-review --dry-run can resolve the path
mkdir -p "$V257/thoughts/shared/plans"
cat > "$V257/thoughts/shared/plans/2026-10-27-demo.md" <<'PLAN'
---
id: PLAN-demo
type: plan
phase: plan
status: draft
triage: medium
plan_review: none
owner_agent: tester
date: 2026-10-27
links: []
---
# Demo plan
PLAN
PL257="thoughts/shared/plans/2026-10-27-demo.md"
expect 0 "eng-check warns when hooks empty" bash -c "python3 '$KIT/bin/eng-check' '$V257' 2>&1 | tee '$T/v257-check.txt' | grep -q 'no on_complete hook configured'"
expect 0 "eng-run dry-run warns with no hook" bash -c "cd '$V257' && python3 .eng/bin/eng-run plan-review $PL257 --dry-run 2>&1 | tee '$T/v257-dry.txt' | grep -q 'WARNING: no on_complete hook'"
(cd "$V257" && awk 'BEGIN{done=0} /^implement_on_complete = ""$/ && !done {print; print "on_complete = \"echo woken\""; done=1; next} {print}' .eng/runners.toml > .eng/runners.toml.tmp && mv .eng/runners.toml.tmp .eng/runners.toml)
expect 0 "eng-run dry-run shows hook when configured" bash -c "cd '$V257' && python3 .eng/bin/eng-run plan-review $PL257 --dry-run 2>&1 | tee '$T/v257-dry2.txt' | grep -q '# on_complete hook (not run): echo woken' && ! grep -q 'Starter must stay attached' '$T/v257-dry2.txt'"
expect 0 "eng-check quiet on hooks when on_complete set" bash -c "! python3 '$KIT/bin/eng-check' '$V257' 2>&1 | grep -q 'no on_complete hook configured'"
expect 0 "LESSONS L-006 present; VERSION 2.5.7" bash -c "grep -q 'L-006' '$KIT/LESSONS.md' && grep -qx '2.5.[789]' '$KIT/VERSION'"
