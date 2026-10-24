"""`eng` console script: thin wrapper over the kit's bin/eng-* scripts (stdlib only).

Each subcommand runs the bundled script with the current interpreter, so behaviour is identical to
calling bin/eng-init etc. from a kit checkout. Repos never need this package: eng init/upgrade vendor
standalone copies into <repo>/.eng/bin/."""
import os
import subprocess
import sys

from . import kit_dir, kit_version

# subcommand -> (script, fixed leading args, defaults to repo '.' when no positional given)
COMMANDS = {
    "init": ("eng-init", [], True, "scaffold the kit into a repo (eng-init)"),
    "upgrade": ("eng-init", ["--upgrade"], True, "re-vendor kit files into a repo (eng-init --upgrade)"),
    "check": ("eng-check", [], True, "validate process artifacts (eng-check)"),
    "status": ("eng-status", [], True, "one-screen status (eng-status)"),
    "new": ("eng-new", [], False, "create an artifact from a template (eng-new)"),
    "spec": ("eng-spec", [], False, "executable specs: init|lock|status|trace (eng-spec)"),
    "run": ("eng-run", [], False, "run an agent role headless (eng-run)"),
}

USAGE = """usage: eng <command> [args...]

commands:
%s
  version   print the kit version
  help      show this help

`eng <command> --help` shows the command's own options. Repo defaults to '.' for init/upgrade/check/status.
""" % "\n".join("  %-9s %s" % (k, v[3]) for k, v in COMMANDS.items())


def _has_positional(args):
    return any(not a.startswith("-") for a in args)


def main(argv=None):
    argv = list(sys.argv[1:] if argv is None else argv)
    if not argv or argv[0] in ("help", "-h", "--help"):
        sys.stdout.write(USAGE)
        return 0 if argv else 2
    cmd, rest = argv[0], argv[1:]
    if cmd in ("version", "--version", "-V"):
        print("eng-process %s (kit: %s)" % (kit_version(), kit_dir()))
        return 0
    if cmd not in COMMANDS:
        sys.stderr.write("eng: unknown command %r\n\n%s" % (cmd, USAGE))
        return 2
    script, fixed, default_repo, _ = COMMANDS[cmd]
    if default_repo and not _has_positional(rest) and not any(a in ("-h", "--help") for a in rest):
        rest = ["."] + rest
    path = os.path.join(kit_dir(), "bin", script)
    if not os.path.isfile(path):
        sys.stderr.write("eng: kit script missing: %s (broken install?)\n" % path)
        return 2
    try:
        return subprocess.call([sys.executable, path] + rest + fixed)
    except KeyboardInterrupt:
        return 130


if __name__ == "__main__":
    sys.exit(main())
