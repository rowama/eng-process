"""Shared helpers for eng-* scripts. Stdlib only (python3 >= 3.9). Script output is ASCII-only."""
import os, re, sys, subprocess, datetime

try:  # avoid mojibake on consoles that are not UTF-8 (e.g. Windows cp1252)
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

KIT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KIT_VERSION = open(os.path.join(KIT_DIR, "VERSION")).read().strip() if os.path.exists(os.path.join(KIT_DIR, "VERSION")) else "?"
REQUIRED_FIELDS = ["id", "type", "phase", "status", "owner_agent", "date", "links"]
PHASES = ["discover", "scope", "research", "architecture", "plan", "implement",
          "verify", "ship", "reflect", "any"]
PHASE_IDX = {p: i for i, p in enumerate(PHASES)}
IMPL_PHASES = {"implement", "verify", "ship"}
TRIAGES = {"unset", "small", "medium", "large"}
# checkpoint -> phase in which it is requested/decided
CHECKPOINTS = {"A": "discover", "R": "research", "B": "architecture", "C": "plan",
               "S": "implement", "D": "verify", "P": "ship"}
DOC = {"input", "draft", "in-review", "approved", "superseded"}   # input = pre-draft, not approved
STATUSES = {
    "project-state": {"active", "paused", "done"},
    "design": DOC,
    "architecture": DOC,
    "vision": DOC,
    "project-brief": DOC,
    "adr": {"proposed", "accepted", "partially-accepted", "deferred", "rejected", "deprecated", "superseded"},
    "research": {"input", "draft", "in-review", "approved", "discarded"},
    "market-research": {"input", "draft", "in-review", "approved", "discarded"},
    "plan": {"input", "draft", "in-review", "approved", "in-progress", "done", "superseded"},
    "slice": {"todo", "in-progress", "blocked", "review", "done"},
    "handoff": {"complete"},
    "verification": {"draft", "pass", "fail"},
    "review-findings": {"open", "addressed", "closed"},
    "retro": {"draft", "done"},
    "process-feedback": {"open", "closed"},
    "conventions": {"active"},
    "definition-of-done": {"active"},
    "owner-guide": {"active"},
    "run-log": {"ok", "failed"},
}
APPROVED = {"approved", "accepted", "partially-accepted", "in-progress", "done", "pass"}
UNAPPROVED = {"input", "draft", "in-review", "proposed", "todo"}
# types whose approval must appear in the Approval log
LOGGED_TYPES = {"design", "architecture", "vision", "project-brief", "research", "market-research", "plan", "adr"}
# artifact type -> (template file, destination dir, filename pattern)
ARTIFACTS = {
    "design":          ("design-doc.md", "docs/design", "{date}-{slug}.md"),
    "architecture":    ("architecture.md", "docs/architecture", "{date}-{slug}.md"),
    "vision":          ("vision.md", "docs/vision", "{slug}.md"),
    "adr":             ("adr.md", "docs/decisions", "{num:04d}-{slug}.md"),
    "research":        ("research.md", "thoughts/shared/research", "{date}-{slug}.md"),
    "market-research": ("market-research.md", "thoughts/shared/market-research", "{date}-{slug}.md"),
    "brief":           ("project-brief.md", "thoughts/shared/briefs", "{date}-{slug}.md"),
    "plan":            ("plan.md", "thoughts/shared/plans", "{date}-{slug}.md"),
    "slice":           ("slice.md", "thoughts/shared/slices", "{date}-{slug}.md"),
    "handoff":         ("handoff.md", "thoughts/shared/handoffs", "{datetime}_{slug}.md"),
    "review":          ("review-findings.md", "thoughts/shared/verification", "{date}-{slug}-review.md"),
    "plan-review":     ("review-findings.md", "thoughts/shared/verification", "{date}-{slug}-plan-review.md"),
    "verification":    ("verification-report.md", "thoughts/shared/verification", "{date}-{slug}.md"),
    "retro":           ("retro.md", "thoughts/shared/retros", "{date}-{slug}.md"),
    "changelog":       ("CHANGELOG-entry.md", None, None),
}
ID_PREFIX = {"plan-review": "PLANREV", "market-research": "MRES", "brief": "BRIEF", "review": "REVIEW", "architecture": "ARCH"}
DIRS = ["docs/design", "docs/architecture", "docs/vision", "docs/decisions",
        "thoughts/shared/research", "thoughts/shared/market-research", "thoughts/shared/briefs",
        "thoughts/shared/plans", "thoughts/shared/handoffs", "thoughts/shared/slices",
        "thoughts/shared/verification", "thoughts/shared/retros", "thoughts/shared/review-notes",
        "thoughts/shared/inbox", "thoughts/shared/runs", ".eng/templates"]
