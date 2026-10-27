# v2.5.8 tests: measurable-only process items. Sourced by run-tests.sh after v257.
V258="$T/v258"; rm -rf "$V258"; python3 "$KIT/bin/eng-init" "$V258" >/dev/null
expect 0 "VERSION 2.5.8; README pins @v2.5.8" bash -c "grep -qx '2.5.8' '$KIT/VERSION' && grep -q '@v2.5.8' '$KIT/README.md'"
# Version banners: PROCESS/README H1 must carry the VERSION file value.
expect 0 "PROCESS.md and README.md H1 match VERSION" bash -c "v=\$(cat '$KIT/VERSION'); head -1 '$KIT/PROCESS.md' | grep -qF \"kit v\$v)\" && head -1 '$KIT/README.md' | grep -qF \"(v\$v,\""
expect 0 "fresh project: no latest-artifacts / approval-log warn" bash -c "! python3 '$KIT/bin/eng-check' '$V258' 2>&1 | grep -qE 'Latest artifacts has|Approval log is'"
# 13 in-play links => warn; links under ## Prior increments and in comments do not count
cp "$V258/PROJECT_STATE.md" "$T/v258-state.bak"
python3 - "$V258/PROJECT_STATE.md" <<'PY'
import sys; p=sys.argv[1]; s=open(p).read()
extra="".join("- a%d: [AGENTS.md](AGENTS.md)\n" % i for i in range(8))
s=s.replace("- Latest handoff: none\n","- Latest handoff: none\n"+extra+"<!-- [x](AGENTS.md) [y](AGENTS.md) -->\n",1)
s=s.replace("## Prior increments\n","## Prior increments\n"+"".join("- p%d: [AGENTS.md](AGENTS.md)\n" % i for i in range(20)),1)
open(p,"w").write(s)
PY
expect 0 "12 in-play links: no warn (comments + Prior increments excluded)" bash -c "! python3 '$KIT/bin/eng-check' '$V258' 2>&1 | grep -q 'Latest artifacts has'"
sed -i "s|^- Latest handoff: none$|- Latest handoff: none\n- extra: [OWNER-GUIDE.md](OWNER-GUIDE.md)|" "$V258/PROJECT_STATE.md"
expect 0 "13 in-play links: warn" bash -c "python3 '$KIT/bin/eng-check' '$V258' 2>&1 | grep -q 'Latest artifacts has 13 in-play links (> 12)'"
cp "$T/v258-state.bak" "$V258/PROJECT_STATE.md"
# Approval log: 40 rows ok, 41 warn; bytes > 3072 warn
python3 -c "
import sys; p='$V258/PROJECT_STATE.md'; s=open(p).read().rstrip('\n')+'\n'
open(p,'w').write(s+''.join('| d | pre-kit | AGENTS.md | approved (back-filled, pre-kit) |\n' for _ in range(40)))"
expect 0 "approval log 40 rows: no row warn" bash -c "! python3 '$KIT/bin/eng-check' '$V258' 2>&1 | grep -q 'Approval log is'"
echo '| d | pre-kit | AGENTS.md | approved (back-filled, pre-kit) |' >> "$V258/PROJECT_STATE.md"
expect 0 "approval log 41 rows: warn + eng-status shows" bash -c "python3 '$KIT/bin/eng-check' '$V258' 2>&1 | grep -q 'Approval log is 41 rows' && python3 '$KIT/bin/eng-status' '$V258' 2>&1 | grep -q 'approval-log rows=41'"
cp "$T/v258-state.bak" "$V258/PROJECT_STATE.md"
python3 -c "
p='$V258/PROJECT_STATE.md'; s=open(p).read().rstrip('\n')+'\n'
open(p,'w').write(s+'| d | pre-kit | AGENTS.md | approved '+'x'*3200+' |\n')"
expect 0 "approval log > 3072 bytes: warn" bash -c "python3 '$KIT/bin/eng-check' '$V258' 2>&1 | grep -q 'Approval log is 1 rows'"
cp "$T/v258-state.bak" "$V258/PROJECT_STATE.md"
expect 0 "template has ## Prior increments + kit_upgrade note; no archive file shipped" bash -c "grep -q '^## Prior increments' '$KIT/templates/PROJECT_STATE.md' && grep -q 'kit_upgrade: deferred' '$KIT/templates/PROJECT_STATE.md' && ! ls '$KIT/templates' | grep -qi archive"
expect 0 "AGENTS template: plan review gate for medium/large; slice/arch advisory" bash -c "grep -q 'Plan review is a gate for medium/large' '$KIT/templates/AGENTS.md' && grep -q 'slices and architecture is advisory' '$KIT/templates/AGENTS.md'"
expect 0 "eng-resume: stale-kit Action for Rob unless kit_upgrade deferred" bash -c "grep -q 'Action for Rob' '$KIT/skills/eng-resume/SKILL.md' && grep -q 'kit_upgrade: deferred' '$KIT/skills/eng-resume/SKILL.md' && grep -q 'eng upgrade .' '$KIT/skills/eng-resume/SKILL.md'"
# Skills own the happy path. Rule: in eng-plan / eng-implement-slice / eng-verify, any line that mentions a
# PROCESS pointer ("see PROCESS", "PROCESS.md section N", "PROCESS.md N", "PROCESS §N") must still carry >= 80
# characters of other content once the pointer phrases and markdown are stripped. A bare "see PROCESS §10"
# step fails; "edge cases: see PROCESS §10 wake-pair PID classification" inside a full step passes.
expect 0 "eng-plan/implement-slice/verify have no bare PROCESS pointer lines" python3 - "$KIT" <<'PY'
import re, sys
pat = re.compile(r"\(?\s*(?:see|per)?\s*`?(?:\.eng/)?(?:kit:\s*)?`?PROCESS(?:\.md)?`?(?:\s*(?:section|§)\s*[\w.]+|\s+\d+[a-z]?)?\s*\)?", re.I)
bad = []
for sk in ("eng-plan", "eng-implement-slice", "eng-verify"):
    for n, line in enumerate(open("%s/skills/%s/SKILL.md" % (sys.argv[1], sk)), 1):
        if not re.search(r"see PROCESS|PROCESS\.md|PROCESS §", line): continue
        rest = re.sub(r"[`*_#>\-\[\]()|]", "", pat.sub("", line)).strip()
        rest = re.sub(r"^\d+[a-z]?\.\s*", "", rest)
        if len(rest) < 80: bad.append("%s:%d: %s" % (sk, n, line.strip()))
print("\n".join(bad)); sys.exit(1 if bad else 0)
PY
