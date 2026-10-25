# v2.5.0 tests: executable specs (eng-spec, scaffold, eng-check warn-only checks, eng-run flagging). Sourced by run-tests.sh
TP="$KIT/templates"
# 1. templates / prompts / skills / docs
expect 0 "design doc has Acceptance examples (Given/When/Then)" bash -c "grep -q '^## Acceptance examples' '$TP/design-doc.md' && grep -q 'GIVEN <context> WHEN <action> THEN' '$TP/design-doc.md'"
expect 0 "slice template: reqs, specs, run-specs-red task" bash -c "grep -q '^reqs: \[\]' '$TP/slice.md' && grep -q '^specs: \[\]' '$TP/slice.md' && grep -q 'confirm they fail for the right reason (red)' '$TP/slice.md'"
expect 0 "plan Testing Strategy, DoD, verification report, ADR template cover executable specs" bash -c "grep -q 'Acceptance (executable specs' '$TP/plan.md' && grep -q 'approved speclock sha256' '$TP/plan.md' && grep -q 'Executable specs' '$TP/definition-of-done.md' && grep -q '^## Executable specs' '$TP/verification-report.md' && grep -q 'four-layer' '$TP/adr-acceptance-tests.md'"
expect 0 "prompts bumped to version 2 and mention executable specs" bash -c "for r in implement plan-review code-review; do grep -q '^prompt_version: 2' '$TP/prompts/'\$r.md && grep -q 'Executable specs' '$TP/prompts/'\$r.md || exit 1; done; grep -q 'Never edit locked specs' '$TP/prompts/implement.md' && grep -q 'eng-spec status' '$TP/prompts/code-review.md'"
expect 0 "skills cover executable specs" bash -c "for s in discover architecture-review plan implement-slice verify ship triage project-init; do grep -qi 'v2.5' '$KIT/skills/eng-'\$s/SKILL.md || { echo \$s; exit 1; }; done; grep -q 'eng-spec lock' '$KIT/skills/eng-plan/SKILL.md' && grep -q 'Never edit' '$KIT/skills/eng-implement-slice/SKILL.md' && grep -q 'eng-spec trace' '$KIT/skills/eng-verify/SKILL.md'"
expect 0 "PROCESS.md 13: design-side vs executable specs, sizes, warn-only until 2.6.0, migration" bash -c "f='$KIT/PROCESS.md'; grep -q '^## 13. Executable specifications' \$f && grep -q 'Design-side specs' \$f && grep -q 'test-side' \$f && grep -q 'warn-only until v2.6.0' \$f && grep -q 'Migration / grandfathering' \$f && grep -q 'Medium: specs on the API channel' \$f"
expect 0 "README pins v2.5.1 and documents eng-spec; CHANGELOG 2.5.0; VERSION" bash -c "grep -q '@v2.5.1' '$KIT/README.md' && grep -q 'eng-spec' '$KIT/README.md' && grep -q '^## 2.5.0' '$KIT/CHANGELOG.md' && grep -qx '2.5.1' '$KIT/VERSION'"
expect 0 "cli exposes eng spec" python3 -c "
import sys; sys.path.insert(0,'$KIT/src'); from eng_process import cli; assert cli.COMMANDS['spec'][0] == 'eng-spec'"
expect 0 "new checks registered warn-only until 2.6.0" python3 -c "
import sys; sys.path.insert(0,'$KIT/bin'); import englib as L
for c in ['spec-changed-without-approval','dsl-interface-changed','dsl-assertion-changed','slice-without-spec','spec-unknown-node','req-without-spec','speclock-not-approved']:
    assert L.WARN_ONLY_UNTIL[c] == '2.6.0', c"

# 2. scaffold + vendoring
expect 0 "eng-init vendors the acceptance scaffold" bash -c "for f in conftest.py dsl.py README.md drivers/api.py drivers/ui.py drivers/mcp.py specs/test_example_ordering.py; do test -f '$G/.eng/templates/acceptance/'\$f || { echo \$f; exit 1; }; done"
expect 0 "scaffold python compiles" python3 -c "
import os
for d, _, fs in os.walk('$TP/acceptance'):
    for f in fs:
        if f.endswith('.py'): compile(open(os.path.join(d, f), encoding='utf-8').read(), f, 'exec')"
expect 0 "scaffold specs use domain language only (no URLs, selectors, status codes)" bash -c "! grep -nE 'http|/[a-z]+\"|status_code|page\\.|sleep' '$TP/acceptance/specs/'*.py"
expect 0 "eng-init --upgrade with a vendored acceptance dir works" eng-init "$G" --upgrade