CHECKED_ROOTS = ["docs/design", "docs/architecture", "docs/vision", "docs/decisions", "thoughts/shared"]
UNCHECKED_DIRS = ["thoughts/shared/review-notes", "thoughts/shared/inbox"]
UNCHECKED_FILES = ["thoughts/shared/inbox.md"]   # v2.5.6 owner inbox: capture-only, no front matter   # owner's scratch files: agents don't edit, no front matter
PLAN_SECTIONS = [r"^## Overview", r"^## Desired End State", r"^## What We're NOT Doing",
                 r"^## Phase \d+", r"^#### Automated Verification", r"^#### Manual Verification"]
SEVERITIES = {"critical", "high", "medium", "low"}
DISPOSITIONS = {"open", "fixed", "accepted-risk", "rejected"}
# statuses that look like approval but aren't (e.g. approved-for-review, pre-approved, approved-draft)
PSEUDO_APPROVAL = re.compile(r"approv|accept", re.I)


def findings(body):
    """Rows of a review-findings '## Findings' table: dicts(num, severity, disposition, reason, raw)."""
    out = []
    for line in (section(body, "Findings") or "").splitlines():
        c = [x.strip() for x in line.strip().strip("|").split("|")]
        if len(c) < 6 or set(c[0]) <= set("-: ") or c[0] in ("#", ""):
            continue
        disp = (c[4].split() or [""])[0].lower().strip("()`*:,")
        out.append({"num": c[0], "severity": c[1].lower().strip("`* "), "disposition": disp,
                    "reason": c[5], "raw": line})
    return out


def waived(repo, plan_rel):
    """True if the Approval log has a Rob-approved plan-review waiver row naming this plan (grandfather route)."""
    sp = os.path.join(repo, "PROJECT_STATE.md")
    if not os.path.isfile(sp):
        return False
    for r in approval_log(read_front_matter(sp)[1]):
        if plan_rel in r["paths"] and "waiver" in r["decision"] and "plan review" in r["decision"] \
                and re.search(r"\brob\b|owner", r["decision"]):
            return True
    return False


HISTORY_HEADINGS = re.compile(r"history|done|archive|completed|changelog|past|log of", re.I)


def _ver(x):
    try:
        return tuple(int(n) for n in str(x).strip().split("."))
    except ValueError:
        return ()


# New checks are warn-only until the listed kit version, then they become errors ('--strict' forces errors now).
# stray-approval was warn-only in 2.3.x and is an error from 2.4.0.
WARN_ONLY_UNTIL = {"stray-approval": "2.4.0", "rejected-no-evidence": "2.5.0",
                   "draft-before-design": "2.5.0", "design-changed-after-approval": "2.5.0"}


def warn_only(check, strict=False):
    until = WARN_ONLY_UNTIL.get(check)
    return bool(until) and not strict and _ver(KIT_VERSION) < _ver(until)


