# 2026-10-28 retro fixes (Unreleased). Sourced by run-tests.sh after v258; reuses $RN/$PL/$SID/$FAKE_* from v230.
expect 0 "codex [P1]/[P2] findings are parsed (not 'No findings.')" bash -c "cp -r '$RN' '$T/pri' && cd '$T/pri' && FAKE_NO_O=1 FAKE_STDOUT='Review comments:
- [P1] Stale id approves old wakes - src/wake.py:12-20
- [P2] Missing retry cap — src/retry.py:5
- [P3] plan wording - tighten Phase 2
4. [low] typo - README.md:1
No findings beyond these.' python3 .eng/bin/eng-run code-review --base main --allow-self-review >/dev/null && V=\$(ls thoughts/shared/verification/*-base-main-review.md) && grep -q '^| 1 | high | src/wake.py:12-20 | \\[P1\\] Stale id approves old wakes | open |' \$V && grep -q '^| 2 | medium | src/retry.py:5 | \\[P2\\] Missing retry cap | open |' \$V && grep -q '^| 3 | low | plan wording | \\[P3\\] tighten Phase 2 | open |' \$V && grep -q '^| 4 | low | typo | README.md:1 | open |' \$V && ! grep -qx 'No findings.' \$V"
expect 0 "missing runner: exit 127 and error mentions nvm PATH; runners.toml documents it" bash -c "cd '$RN' && out=\$(PATH=/usr/bin:/bin python3 .eng/bin/eng-run plan-review $PL --runner codex 2>&1); rc=\$?; [ \$rc = 127 ] && echo \"\$out\" | grep -q 'nvm' && grep -q 'NVM_DIR' '$KIT/templates/runners.toml'"
expect 0 "design_req_ids: letter ids, definitions only, natural sort" python3 -c "
import sys; sys.path.insert(0,'$KIT/bin'); import englib as L
b='## Requirements (acceptance criteria)\n- [ ] REQ-A1: x (amended)\n- [ ] REQ-A10: y\n- [ ] REQ-A5b: z, amends v1 REQ-7\n- [ ] REQ-A2: w\n\n## Amendments\n- REQ-A1 changed\n'
assert L.design_req_ids(b)==['REQ-A1','REQ-A2','REQ-A5b','REQ-A10'], L.design_req_ids(b)
assert L.design_req_ids('## Requirements\nCovers REQ-2 and REQ-10.\n')==['REQ-2','REQ-10']"
D="$T/amend"; rm -rf "$D"; mkdir -p "$D/docs/design" "$D/tests/acceptance/specs"
printf -- '---\nid: DESIGN-1\ntype: design\nstatus: approved\n---\n## Requirements (acceptance criteria)\n- [ ] REQ-A1: amended 2026-10-27\n\n## Amendments\n- 2026-10-27 re-approved\n' > "$D/docs/design/2026-10-26-x.md"
printf 'import pytest\n@pytest.mark.req("REQ-A1")\ndef test_a(): pass\n' > "$D/tests/acceptance/specs/test_x.py"
expect 0 "eng-spec trace: amended+reapproved design REQ-A1 is in an approved design" bash -c "cd '$D' && out=\$(python3 '$KIT/bin/eng-spec' trace .) && echo \"\$out\" | grep -q '^| REQ-A1 | docs/design/2026-10-26-x.md | tests/acceptance/specs/test_x.py' && ! echo \"\$out\" | grep -q 'not in an approved design'"
