---
id: {{ID}}
type: plan
phase: plan
status: draft            # input (pre-draft from an earlier phase) | draft | in-review | approved | in-progress | done | superseded
owner_agent: {{AGENT}}
date: {{DATE}}
links: []
plan_review: none        # medium/large: path to the mandatory Codex plan review (.eng/bin/eng-new plan-review <slug>)
---
# Plan: {{TITLE}}

## Overview
<what and why, 2-3 lines; link design doc and research>

## Current State Analysis
<what exists now, with file:line refs from research>

## Desired End State
<how we know we're done; how to verify it>

### Key Discoveries
- <finding> (`file:line`)

## What We're NOT Doing
- <explicit out-of-scope item>

## Implementation Approach
<strategy; program design: key types/signatures, call path, file-tree diff>

## Phase 1: <vertical slice name — thin, end-to-end, demoable>
Slice card: <thoughts/shared/slices/...md>

### Changes Required
#### 1. <component / file>
**File**: `path/to/file.ext`
**Changes**: <summary>

### Success Criteria
#### Automated Verification
- [ ] <exact command>, e.g. `make test` passes
#### Manual Verification
- [ ] <what Rob checks by hand>

**Stop:** after automated checks pass, pause for Rob's manual verification before Phase 2.

---

## Phase 2: <next vertical slice>
(same structure)

## Demo script
<!-- 3-6 steps Rob can follow to see the result working (commands, URLs, clicks, expected output). Short. -->
1. 

## Testing Strategy
- Unit:
- Integration:
- Manual steps:

## Risks, Rollback, Migration
<partial deploy, rollback, flags, data migration>

## References
- Design: <path>
- Research: <path>
- ADRs: <paths>
