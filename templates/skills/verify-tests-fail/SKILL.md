---
name: verify-tests-fail-without-fix
description: "Verifies that tests catch the bug by confirming they fail without the fix and pass with it."
---

# Verify Tests Fail Without Fix

Proves that tests actually catch the bug by verifying two conditions:
1. Tests **FAIL** without the fix (bug is reproduced)
2. Tests **PASS** with the fix (bug is fixed)

## When to Use

- After writing tests for a bug fix
- Before marking a PR as ready for review
- When asked to "verify tests catch the bug"

## Two Modes

### Mode 1: Verify Failure Only (Test Creation)

Use when you just wrote tests and want to confirm they catch the bug.

```bash
# 1. Stash the fix (keep only the tests)
git stash push -m "fix" -- {{FIX_FILES}}

# 2. Build
{{BUILD_COMMAND}}

# 3. Run tests — they should FAIL
{{TEST_COMMAND}}
# Expected: FAIL (proves tests catch the bug)

# 4. Restore the fix
git stash pop
```

### Mode 2: Full Verification (Test + Fix)

Use when you have both tests and fix and want to verify the complete cycle.

```bash
# Step 1: Verify tests FAIL without fix
git stash push -m "fix" -- {{FIX_FILES}}
{{BUILD_COMMAND}}
{{TEST_COMMAND}}
# Expected: FAIL

# Step 2: Restore fix and verify tests PASS
git stash pop
{{BUILD_COMMAND}}
{{TEST_COMMAND}}
# Expected: PASS
```

## Output Format

```markdown
## Test Verification Results

### Without Fix
- Build: ✅ / ❌
- Tests: ❌ FAIL (expected — tests catch the bug)
- Failed tests: [list]

### With Fix
- Build: ✅ / ❌
- Tests: ✅ PASS (expected — fix works)

### Verdict
✅ Tests properly catch the bug and pass with the fix
OR
❌ Tests do NOT catch the bug — [reason]
```

## Rules

- Always restore the working state after verification
- If tests pass without the fix, they DON'T catch the bug — report this
- If tests fail with the fix, the fix is incomplete — report this
