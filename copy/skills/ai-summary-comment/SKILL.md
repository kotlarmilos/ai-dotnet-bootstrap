---
name: ai-summary-comment
description: Posts or updates automated progress comments on GitHub PRs. Creates single aggregated comment with collapsible sections. Use after completing any agent phase.
---

# PR Comment Skill

Posts automated progress comments to GitHub Pull Requests during agent workflows. Creates a single unified comment with collapsible sections.

**⚠️ Self-Contained Rule**: All content in PR comments must be self-contained. Never reference local files — GitHub users cannot access your local filesystem.

## Key Features

- **Single Unified Comment** — ONE comment per PR containing ALL sections
- **Section-Based Updates** — Each update modifies only its section, preserving others
- **Duplicate Prevention** — Finds existing `<!-- AI Summary -->` comment and updates it

## Comment Architecture

```markdown
<!-- AI Summary -->

## 🤖 AI Summary

<!-- SECTION:PR-REVIEW -->
... PR review phases ...
<!-- /SECTION:PR-REVIEW -->

<!-- SECTION:TRY-FIX -->
... try-fix attempts ...
<!-- /SECTION:TRY-FIX -->

<!-- SECTION:TESTS -->
... test results ...
<!-- /SECTION:TESTS -->
```

## Usage

### Post or Update a Section

```bash
# Find existing AI Summary comment
COMMENT_ID=$(gh pr view XXXXX --repo OWNER/REPO --json comments --jq '.comments[] | select(.body | contains("<!-- AI Summary -->")) | .databaseId')

# If comment exists, update it
if [ -n "$COMMENT_ID" ]; then
  # Get current body, replace section, update
  gh api repos/OWNER/REPO/issues/comments/$COMMENT_ID --method PATCH -f body="$NEW_BODY"
else
  # Create new comment
  gh pr comment XXXXX --repo OWNER/REPO --body "$NEW_BODY"
fi
```

### Section Format

Each section should use collapsible details:

```markdown
<!-- SECTION:PR-REVIEW -->
<details>
<summary><strong>📋 PR Review</strong> — Phase 1: Pre-Flight ✅ | Phase 2: Gate ✅</summary>

### Phase 1: Pre-Flight
- Issue: #XXXXX
- Platform: [affected platforms]
- Root cause: [brief description]

### Phase 2: Gate
- Tests exist: Yes/No
- Tests catch bug: Yes/No

</details>
<!-- /SECTION:PR-REVIEW -->
```

## Rules

1. **Self-contained** — Never reference local files or paths
2. **Idempotent** — Running twice produces same result
3. **Section isolation** — Updating one section never affects others
4. **Collapsible** — Use `<details>` to keep comments compact
5. **No approvals** — Never use `--approve` or `--request-changes`