def stray_approvals(body):
    """Approval-like lines in PROJECT_STATE body outside the Approval log table (returns line texts).
    Ignored: HTML comments, struck-through text (~~CP-R~~ approved ...), and history-style sections
    (headings containing history/done/archive/completed/changelog)."""
    out, in_log, in_comment, in_hist = [], False, False, False
    for line in body.splitlines():
        s = line.strip()
        if s.startswith("<!--"):
            in_comment = "-->" not in s
            continue
        if in_comment:
            in_comment = "-->" not in s
            continue
        if re.match(r"^#{2,6} ", s):
            h = s.lstrip("#").strip()
            if s.startswith("## "):
                in_log = h.lower() == "approval log"
                in_hist = bool(HISTORY_HEADINGS.search(h)) and not in_log
            elif not in_log:
                in_hist = bool(HISTORY_HEADINGS.search(h))
            continue
        live = re.sub(r"~~.*?~~", "", s)          # struck-through text is history
        if in_hist or not re.search(r"\bCP-[ARBCSDP]\b", live):
            continue
        rowlike = s.startswith("|") or s.count("|") >= 2
        decided = re.search(r"\b(approved|accepted|waiver)\b", live, re.I) and not re.search(r"\b(awaiting|pending|needs?|request)", live, re.I)
        if in_log and not s.startswith("|"):
            out.append(s)
        elif not in_log and (rowlike or decided):
            out.append(s)
    return out


def plan_review_problems(repo, plan_rel, pfm):
    """Mandatory plan-review gate (medium/large). Returns a list of problem strings."""
    pr = posix(pfm.get("plan_review", "")) if pfm and isinstance(pfm.get("plan_review"), str) else ""
    if not pr or pr in ("none", []) or not isinstance(pr, str):
        if waived(repo, plan_rel):
            return []
        return ["no plan review linked (set 'plan_review:' in the plan front matter, see PROCESS.md 10). "
                "Plan approved before reviews were mandatory? Grandfather it: run the review retroactively before the next "
                "slice starts, or log Rob's waiver: '| <date> | CP-C | %s | waiver: plan review - approved by Rob |'" % plan_rel]
    path = os.path.join(repo, pr)
    if not os.path.isfile(path):
        return ["plan_review file does not exist: " + pr]
    rfm, rbody = read_front_matter(path)
    if not rfm or rfm.get("type") != "review-findings":
        return ["plan_review %s is not a review-findings artifact" % pr]
    rows, probs = findings(rbody), []
    if not rows and "no findings" not in rbody.lower():
        probs.append("plan review %s has no findings rows (write 'No findings.' if Codex reported none)" % pr)
    for f in rows:
        tag = "plan review %s finding %s" % (pr, f["num"])
        if f["severity"] not in SEVERITIES:
            probs.append("%s: severity '%s' not one of critical/high/medium/low" % (tag, f["severity"]))
        if f["disposition"] not in DISPOSITIONS:
            probs.append("%s: disposition '%s' not one of open/fixed/accepted-risk/rejected" % (tag, f["disposition"]))
        elif f["severity"] in ("critical", "high") and f["disposition"] == "open":
            probs.append("%s: %s finding still open" % (tag, f["severity"]))
        if f["disposition"] == "accepted-risk" and not re.search(r"\brob\b|owner", f["reason"], re.I):
            probs.append("%s: accepted-risk needs Rob's approval recorded in Reason/approval" % tag)
        if f["disposition"] == "rejected" and len(f["reason"].strip()) < 3:
            probs.append("%s: rejected needs a reason" % tag)
    return probs


# Evidence for rejecting a finding: file:line (src/a.py:12, a.ts:3-9) or a test reference.
EVIDENCE = re.compile(r"[\w./\\-]+\.\w+:\d+|\btests?[/\\:_.]|\btest_\w+|\w+\.(test|spec)\.\w+|\b[\w/.-]*_test\.\w+|::\w+", re.I)


def rejected_without_evidence(body):
    """Finding numbers whose disposition is 'rejected' but whose Reason cites no file:line or test."""
    return [f["num"] for f in findings(body) if f["disposition"] == "rejected" and not EVIDENCE.search(f["reason"])]


def file_sha(path):
    """sha256 of a file with line endings normalized (CRLF == LF), hex."""
    import hashlib
    with open(path, "rb") as fh:
        return hashlib.sha256(fh.read().replace(b"\r\n", b"\n")).hexdigest()


