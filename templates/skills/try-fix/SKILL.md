---
name: try-fix
description: "Attempts ONE alternative fix for a bug, tests it empirically, and reports results. Explores a DIFFERENT approach from existing fixes."
---

# Try Fix Skill

Attempts ONE fix for a given problem. Receives context, tries a single approach, tests it, and reports what happened.

## Core Principles

1. **Always run** — Never question whether to run
2. **Single-shot** — Each invocation = ONE fix idea, tested, reported
3. **Alternative-focused** — Always propose something DIFFERENT from existing fixes
4. **Empirical** — Actually implement and test, don't just theorize

## Inputs

All inputs provided by the invoker:

| Input | Required | Description |
|-------|----------|-------------|
| Problem description | Yes | What's broken and why |
| Test command | Yes | How to verify the fix |
| Target files | Yes | Which files to modify |
| Prior attempts | No | What's already been tried |
| Hints | No | Suggestions for approach |

## Workflow

### Step 1: Establish Baseline

```bash
# Ensure clean state
git stash

# Run tests to confirm failure
{{TEST_COMMAND}}
```

### Step 2: Analyze & Plan

1. Read the target files
2. Review prior attempts (if any) — do something DIFFERENT
3. Plan a single focused fix

### Step 3: Implement Fix

Make minimal changes to the target files.

### Step 4: Test

```bash
# Build
{{BUILD_COMMAND}}

# Run tests
{{TEST_COMMAND}}
```

### Step 5: Report

```markdown
## Try-Fix Attempt #N

### Approach
[What I tried and why]

### Changes Made
- `path/to/file.cs`: [What changed]

### Test Results
- Build: ✅ Pass / ❌ Fail
- Tests: ✅ Pass / ❌ Fail
- [Test output excerpt]

### Verdict
✅ FIX WORKS / ❌ FIX FAILED — [reason]
```

### Step 6: Clean Up

```bash
# Revert changes (always clean up)
git checkout -- .
git stash pop
```

## Rules

- **Sequential only** — Never run multiple try-fix attempts in parallel
- **Max 5 attempts** per session
- **Always revert** — Leave repo clean after each attempt
- **Report honestly** — If the fix didn't work, say so
