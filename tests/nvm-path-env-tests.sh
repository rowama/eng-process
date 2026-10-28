# nvm PATH auto-prepend + runners.toml [env] (Unreleased). Sourced by run-tests.sh; reuses $RN/$PL/$FK/$FAKE_LOG from v230.
NH="$T/nvmhome"; rm -rf "$NH"; mkdir -p "$NH/.nvm/versions/node/v9.0.0/bin" "$NH/.nvm/versions/node/v20.1.0/bin" "$NH/.nvm/versions/node/v18.2.0/bin"
cp "$FK/fake-agent" "$NH/.nvm/versions/node/v9.0.0/bin/codex"; cp "$FK/fake-agent" "$NH/.nvm/versions/node/v20.1.0/bin/codex"; chmod +x "$NH"/.nvm/versions/node/*/bin/codex
expect 0 "nvm_bin_dirs: only dirs with the exe, newest version first, NVM_DIR too" python3 -c "
import sys,os; sys.path.insert(0,'$KIT/bin'); import englib as L
d=L.nvm_bin_dirs('codex', {'HOME':'$NH'}); assert [os.path.basename(os.path.dirname(x)) for x in d]==['v20.1.0','v9.0.0'], d
assert L.nvm_bin_dirs('codex', {'HOME':'/nonexistent','NVM_DIR':'$NH/.nvm'})==d
assert L.nvm_bin_dirs('nope', {'HOME':'$NH'})==[]"
expect 0 "eng-run auto-prepends nvm bin when runner missing from PATH and runs it" bash -c "cp -r '$RN' '$T/nv' && cd '$T/nv' && : > '$FAKE_LOG' && out=\$(HOME='$NH' NVM_DIR= PATH=/usr/bin:/bin python3 .eng/bin/eng-run plan-review $PL --runner codex 2>&1) && echo \"\$out\" | grep -q 'v20.1.0/bin' && grep -q 'codex ARGV' '$FAKE_LOG'"
expect 0 "missing runner (no nvm match): still exit 127 mentioning nvm" bash -c "cd '$RN' && out=\$(HOME=/nonexistent NVM_DIR= PATH=/usr/bin:/bin python3 .eng/bin/eng-run plan-review $PL --runner codex 2>&1); [ \$? = 127 ] && echo \"\$out\" | grep -q nvm"
expect 0 "runners.toml [env] PATH finds the runner; [runners.codex.env] reaches the subprocess" bash -c "cp -r '$RN' '$T/ev' && cd '$T/ev' && printf '\n[env]\nPATH = \"$NH/.nvm/versions/node/v9.0.0/bin\"\nFAKE_STDOUT = \"from-global-env\"\n[runners.codex.env]\nFAKE_STDOUT = \"from-runner-env\"\n' >> .eng/runners.toml && : > '$FAKE_LOG' && out=\$(HOME=/nonexistent PATH=/usr/bin:/bin python3 .eng/bin/eng-run plan-review $PL --runner codex 2>&1) && echo \"\$out\" | grep -q from-runner-env && ! echo \"\$out\" | grep -q 'nvm bin' && grep -q 'codex ARGV' '$FAKE_LOG'"
expect 0 "runner_env: PATH prepended (runner, [env], inherited); parse_toml_min loads the env shape" python3 -c "
import sys,os; sys.path.insert(0,'$KIT/bin'); import englib as L
t='[env]\nPATH = \"/g\"\nA = \"1\"\n[runners.codex]\ntype = \"codex\"\n[runners.codex.env]\nPATH = \"/r\"\nA = \"2\"\n'
c=L.parse_toml_min(t); assert c['env']=={'PATH':'/g','A':'1'} and c['runners']['codex']['env']=={'PATH':'/r','A':'2'}, c
e=L.runner_env(c,'codex',{'PATH':'/bin'}); assert e['PATH']==os.pathsep.join(['/r','/g','/bin']) and e['A']=='2', e
assert L.runner_env(c,'claude',{'PATH':'/bin'})['A']=='1'
L.parse_toml_min(open('$KIT/templates/runners.toml').read())"
