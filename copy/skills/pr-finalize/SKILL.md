---
name: pr-finalize
description: Finalizes any PR for merge by verifying title/description match implementation AND performing code review for best practices. Use when asked to "finalize PR", "check PR description", "review commit message", before merging any PR.
---

# PR Finalize

Ensures PR title and description accurately reflect the implementation, and performs a **code review** for best practices before merge.

**Standalone skill** — works on any PR in any repository.

## Two-Phase Workflow

1. **Title & Description Review** — Verify PR metadata matches implementation
2. **Code Review** — Review code for best practices and potential issues

---

## 🚨 CRITICAL RULES

### 1. NEVER Approve or Request Changes

**AI agents must NEVER use `--approve` or `--request-changes` flags.**

| Action | Allowed? | Why |
|--------|----------|-----|
| `gh pr review --approve` | ❌ **NEVER** | Approval is a human decision |
| `gh pr review --request-changes` | ❌ **NEVER** | Blocking PRs is a human decision |

### 2. NEVER Post Comments Directly

**This skill is ANALYSIS ONLY.** Never post comments using `gh` commands.

| Action | Allowed? | Why |
|--------|----------|-----|
| `gh pr review --comment` | ❌ **NEVER** | Use ai-summary-comment skill instead |
| `gh pr comment` | ❌ **NEVER** | Use ai-summary-comment skill instead |
| Analyze and report findings | ✅ **YES** | This is the skill's purpose |

---

## Phase 1: Title & Description

### Core Principle: Preserve Quality

**Review existing description BEFORE suggesting changes.** Many PR authors write excellent descriptions. Your job is to:

1. **Evaluate first** — Is the existing description good?
2. **Preserve quality** — Don't replace a thorough description with a generic template
3. **Enhance, don't replace** — Add missing elements without rewriting good content
4. **Only rewrite if needed** — When description is stale, inaccurate, or missing key information

### Usage

```bash
# Get current state
gh pr view XXXXX --json title,body
gh pr view XXXXX --json files --jq '.files[].path'
gh pr view XXXXX --json commits --jq '.commits[].messageHeadline'

# Review actual code changes
gh pr diff XXXXX
```

### Title Requirements

**The title becomes the commit message headline.** Make it searchable and informative.

| Requirement | Good | Bad |
|-------------|------|-----|
| Describes behavior | `Fix null reference in UserService.GetById()` | `Fix #123` |
| Captures the "what" | `Add retry logic to HTTP client` | `Fix flaky tests` |
| Scoped appropriately | `[API] Add rate limiting to endpoints` | `Changes` |

### Title Formula

```
[Scope] Component: What changed
```

### Description Requirements

PR description should:
1. Explain what changed and why
2. Link to the issue being fixed
3. Note any breaking changes
4. Match the actual implementation

### Evaluation Workflow

1. **Review existing description quality** — Structure, technical depth, accuracy
2. **Compare to what's needed** — Is it better than a template?
3. **Produce output** — Recommended title, assessment, specific additions needed

## Phase 2: Code Review

After verifying title/description, perform a code review:

### Review Focus Areas

1. **Code quality** — Clean code, good naming, appropriate abstractions
2. **Error handling** — Null checks, exception handling, boundary conditions
3. **Performance** — Unnecessary allocations, blocking calls
4. **Breaking changes** — API changes, behavior changes
5. **Test coverage** — Are changes adequately tested?

### Output Format

```markdown
## PR #XXXXX Finalization Review

### Title: [Good / Needs Update]
**Current:** "Existing title"
**Recommended:** "Improved title" (if needed)

### Description: [Good / Needs Update / Needs Rewrite]
**Assessment:** [Quality evaluation]

### Code Review Findings

#### 🔴 Critical Issues
- **[Issue]** in `path/to/file` — [Problem + Recommendation]

#### 🟡 Suggestions
- [Suggestion 1]

#### ✅ Looks Good
- [Positive observation]
```
