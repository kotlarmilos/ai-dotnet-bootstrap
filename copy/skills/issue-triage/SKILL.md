---
name: issue-triage
description: Queries and triages open GitHub issues that need attention. Helps identify issues needing milestones, labels, or investigation.
---

# Issue Triage Skill

Helps triage open GitHub issues by:
1. Loading a batch of issues that need attention
2. Presenting issues ONE AT A TIME for triage decisions
3. Suggesting milestones/labels based on issue characteristics
4. Tracking progress through a triage session

## Prerequisites

GitHub CLI (`gh`) must be installed and authenticated.

## When to Use

- "Find issues to triage"
- "Let's triage issues"
- "Grab me 10 issues to triage"
- "Show me issues without milestones"

## Triage Workflow

### Step 1: Query Issues

```bash
# Find issues without milestones
gh issue list --repo OWNER/REPO --search "no:milestone -label:needs-info -label:needs-repro" --limit 50 --json number,title,labels,createdAt,author,comments,url
```

Adapt the exclusion labels to your repo's conventions (e.g., `needs-info`, `waiting-for-author`, etc.).

### Step 2: Present ONE Issue at a Time

```markdown
## Issue #XXXXX

**[Title]**

🔗 [URL]

| Field | Value |
|-------|-------|
| **Author** | username |
| **Labels** | labels |
| **Comments** | count |
| **Age** | days |

**My Suggestion**: `Milestone` — Reason

---

What would you like to do with this issue?
```

### Step 3: Wait for User Decision

Wait for user to say:
- A milestone name (e.g., "Backlog", "v3.0")
- "yes" to accept suggestion
- "skip" or "next" to move on without changes
- Specific instructions (e.g., "add regression label and assign to v3.0")

### Step 4: Apply Decision

```bash
# Set milestone
gh issue edit ISSUE_NUMBER --repo OWNER/REPO --milestone "MILESTONE_NAME"

# Add labels
gh issue edit ISSUE_NUMBER --repo OWNER/REPO --add-label "LABEL"
```

### Step 5: Move to Next Issue

After user decision, automatically present the NEXT issue.

### Step 6: Auto-Reload When Empty

When batch is exhausted, automatically query more. Do NOT ask "Load more?"

## Milestone Suggestion Guidelines

| Condition | Suggestion | Reason |
|-----------|------------|--------|
| Has linked PR with milestone | PR's milestone | Already being worked on |
| Has `regression` label | Current release milestone | Regressions are high priority |
| Has open linked PR | Current milestone | Active development |
| Default | Backlog | Needs prioritization |

## Label Quick Reference

Adapt these to your repo's label conventions:

| Category | Examples |
|----------|----------|
| **Priority** | `p/0` (critical), `p/1` (high), `p/2` (medium) |
| **Type** | `bug`, `enhancement`, `question` |
| **Status** | `needs-info`, `needs-repro`, `ready` |
| **Area** | `area-api`, `area-ui`, `area-docs` |
