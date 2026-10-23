"""eng-process: a file-based engineering process kit for AI coding agents (see README.md)."""
import os

_HERE = os.path.dirname(os.path.abspath(__file__))


def kit_dir():
    """Directory holding bin/, skills/, templates/, PROCESS.md, VERSION.

    Installed wheel: <site-packages>/eng_process/kit. Source checkout: the repo root."""
    inst = os.path.join(_HERE, "kit")
    if os.path.isfile(os.path.join(inst, "VERSION")):
        return inst
    return os.path.dirname(os.path.dirname(_HERE))


def kit_version():
    with open(os.path.join(kit_dir(), "VERSION"), encoding="utf-8") as f:
        return f.read().strip()


__version__ = kit_version()