def design_changed_after_approval(repo, rel_path, rows):
    """Problem string if a design doc changed after its latest CP-A approval row, else None.
    If the row's decision carries 'sha256:<hex prefix>' the file content is compared (exact);
    otherwise git: any commit touching the file with a commit date after the approval date
    (uncommitted edits are not flagged; see PROCESS.md 'Design changes after CP-A')."""
    mine = [r for r in rows if rel_path in r["paths"] and r["cp"].upper().startswith("CP-A")
            and re.search(r"approved|accepted", r["decision"]) and not re.search(r"reject", r["decision"])]
    if not mine:
        return None
    last = max(mine, key=lambda r: r["date"])
    m = re.search(r"sha256:([0-9a-f]{7,64})", last["decision"])
    if m:
        if not file_sha(os.path.join(repo, rel_path)).startswith(m.group(1)):
            return "content differs from the sha256 recorded at CP-A approval (%s)" % last["date"]
        return None
    d = re.match(r"\d{4}-\d{2}-\d{2}", last["date"])
    if not d:
        return None
    try:
        out = subprocess.run(["git", "-C", repo, "log", "--format=%cs", "--", rel_path],
                             capture_output=True, text=True, timeout=10)
    except Exception:
        return None
    later = [x for x in out.stdout.split() if x > d.group(0)] if out.returncode == 0 else []
    if later:
        return "committed changes after CP-A approval on %s (latest commit %s)" % (d.group(0), later[0])
    return None


WORKING_AGREEMENTS = ["implementer", "planner", "cross_review", "push_permission", "board"]


def split_list(inner):
    """Split an inline list on commas that are outside single/double quotes."""
    out, cur, q = [], "", None
    for ch in inner:
        if q:
            if ch == q:
                q = None
            else:
                cur += ch
        elif ch in "'\"":
            q = ch
        elif ch == ",":
            out.append(cur); cur = ""
        else:
            cur += ch
    out.append(cur)
    return [x.strip() for x in out if x.strip()]


def posix(p):
    """Normalize a repo path to POSIX form ('\\' -> '/', no leading './'). Every compared or printed path goes through this."""
    s = str(p).replace("\\", "/")
    while s.startswith("./"):
        s = s[2:]
    return re.sub(r"/{2,}", "/", s)


def rel(p, repo):
    return posix(os.path.relpath(p, repo))


def _norm_paths(v):
    if isinstance(v, list):
        return [_norm_paths(x) for x in v]
    if isinstance(v, str) and "\\" in v and re.search(r"\.md\b|[\w.-]\\[\w.-]", v):
        return re.sub(r"(?<=[\w.\-*])\\(?=[\w.\-*<])", "/", v)
    return v


def parse_value(v):
    v = v.strip()
    if not (v.startswith(("'", '"'))):
        v = re.sub(r"\s+#.*$", "", v).strip()  # strip trailing comment (not inside a quoted scalar)
    if v.startswith("[") and "]" in v:
        inner = v[1:v.rindex("]")].strip()
        return split_list(inner) if inner else []
    if len(v) >= 2 and v[0] in "'\"" and v[-1] == v[0]:
        return v[1:-1]
    m = re.match(r"^(['\"])(.*?)\1\s+#", v)
    return m.group(2) if m else v


def read_front_matter(path):
    """Return (dict or None, body). Supports flat key: value, inline lists (quotes protect commas)
    and dash lists."""
    with open(path, encoding="utf-8-sig", errors="replace") as f:
        text = f.read()
    if not text.startswith("---\n"):
        return None, text
    end = text.find("\n---", 4)
    if end < 0:
        return None, text
    fm, body = {}, text[end + 4:]
    key = None
    for line in text[4:end].splitlines():
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        m = re.match(r"^([A-Za-z_][\w-]*):\s*(.*)$", line)
        if m:
            key = m.group(1)
            fm[key] = parse_value(m.group(2)) if m.group(2).strip() else []
        elif key and re.match(r"^\s*-\s+", line):
            if not isinstance(fm[key], list):
                fm[key] = []
            fm[key].append(parse_value(re.sub(r"^\s*-\s+", "", line)))
    return {k: _norm_paths(v) for k, v in fm.items()}, body


def pending_list(state):
    p = state.get("pending_approvals") or []
    if not isinstance(p, list):
        p = [] if str(p).lower() in ("", "none", "[]") else [p]
    return [x for x in p if x and str(x).lower() != "none"]


