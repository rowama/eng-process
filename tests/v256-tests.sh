# v2.5.6 tests: owner inbox. Sourced by run-tests.sh after v255 (uses $KIT $T expect).
EI="$KIT/bin/eng-init"
I1="$T/ib-init"; rm -rf "$I1"; python3 "$EI" "$I1" >/dev/null
expect 0 "eng-init creates inbox from template" bash -c "cmp -s '$I1/thoughts/shared/inbox.md' '$KIT/templates/inbox.md' && grep -q '^## Deferred' '$I1/thoughts/shared/inbox.md'"
expect 0 "eng-check passes with inbox items (no front matter needed)" bash -c "echo '- [idea] 2026-10-26: x' >> '$I1/thoughts/shared/inbox.md' && mkdir -p '$I1/thoughts/shared/inbox' && echo '- old' > '$I1/thoughts/shared/inbox/2026-10-26-1200-inbox.md' && python3 '$KIT/bin/eng-check' '$I1'"
I2="$T/ib-up"; rm -rf "$I2"; python3 "$EI" "$I2" >/dev/null; rm "$I2/thoughts/shared/inbox.md"
expect 0 "upgrade creates missing inbox" bash -c "python3 '$EI' --upgrade '$I2' --no-commit | grep -q 'create  thoughts/shared/inbox.md' && cmp -s '$I2/thoughts/shared/inbox.md' '$KIT/templates/inbox.md'"
expect 0 "upgrade keeps an edited inbox" bash -c "echo '- [note] keep me' >> '$I2/thoughts/shared/inbox.md' && python3 '$EI' --upgrade '$I2' --no-commit >/dev/null && grep -q 'keep me' '$I2/thoughts/shared/inbox.md'"
expect 0 "eng-inbox skill vendored with capture + process triggers" bash -c "grep -q 'process incoming' '$I1/.claude/skills/eng-inbox/SKILL.md' && grep -q 'ff:' '$I1/.claude/skills/eng-inbox/SKILL.md'"
