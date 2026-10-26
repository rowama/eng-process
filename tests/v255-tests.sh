# v2.5.5 tests: eng-init --upgrade auto-commits kit paths only. Sourced by run-tests.sh after v254 (uses $KIT $T expect).
EI="$KIT/bin/eng-init"
mk255(){ local d="$T/u-$1"; rm -rf "$d"; python3 "$EI" "$d" >/dev/null && (cd "$d" && git init -q && git config user.email t@example.com && git config user.name T && git add -A && git commit -qm init && echo old > .eng/VERSION && echo "# stale" >> .eng/bin/eng-check && git commit -qam "old kit"); echo "$d"; }
U1=$(mk255 clean)
expect 0 "upgrade on clean tree commits kit paths with VERSION; tree clean" bash -c "cd '$U1' && V=\$(cat '$KIT/VERSION') && python3 '$EI' --upgrade . | grep -q \"^Committed kit upgrade to v\$V as [0-9a-f]* (kit paths only; not pushed)\\.\$\" && git log -1 --format=%s | grep -qx \"chore: eng-process kit upgrade to v\$V\" && git show --name-only HEAD | grep -qx .eng/VERSION && [ -z \"\$(git status --porcelain)\" ]"
U2=$(mk255 dirty)
expect 0 "dirty non-kit file + runners.toml edit left unstaged; kit committed" bash -c "cd '$U2' && echo x >> AGENTS.md && echo '# local' >> .eng/runners.toml && python3 '$EI' --upgrade . | grep -q '^Committed kit upgrade to v' && git show --name-only HEAD | grep -qx '.eng/VERSION' && ! git show --name-only HEAD | grep -Eq 'AGENTS.md|runners.toml' && git status --porcelain | grep -q '^ M AGENTS.md' && git status --porcelain | grep -q '^ M .eng/runners.toml'"
U3=$(mk255 nocommit)
expect 0 "--no-commit leaves kit changes uncommitted with message" bash -c "cd '$U3' && h=\$(git rev-parse HEAD) && python3 '$EI' --upgrade . --no-commit | grep -q 'left uncommitted: --no-commit' && [ \"\$(git rev-parse HEAD)\" = \$h ] && git status --porcelain | grep -q '^ M .eng/VERSION'"
expect 0 "eng upgrade --no-commit passes through cli" bash -c "cd '$U3' && git checkout -q . && PYTHONPATH='$KIT/src' python3 -m eng_process upgrade --no-commit | grep -q 'left uncommitted: --no-commit'"
expect 0 "second upgrade: nothing to commit" bash -c "cd '$U1' && python3 '$EI' --upgrade . | grep -q 'left uncommitted: nothing to commit'"
U4="$T/u-nogit"; rm -rf "$U4"; python3 "$EI" "$U4" >/dev/null
expect 0 "not a git repo: exit 0, left uncommitted" bash -c "cd '$U4' && GIT_CEILING_DIRECTORIES='$T' python3 '$EI' --upgrade . | grep -q 'left uncommitted: not a git repo'"
U5=$(mk255 merge)
expect 0 "merge in progress: left uncommitted" bash -c "cd '$U5' && touch .git/MERGE_HEAD && python3 '$EI' --upgrade . | grep -q 'left uncommitted: merge in progress'"