def parse_pending(item):
    """'CP-B: path + path - decision' -> (letter or None, [targets])."""
    m = re.match(r"^\s*CP-([A-Z])\s*:\s*(.*)$", item)
    if not m:
        return None, []
    rest = re.split(r"\s+(?:\u2014|--|-)\s+", m.group(2), maxsplit=1)[0]
    targets = [posix(t.strip(" `")) for t in re.split(r"\s*(?:\+|,|\band\b)\s*", rest) if t.strip(" `")]
    return m.group(1), targets


def section(body, name):
    m = re.search(r"^## %s\s*\n(.*?)(?=^## |\Z)" % re.escape(name), body, re.M | re.S)
    return re.sub(r"<!--.*?-->", "", m.group(1), flags=re.S).strip() if m else None


def approval_log(body):
    """Rows of the PROJECT_STATE Approval log: dicts(date, cp, paths, decision)."""
    sec = section(body, "Approval log") or ""
    rows = []
    for line in sec.splitlines():
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < 4 or set(cells[0]) <= set("-: ") or cells[0].lower() == "date":
            continue
        paths = [posix(x) for x in re.findall(r"[\w./\\-]+\.md", cells[2])]
        rows.append({"date": cells[0], "cp": cells[1], "paths": paths, "decision": cells[3].lower(), "raw": line})
    return rows


def git(repo, *args):
    try:
        return subprocess.run(["git", "-C", repo, *args], capture_output=True, text=True,
                              timeout=10).stdout.strip() or "none"
    except Exception:
        return "none"


def now():
    return datetime.datetime.now()


def fill(text, **kw):
    for k, v in kw.items():
        text = text.replace("{{%s}}" % k.upper(), str(v))
    return text


def template_path(repo, name):
    for d in (os.path.join(repo, ".eng", "templates"), os.path.join(KIT_DIR, "templates")):
        p = os.path.join(d, name)
        if os.path.isfile(p):
            return p
    raise FileNotFoundError("template not found: " + name)


def md_links(body):
    """Relative markdown link targets, ignoring URLs and anchors."""
    out = []
    for t in re.findall(r"\]\(([^)\s]+)\)", body):
        if re.match(r"^[a-z]+://|^#|^mailto:", t):
            continue
        out.append(posix(t.split("#")[0]))
    return out


def load_artifacts(repo):
    """{relpath: (fm, body)} for every checked artifact (fm None if missing)."""
    import glob
    files = [os.path.join(repo, f) for f in ("PROJECT_STATE.md", "AGENTS.md", "OWNER-GUIDE.md",
                                               "docs/definition-of-done.md")]
    for root in CHECKED_ROOTS:
        files += glob.glob(os.path.join(repo, root, "**", "*.md"), recursive=True)
    out = {}
    for p in files:
        r = rel(p, repo)
        if not os.path.isfile(p) or r in UNCHECKED_FILES or any(r.startswith(d + "/") for d in UNCHECKED_DIRS):
            continue
        out[r] = read_front_matter(p)
    return out


def _has(arts, types, statuses):
    return any(fm and fm.get("type") in types and fm.get("status") in statuses for fm, _ in arts.values())


def _log_ok(rows, cp):
    return any(r["cp"].upper().startswith("CP-" + cp) and re.search(r"approved|accepted", r["decision"])
               and not re.search(r"reject", r["decision"]) for r in rows)