# 3. eng-spec init / lock / status / trace
AC="$T/ac"; cp -r "$M" "$AC"
expect 0 "eng-spec init copies scaffold, sets acceptance flag" bash -c "cd '$AC' && eng-spec init . >/dev/null && test -f tests/acceptance/specs/test_example_ordering.py && grep -q '^acceptance: executable-specs' PROJECT_STATE.md"
expect 0 "eng-spec init never overwrites" bash -c "cd '$AC' && echo '# mine' >> tests/acceptance/dsl.py && eng-spec init . | grep -q '^keep    tests/acceptance/dsl.py' && grep -q '# mine' tests/acceptance/dsl.py"
expect 0 "opted in, no lock at implement: speclock warning + slice-without-spec warning, exit 0" bash -c "cd '$AC' && eng-check . > o.txt; r=\$?; grep -q 'no spec lock' o.txt && grep -q 'slice names no executable spec' o.txt && [ \$r = 0 ]"
expect 1 "--strict turns v2.5 warnings into errors" bash -c "cd '$AC' && eng-check --strict ."
S5=$(cd "$AC" && ls thoughts/shared/slices/*.md)
(cd "$AC" && sed -i 's#^specs: \[\]#specs: [tests/acceptance/specs/test_example_ordering.py::test_quantity_is_kept]#' "$S5"
  H=$(eng-spec lock . | sed -n 's/.*approved speclock sha256:\([0-9a-f]*\).*/\1/p'); P=$(ls thoughts/shared/plans/*.md)
  printf '| 2026-01-03 | CP-C | %s | approved speclock sha256:%s |\n' "$P" "$H" >> PROJECT_STATE.md)
expect 0 "approved lock + slice spec: no v2.5 warnings" bash -c "cd '$AC' && eng-check . > o.txt && ! grep -qiE 'spec|dsl' o.txt"
expect 0 "eng-spec status clean, approval ok" bash -c "cd '$AC' && eng-spec status . | grep -q 'lock approval: ok' && eng-spec status . | grep -q 'match the lock'"
expect 0 "lock records specs, DSL interface, assertion steps (no drivers, no private helpers)" python3 -c "
import json; d = json.load(open('$AC/tests/acceptance/spec-lock.json'))
assert list(d['specs']) == ['tests/acceptance/specs/test_example_ordering.py'], d['specs']
assert any(k.endswith('Dsl.register_user') for k in d['dsl_interface']) and not any('_alias' in k for k in d['dsl_interface'])
assert list(d['dsl_assertions']) == ['tests/acceptance/dsl.py::Dsl.assert_order_placed'], d['dsl_assertions']
assert not any('drivers' in k for s in ('specs','dsl_interface','dsl_assertions') for k in d[s])"
expect 0 "lock is stable across CRLF" bash -c "cp -r '$AC' '$T/acrl' && cd '$T/acrl' && sed -i 's/\$/\r/' tests/acceptance/dsl.py tests/acceptance/specs/*.py && eng-spec status . | grep -q 'match the lock'"
expect 0 "driver edit: not flagged" bash -c "cp -r '$AC' '$T/acd' && cd '$T/acd' && echo '# tweak' >> tests/acceptance/drivers/api.py && ! eng-check . | grep -qiE 'spec|dsl'"
expect 0 "private DSL helper edit: not flagged" bash -c "cp -r '$AC' '$T/acp' && cd '$T/acp' && sed -i 's/uuid.uuid4().hex\[:6\]/uuid.uuid4().hex[:8]/' tests/acceptance/dsl.py && ! eng-check . | grep -qiE 'spec|dsl'"
expect 0 "spec edit: spec-changed warning, exit 0; speclock mismatch after relock without row" bash -c "cp -r '$AC' '$T/acs' && cd '$T/acs' && sed -i 's/quantity=3)\$/quantity=4)/' tests/acceptance/specs/test_example_ordering.py && eng-check . > o.txt && grep -q '^WARN  tests/acceptance/specs: locked executable specs changed' o.txt && eng-spec lock . >/dev/null && eng-check . | grep -q 'differs from the speclock sha256 approved on 2026-01-03'"
expect 0 "new spec file is flagged as added" bash -c "cp -r '$AC' '$T/acn' && cd '$T/acn' && printf 'def test_new(app):\n    pass\n' > tests/acceptance/specs/test_new.py && eng-check . | grep -q 'added tests/acceptance/specs/test_new.py'"
expect 0 "DSL interface edit (new parameter): dsl-interface-changed" bash -c "cp -r '$AC' '$T/aci' && cd '$T/aci' && sed -i 's/def register_user(self, name=\"alice\")/def register_user(self, name=\"alice\", admin=False)/' tests/acceptance/dsl.py && eng-check . | grep -q 'locked DSL public interface changed.*Dsl.register_user'"
expect 0 "DSL docstring edit: dsl-interface-changed" bash -c "cp -r '$AC' '$T/acq' && cd '$T/acq' && sed -i 's/A product is available to buy./A product exists./' tests/acceptance/dsl.py && eng-check . | grep -q 'Dsl.add_product'"
expect 0 "DSL non-assertion step body edit: not flagged" bash -c "cp -r '$AC' '$T/acb' && cd '$T/acb' && sed -i 's/self._d.place_order(self._alias(user), self._alias(product), quantity)/self._d.place_order(self._alias(user), self._alias(product), int(quantity))/' tests/acceptance/dsl.py && ! eng-check . | grep -qiE 'spec|dsl'"
expect 0 "DSL assertion body edit flagged until a review names the step" bash -c "cp -r '$AC' '$T/aca' && cd '$T/aca' && sed -i 's/in orders, orders/in orders, \"missing\"/' tests/acceptance/dsl.py && eng-check . | grep -q 'DSL assertion step body changed.*assert_order_placed' && eng-new review sl --agent t >/dev/null && V=\$(ls -t thoughts/shared/verification/*-review.md | head -1) && echo '1. [low] dsl.py - assert_order_placed message changed, check not weaker' >> \$V && ! eng-check . | grep -q 'DSL assertion step body changed'"
expect 0 "slice spec node unknown: spec-unknown-node" bash -c "cp -r '$AC' '$T/acu' && cd '$T/acu' && sed -i 's#::test_quantity_is_kept#::test_nope#' $S5 && eng-check . | grep -q \"has no test function 'test_nope'\""
expect 0 "slice 'specs: none - reason' accepted" bash -c "cp -r '$AC' '$T/acx' && cd '$T/acx' && sed -i 's#^specs: .*#specs: none - refactor only, covered by unit tests#' $S5 && ! eng-check . | grep -q 'executable spec'"
expect 0 "verify: REQ without spec warns (req-without-spec)" bash -c "cp -r '$AC' '$T/acv' && cd '$T/acv' && sed -i 's/^phase: implement/phase: verify/' PROJECT_STATE.md && ! eng-check . | grep -q 'requirements with no executable spec' && sed -i 's/REQ-1/REQ-9/' tests/acceptance/specs/*.py && eng-check . | grep -q 'requirements with no executable spec (@pytest.mark.req): REQ-1'"
expect 0 "eng-spec trace maps REQ-1 to the spec" bash -c "cd '$AC' && eng-spec trace . | grep -q '^| REQ-1 | docs/design/.* | tests/acceptance/specs/test_example_ordering.py |'"
expect 0 "triage small: v2.5 checks off" bash -c "cp -r '$T/acs' '$T/acsm' && cd '$T/acsm' && sed -i 's/^triage: .*/triage: small/' PROJECT_STATE.md && ! eng-check . | grep -qiE 'spec|dsl'"
expect 0 "not opted in: no v2.5 warnings (grandfathered)" bash -c "! eng-check '$M' | grep -qiE 'executable spec|spec lock|DSL'"
expect 0 "eng spec via the package cli" bash -c "cd '$AC' && PYTHONPATH='$KIT/src' ENG_KIT_DIR='$KIT' python3 -m eng_process.cli spec status . | grep -q 'lock approval'"

