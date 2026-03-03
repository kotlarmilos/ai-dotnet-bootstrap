---
name: learn-from-pr
description: Analyzes a completed PR to extract lessons learned from agent behavior. Use after any PR with agent involvement. Identifies patterns to reinforce or fix, and generates actionable recommendations for instruction files, skills, and documentation.
---

# Learn From PR

Extracts lessons learned from a completed PR to improve repository documentation and agent capabilities.

## Inputs

| Input | Required | Source |
|-------|----------|--------|
| PR number | Yes | User provides (e.g., "PR #123") |

## Outputs

1. **Learning Analysis** — What happened, attempts, solution
2. **Fix Location Analysis** — Where was the fix vs where agents looked
3. **Failure Modes** — What went wrong and why
4. **Actionable Recommendations** — Specific changes to instruction files, skills, docs

## When to Use

- After agent failed to find the right fix
- After agent succeeded but took many attempts
- After agent succeeded quickly (to understand what worked)
- When asked "what can we learn from PR #XXXXX?"

## When NOT to Use

- Before PR is finalized (use `pr-finalize` first)
- For trivial PRs (typo fixes, simple changes)

---

## Workflow

### Step 1: Gather Data

```bash
# Get PR details
gh pr view XXXXX --json title,body,files,commits,comments,reviews,mergedAt,closedAt

# Get the diff
gh pr diff XXXXX

# Get PR comments for context
gh pr view XXXXX --json comments --jq '.comments[].body'
```

### Step 2: Analyze Fix Location

Map where code was actually changed:
- Which files were modified?
- Which project/module/layer?
- Was this a common location for this type of bug?

### Step 3: Identify Failure Modes

If the agent struggled, identify why:
- Wrong file/module targeted?
- Missing domain knowledge?
- Build/test command incorrect?
- Missing instruction coverage?

### Step 4: Generate Recommendations

Each recommendation should have:

| Field | Description |
|-------|-------------|
| **Category** | instruction-file, skill, code-comment, documentation |
| **Priority** | high, medium, low |
| **Location** | Which file to update |
| **Change** | Specific addition/modification |
| **Why** | How this prevents future failures |

### Step 5: Present Findings

```markdown
## Learning Analysis for PR #XXXXX

### What Happened
[Problem → Attempts → Solution]

### Fix Location
- **Actual fix:** `path/to/file.cs` (module X)
- **Agent looked at:** [files/modules the agent tried first]

### Failure Modes Identified
1. [Mode 1] — [Why it happened]
2. [Mode 2] — [Why it happened]

### Recommendations (prioritized)

| # | Priority | Category | Location | Change |
|---|----------|----------|----------|--------|
| 1 | High | instruction-file | `.github/instructions/X.md` | Add guidance about Y |
| 2 | Medium | skill | `.github/skills/Z/SKILL.md` | Add step for W |
```

## Completion Criteria

- [ ] Gathered PR diff and metadata
- [ ] Analyzed fix location
- [ ] Identified failure modes (if any)
- [ ] Generated at least one concrete recommendation
- [ ] Presented findings to user