def readiness(arts, phase, triage):
    """Missing prerequisites to legitimately be in `phase` for this triage size.
    Returns [(producing_phase, message)]. Empty list = ready."""
    miss = []
    if phase not in PHASE_IDX or phase in ("discover", "any", "reflect"):
        return miss
    state = (arts.get("PROJECT_STATE.md") or ({}, ""))
    rows = approval_log(state[1] or "")
    i = PHASE_IDX[phase]
    if triage in (None, "", "unset"):
        return [("discover", "triage is unset; run eng-triage before leaving discover")]
    if triage == "small":
        if i >= PHASE_IDX["implement"] and not _has(arts, {"slice"}, STATUSES["slice"]):
            miss.append(("implement", "small task needs a slice card (eng-new slice <slug>)"))
        if i >= PHASE_IDX["ship"] and not _has(arts, {"verification"}, {"pass"}):
            miss.append(("verify", "verification report with status pass (CP-D)"))
        return miss
    if i > PHASE_IDX["discover"] and not _has(arts, {"design"}, {"approved"}):
        miss.append(("discover", "approved design doc (CP-A)"))
    if i > PHASE_IDX["research"]:
        if triage == "large" and not _has(arts, {"research"}, {"approved"}):
            miss.append(("research", "approved codebase research doc (CP-R)"))
        if triage == "medium" and not _has(arts, {"research"}, {"draft", "in-review", "approved"}):
            miss.append(("research", "codebase research doc (thoughts/shared/research/)"))
    if i > PHASE_IDX["architecture"] and triage == "large":
        if not (_has(arts, {"architecture"}, {"approved"}) or _log_ok(rows, "B")):
            miss.append(("architecture", "approved architecture (CP-B: architecture doc or design Architecture section, logged)"))
    if i > PHASE_IDX["plan"] and not _has(arts, {"plan"}, {"approved", "in-progress", "done"}):
        miss.append(("plan", "approved plan (CP-C)"))
    if i > PHASE_IDX["verify"] and not _has(arts, {"verification"}, {"pass"}):
        miss.append(("verify", "verification report with status pass (CP-D)"))
    return miss


def load_toml(path):
    """Parse a TOML file: tomllib on 3.11+, else parse_toml_min. Returns {} if the file is missing."""
    if not os.path.isfile(path):
        return {}
    try:
        import tomllib
    except ImportError:
        tomllib = None
    if tomllib is not None and not os.environ.get("ENG_TOML_FALLBACK"):
        with open(path, "rb") as f:
            return tomllib.load(f)
    with open(path, encoding="utf-8-sig") as f:
        return parse_toml_min(f.read())


def _toml_val(v):
    v = v.strip()
    if v[:3] in ('"' * 3, "'" * 3):
        raise ValueError("multi-line strings are not supported by the fallback TOML parser")
    if v.startswith('"'):
        m = re.match(r'^"((?:[^"\\]|\\.)*)"\s*(#.*)?$', v)
        if not m:
            raise ValueError("bad string: " + v)
        return re.sub(r'\\(["\\nt])', lambda x: {"n": "\n", "t": "\t"}.get(x.group(1), x.group(1)), m.group(1))
    if v.startswith("'"):
        m = re.match(r"^'([^']*)'\s*(#.*)?$", v)
        if not m:
            raise ValueError("bad string: " + v)
        return m.group(1)
    if v.startswith("["):
        return [_toml_val(x) for x in _split_raw(v[1:v.rindex("]")])]
    v = re.sub(r"\s+#.*$", "", v).strip()
    if v in ("true", "false"):
        return v == "true"
    if re.match(r"^[+-]?\d+$", v):
        return int(v)
    raise ValueError("unsupported TOML value: " + v)


def _split_raw(inner):
    out, cur, q, esc = [], "", None, False
    for ch in inner:
        if q:
            cur += ch
            if esc:
                esc = False
            elif ch == "\\" and q == '"':
                esc = True
            elif ch == q:
                q = None
        elif ch in "'\"":
            q = ch; cur += ch
        elif ch == ",":
            out.append(cur); cur = ""
        else:
            cur += ch
    out.append(cur)
    return [x.strip() for x in out if x.strip()]


def _toml_key(k):
    return [a or b or c for a, b, c in re.findall(r'"([^"]*)"|\'([^\']*)\'|([^.\s"\']+)', k.strip())]


def parse_toml_min(text):
    """Minimal TOML subset (Python < 3.11): [tables] incl. dotted/quoted names, key = string | int | bool | [array]."""
    data = {}
    cur = data
    for n, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        m = re.match(r"^\[([^\[\]]+)\]\s*(#.*)?$", s)
        if m:
            cur = data
            for k in _toml_key(m.group(1)):
                cur = cur.setdefault(k, {})
            continue
        m = re.match(r'^("[^"]*"|\'[^\']*\'|[A-Za-z0-9_.-]+)\s*=\s*(.+)$', s)
        if not m:
            raise ValueError("line %d: cannot parse: %s" % (n, s))
        keys = _toml_key(m.group(1))
        tgt = cur
        for k in keys[:-1]:
            tgt = tgt.setdefault(k, {})
        tgt[keys[-1]] = _toml_val(m.group(2))
    return data


