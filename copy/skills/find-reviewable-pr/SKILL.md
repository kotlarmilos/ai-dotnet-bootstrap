---
name: find-reviewable-pr
description: Finds open PRs that are good candidates for review, prioritizing by milestone, priority labels, and community status.
---

# Find Reviewable PR

Searches your repository for open pull requests that are good candidates for review, prioritized by importance.

## When to Use

- "Find a PR to review"
- "Find PRs that need review"
- "Show me milestoned PRs"
- "What community PRs are open?"

## Priority Categories (in order)

1. **Priority (P/0)** — Critical priority PRs needing immediate attention
2. **Approved (Not Merged)** — PRs with human approval awaiting merge
3. **Milestoned** — PRs assigned to current milestones
4. **Community** — External contributions needing review
5. **Recent** — PRs created in last 2 weeks needing first review

## Quick Start

```bash
# Find all reviewable PRs using GitHub CLI
# Priority PRs
gh pr list --repo OWNER/REPO --search "label:p/0" --json number,title,author,labels,createdAt,url

# Milestoned PRs
gh pr list --repo OWNER/REPO --search "milestone:*" --json number,title,author,labels,milestone,createdAt,url

# Community PRs (not from org members)
gh pr list --repo OWNER/REPO --json number,title,author,labels,createdAt,url | jq '[.[] | select(.author.login | test("^(?!org-member1|org-member2).*$"))]'

# Recent PRs needing review
gh pr list --repo OWNER/REPO --search "created:>=$(date -v-14d +%Y-%m-%d) review:none" --json number,title,author,createdAt,url
```

## Presentation Format

Present results grouped by category:

```markdown
### 🔴 Priority (P/0)
| PR | Title | Author | Age |
|----|-------|--------|-----|

### 📅 Milestoned
| PR | Title | Author | Milestone | Age |
|----|-------|--------|-----------|-----|

### ✨ Community
| PR | Title | Author | Age |
|----|-------|--------|-----|

### 🕐 Recent (Needs Review)
| PR | Title | Author | Age |
|----|-------|--------|-----|
```

## Complexity Levels

| Complexity | Criteria |
|------------|----------|
| **Easy** | ≤5 files, ≤200 additions |
| **Medium** | 6-15 files, or 200-500 additions |
| **Complex** | >15 files, or >500 additions |

## Tips

- **P/0 PRs** should always be reviewed first
- **Milestoned PRs** have deadlines
- **Community PRs** may need more guidance and thorough review
- **Recent PRs** — quick turnaround keeps contributors engaged