# 4. eng-run implement flags spec / DSL edits (warning, exit code unchanged)
ER="$T/er"; cp -r "$RN" "$ER"; (cd "$ER" && eng-spec init . >/dev/null && eng-spec lock . >/dev/null)
expect 0 "implement run editing a locked spec: WARNING + OWNER REVIEW, exit 0" bash -c "cd '$ER' && FAKE_TOUCH=tests/acceptance/specs/test_example_ordering.py python3 .eng/bin/eng-run implement $PL $SID > o.txt 2>&1; r=\$?; [ \$r = 0 ] && grep -q 'WARNING: implement run edited locked executable specs' o.txt && grep -q 'OWNER REVIEW' \$(ls -t thoughts/shared/runs/*-implement-*.md | head -1)"
expect 0 "implement run editing only a driver: no flag" bash -c "cp -r '$RN' '$T/er2' && cd '$T/er2' && eng-spec init . >/dev/null && eng-spec lock . >/dev/null && FAKE_TOUCH=tests/acceptance/drivers/api.py python3 .eng/bin/eng-run implement $PL $SID > o.txt 2>&1 && ! grep -q 'WARNING: implement run edited' o.txt && ! grep -q 'OWNER REVIEW' thoughts/shared/runs/*-implement-*.md"
expect 0 "implement run with runner failure keeps its exit code" bash -c "cd '$ER' && FAKE_RC=5 FAKE_TOUCH=tests/acceptance/specs/test_example_ordering.py python3 .eng/bin/eng-run implement $PL $SID >/dev/null 2>&1; [ \$? = 5 ]"