# ---------------------------------------------------------------- v2.5 executable specs
# Layout (Farley four-layer model): tests/acceptance/specs/ (executable specs, locked at CP-C),
# tests/acceptance/dsl.py or dsl/ (DSL: public interface locked; assertion-step bodies flagged),
# tests/acceptance/drivers/ (protocol drivers, freely editable). Lock: tests/acceptance/spec-lock.json,
# its sha256 recorded in the CP-C Approval log row: 'approved speclock sha256:<12+ hex>'.
ACC_DIR = "tests/acceptance"
SPEC_DIR = ACC_DIR + "/specs"
LOCK_FILE = ACC_DIR + "/spec-lock.json"
ASSERT_PREFIXES = ("assert_", "then_", "expect_", "check_", "verify_")
REQ_TAG = re.compile(r"""\bmark\.req\(\s*(['"])([^'"]+)\1""")
REQ_ID = re.compile(r"\bREQ-\d+\b")
WARN_ONLY_UNTIL.update({c: "2.6.0" for c in (
    "spec-changed-without-approval", "dsl-interface-changed", "dsl-assertion-changed",
    "slice-without-spec", "spec-unknown-node", "req-without-spec", "speclock-not-approved")})


def _py_files(repo, rel_dir):
    out, base = [], os.path.join(repo, rel_dir)
    for d, dirs, files in os.walk(base):
        dirs[:] = sorted(x for x in dirs if not x.startswith((".", "__")))
        out += [posix(os.path.relpath(os.path.join(d, f), repo)) for f in sorted(files) if f.endswith(".py")]
    return out


def dsl_files(repo):
    one = ACC_DIR + "/dsl.py"
    return ([one] if os.path.isfile(os.path.join(repo, one)) else []) + _py_files(repo, ACC_DIR + "/dsl")


def acceptance_enabled(repo, state):
    """Opted in when PROJECT_STATE 'acceptance:' starts with executable-specs, or a spec lock exists."""
    v = str((state or {}).get("acceptance", "")).strip()
    return v.startswith("executable-specs") or os.path.isfile(os.path.join(repo, LOCK_FILE))


def _sha_text(t):
    import hashlib
    return hashlib.sha256(t.encode("utf-8")).hexdigest()


def dsl_symbols(path):
    """{qualified public name: (interface sha, body sha or None, is_assertion)} for a DSL file.
    Interface = signature (ast.unparse of args) + docstring; body = code without the docstring.
    Underscore names are private. Parse errors yield {'<parse-error>': ...} so they are flagged."""
    import ast
    src = open(path, encoding="utf-8", errors="replace").read().replace("\r\n", "\n")
    try:
        tree = ast.parse(src)
    except SyntaxError as e:
        return {"<parse-error>": (_sha_text(str(e)), None, False)}
    out = {}

    def fn(node, prefix):
        name = prefix + node.name
        doc = ast.get_docstring(node) or ""
        sig = "%s(%s)" % (node.name, ast.unparse(node.args))
        if node.returns is not None:
            sig += " -> " + ast.unparse(node.returns)
        body = node.body[1:] if doc and node.body and isinstance(node.body[0], ast.Expr) else node.body
        is_assert = node.name.startswith(ASSERT_PREFIXES)
        out[name] = (_sha_text(sig + "\n" + doc.strip()), _sha_text("\n".join(ast.unparse(b) for b in body)) if is_assert else None, is_assert)

    for node in tree.body:
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)) and not node.name.startswith("_"):
            fn(node, "")
        elif isinstance(node, ast.ClassDef) and not node.name.startswith("_"):
            out[node.name] = (_sha_text((ast.get_docstring(node) or "").strip()), None, False)
            for sub in node.body:
                if isinstance(sub, (ast.FunctionDef, ast.AsyncFunctionDef)) and (not sub.name.startswith("_") or sub.name == "__init__"):
                    fn(sub, node.name + ".")
    return out


