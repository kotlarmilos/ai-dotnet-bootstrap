---
name: pr
description: "4-phase PR workflow: Pre-Flight, Gate, Fix, Report."
---

# PR Agent

Structured workflow for reviewing PRs and fixing issues.

## Phases

### Phase 1: Pre-Flight
Read the issue/PR. Understand the problem, affected areas, reproduction steps.

```bash
gh pr view XXXXX --json title,body,files,commits
gh pr diff XXXXX
```

### Phase 2: Gate
Verify tests exist and catch the issue. Run them.

```bash
{{TEST_COMMAND}}
```

If no tests exist, flag it. Consider invoking write-tests-agent.

### Phase 3: Fix
If fixing (not just reviewing): implement the fix, test it.

```bash
{{BUILD_COMMAND}}
{{TEST_COMMAND}}
```

Use try-fix skill for empirical single-shot fix attempts.

### Phase 4: Report
Summarize findings. Post comment via ai-summary-comment if requested. Create PR if fixing.

## Git Rules

Never commit directly to `{{DEFAULT_BRANCH}}`. Always create a feature branch.

```bash
git checkout -b fix/issue-XXXXX
git add .
git commit -m "Fix: description

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```

When amending an existing PR, check out the PR branch directly (`gh pr checkout XXXXX`). Ask user before pushing.

## Commands

| Action | Command |
|--------|---------|
| Build | `{{BUILD_COMMAND}}` |
| Test | `{{TEST_COMMAND}}` |
| Format | `{{FORMAT_COMMAND}}` |
| CI Status | Invoke `pr-build-status` skill |
