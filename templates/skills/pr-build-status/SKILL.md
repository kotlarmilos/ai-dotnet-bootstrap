---
name: pr-build-status
description: "Retrieve CI build information for GitHub Pull Requests, including build status, failed jobs, and error logs."
---

# PR Build Status Skill

Retrieves CI build information for PRs to help diagnose failures.

## When to Use

- "Check build for PR #XXXXX"
- "Why did PR build fail?"
- "Get build status"

## Workflow

### For GitHub Actions CI

```bash
# Get workflow runs for the PR's branch
gh run list --repo OWNER/REPO --branch PR_BRANCH --limit 5

# Get failed jobs
gh run view RUN_ID --repo OWNER/REPO --json jobs --jq '.jobs[] | select(.conclusion == "failure") | {name, conclusion}'

# Get job logs
gh run view RUN_ID --repo OWNER/REPO --log-failed
```

### For Azure DevOps CI

```bash
# Get build info (requires AzDO PAT or service connection)
# Adapt these to your organization's AzDO setup
curl -s "https://dev.azure.com/{{ORG}}/{{PROJECT}}/_apis/build/builds?branchName=refs/pull/XXXXX/merge&api-version=7.0" \
  -H "Authorization: Basic $(echo -n :$AZDO_PAT | base64)"
```

## Output Format

```markdown
## Build Status for PR #XXXXX

| Pipeline | Status | Duration |
|----------|--------|----------|
| CI Build | ✅ Pass / ❌ Fail | 12m |
| Tests | ✅ Pass / ❌ Fail | 8m |

### Failed Jobs
- **Job Name**: [Error summary]
  ```
  [Key error lines from logs]
  ```

### Diagnosis
[Root cause analysis of failures]

### Recommended Actions
- [Action 1]
- [Action 2]
```

## CI System: {{CI_SYSTEM}}
## Pipeline Names: {{PIPELINE_NAMES}}