def spec_snapshot(repo):
    """Current state of the locked layers: specs (file sha), dsl interface + assertion bodies."""
    snap = {"specs": {}, "dsl_interface": {}, "dsl_assertions": {}}
    for f in _py_files(repo, SPEC_DIR):
        snap["specs"][f] = file_sha(os.path.join(repo, f))
    for f in dsl_files(repo):
        for name, (isha, bsha, _) in dsl_symbols(os.path.join(repo, f)).items():
            key = "%s::%s" % (f, name)
            snap["dsl_interface"][key] = isha
            if bsha:
                snap["dsl_assertions"][key] = bsha
    return snap


def lock_text(snap, kit_version=None):
    import json
    data = {"comment": "eng-process executable-spec lock (eng-spec lock). Approve its sha256 at CP-C: "
                       "'| date | CP-C | <plan.md> | approved speclock sha256:<hex> |'. Do not edit by hand.",
            "kit_version": kit_version or KIT_VERSION}
    data.update(snap)
    return json.dumps(data, indent=2, sort_keys=True) + "\n"


def read_lock(repo):
    import json
    p = os.path.join(repo, LOCK_FILE)
    if not os.path.isfile(p):
        return None
    try:
        return json.load(open(p, encoding="utf-8"))
    except ValueError:
        return {}


def diff_snap(old, new):
    """{'specs': [...], 'dsl_interface': [...], 'dsl_assertions': [...]} changed/added/removed keys."""
    out = {}
    for k in ("specs", "dsl_interface", "dsl_assertions"):
        a, b = (old or {}).get(k, {}) or {}, new.get(k, {})
        ch = ["changed " + x for x in sorted(set(a) & set(b)) if a[x] != b[x]]
        ch += ["added " + x for x in sorted(set(b) - set(a))] + ["removed " + x for x in sorted(set(a) - set(b))]
        out[k] = ch
    return out


def speclock_approved(repo, rows):
    """(state, date): 'ok' when the latest 'speclock sha256:' Approval log row matches the lock file,
    'mismatch' when it does not, 'none' when no row records a speclock."""
    mine = [r for r in rows if re.search(r"speclock\s+sha256:[0-9a-f]{7,64}", r["decision"])
            and re.search(r"approved|accepted", r["decision"]) and not re.search(r"reject", r["decision"])]
    if not mine:
        return "none", ""
    last = max(mine, key=lambda r: r["date"])
    h = re.search(r"speclock\s+sha256:([0-9a-f]{7,64})", last["decision"]).group(1)
    p = os.path.join(repo, LOCK_FILE)
    if os.path.isfile(p) and file_sha(p).startswith(h):
        return "ok", last["date"]
    return "mismatch", last["date"]


def spec_req_tags(repo):
    """{req id: [spec file, ...]} from @pytest.mark.req("REQ-n") in tests/acceptance/specs."""
    out = {}
    for f in _py_files(repo, SPEC_DIR):
        for m in REQ_TAG.finditer(open(os.path.join(repo, f), encoding="utf-8", errors="replace").read()):
            out.setdefault(m.group(2), []).append(f)
    return out


def design_req_ids(body):
    sec = section(body, "Requirements (acceptance criteria)") or section(body, "Requirements") or ""
    return sorted(set(REQ_ID.findall(sec)), key=lambda x: int(x.split("-")[1]))


def spec_node_problem(repo, node):
    """None if 'path.py::test_name' (or 'path.py') exists, else a problem string."""
    path, _, fn = str(node).partition("::")
    path = posix(path.strip())
    full = os.path.join(repo, path)
    if not os.path.isfile(full):
        return "spec file does not exist: " + path
    name = fn.split("::")[-1].split("[")[0].strip()
    if name and not re.search(r"(?m)^\s*(async\s+)?def\s+%s\s*\(" % re.escape(name), open(full, encoding="utf-8", errors="replace").read()):
        return "spec %s has no test function '%s'" % (path, name)
    return None
