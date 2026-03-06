---
name: repo-health-check
description: "Daily repo health orchestrator: collects data on issues, PRs, and CI pipelines, diffs against previous run, updates a pinned dashboard issue, and dispatches investigators for critical findings."
tools:
  - github-mcp
  - bash
safe-outputs:
  create-issue: 1
  update-issue: 1
  add-comment: 1
  dispatch-workflow: {{MAX_INVESTIGATE_DISPATCHES}}
triggers:
  - schedule: "{{HEALTH_CHECK_SCHEDULE}}"
  - workflow_dispatch
cache-memory: true
---

# Repo Health Check — Orchestrator

Collect health data for **{{REPO_OWNER}}/{{REPO_NAME}}**, diff against the previous run, update the dashboard issue, and dispatch investigators for critical findings.

## Configuration

| Setting | Value |
|---------|-------|
| Repository | `{{REPO_OWNER}}/{{REPO_NAME}}` |
| CI System | `{{CI_SYSTEM}}` |
| GitHub Actions Workflows | `{{GH_ACTIONS_WORKFLOWS}}` |
| Known Baseline | `{{KNOWN_BASELINE_PATH}}` |
| Priority Labels | `{{ISSUE_PRIORITY_LABELS}}` |
| Review Labels | `{{PR_REVIEW_REQUIRED_LABELS}}` |
| Area Labels | `{{TEAM_AREAS}}` |
| Investigate Workflow | `{{INVESTIGATE_WORKFLOW}}` |
| Max Dispatches | `{{MAX_INVESTIGATE_DISPATCHES}}` |
{{#if AZDO}}
| AzDO Org | `{{AZDO_ORG}}` |
| AzDO Project | `{{AZDO_PROJECT}}` |
| AzDO Pipelines | `{{AZDO_PIPELINES}}` |
{{/if}}

---

## Step 1 — Data Collection

Collect all health data using `gh` CLI and GitHub MCP. Store raw results for analysis.

### Issues

**I1. Open issues by priority/severity label**

```bash
# Count and age distribution by priority label
for label in {{ISSUE_PRIORITY_LABELS}}; do
  echo "=== $label ==="
  gh issue list --repo {{REPO_OWNER}}/{{REPO_NAME}} \
    --label "$label" --state open \
    --json number,title,createdAt,assignees,labels,updatedAt \
    --limit 100
done
```

**I2. Issue velocity — opened vs closed in last 24h**

```bash
# Opened in last 24h
gh issue list --repo {{REPO_OWNER}}/{{REPO_NAME}} \
  --state all --json number,title,state,createdAt \
  --limit 200 | jq '[.[] | select(.createdAt > (now - 86400 | todate))]'

# Closed in last 24h
gh issue list --repo {{REPO_OWNER}}/{{REPO_NAME}} \
  --state closed --json number,title,closedAt \
  --limit 200 | jq '[.[] | select(.closedAt > (now - 86400 | todate))]'
```

**I3. Issues without triage (no milestone, no area label)**

```bash
gh issue list --repo {{REPO_OWNER}}/{{REPO_NAME}} \
  --state open --search "no:milestone" \
  --json number,title,labels,createdAt,author \
  --limit 100
# Then filter: exclude issues that already have an area label from {{TEAM_AREAS}}
```

**I4. Needs-info/needs-repro with no response > 14 days**

```bash
gh issue list --repo {{REPO_OWNER}}/{{REPO_NAME}} \
  --state open --label "needs-info,needs-repro,needs-more-info,needs-author-action" \
  --json number,title,updatedAt,comments \
  --limit 100
# Filter: updatedAt older than 14 days
```

**I5. Recent activity on old items (potential escalations)**

```bash
gh issue list --repo {{REPO_OWNER}}/{{REPO_NAME}} \
  --state open --json number,title,createdAt,updatedAt,comments \
  --limit 200
# Filter: createdAt > 90 days ago AND updatedAt < 3 days ago — old issue with new activity
```

### Pull Requests

**P1. Open PRs — count, age, review status**

```bash
gh pr list --repo {{REPO_OWNER}}/{{REPO_NAME}} \
  --state open \
  --json number,title,createdAt,author,reviewDecision,reviewRequests,isDraft,labels \
  --limit 200
```

**P2. PRs without reviewers assigned**

```bash
gh pr list --repo {{REPO_OWNER}}/{{REPO_NAME}} \
  --state open \
  --json number,title,createdAt,reviewRequests,reviewDecision \
  --limit 200
# Filter: reviewRequests is empty AND reviewDecision is not APPROVED
```

**P3. PRs with failing CI**

```bash
gh pr list --repo {{REPO_OWNER}}/{{REPO_NAME}} \
  --state open \
  --json number,title,statusCheckRollup \
  --limit 200
# Filter: statusCheckRollup contains FAILURE or ERROR
```

**P4. PRs waiting on author > 7 days**

```bash
gh pr list --repo {{REPO_OWNER}}/{{REPO_NAME}} \
  --state open --label "{{PR_REVIEW_REQUIRED_LABELS}}" \
  --json number,title,updatedAt,author,labels \
  --limit 100
# Filter: updatedAt > 7 days ago
```

**P5. Stale PRs (no activity > 30 days)**

```bash
gh pr list --repo {{REPO_OWNER}}/{{REPO_NAME}} \
  --state open \
  --json number,title,updatedAt,author \
  --limit 200
# Filter: updatedAt > 30 days ago
```

**P6. PRs merged in last 24h**

```bash
gh pr list --repo {{REPO_OWNER}}/{{REPO_NAME}} \
  --state merged \
  --json number,title,mergedAt \
  --limit 100 | jq '[.[] | select(.mergedAt > (now - 86400 | todate))]'
```

### Pipelines / CI

**C1. Recent workflow run success/failure rate**

```bash
for workflow in {{GH_ACTIONS_WORKFLOWS}}; do
  echo "=== $workflow ==="
  gh run list --repo {{REPO_OWNER}}/{{REPO_NAME}} \
    --workflow "$workflow" \
    --json status,conclusion,createdAt,event \
    --limit 30
done
# Calculate success rate from last run until now (or last 7 days fallback)
```

**C2. Currently failing workflows on default branch**

```bash
for workflow in {{GH_ACTIONS_WORKFLOWS}}; do
  gh run list --repo {{REPO_OWNER}}/{{REPO_NAME}} \
    --workflow "$workflow" --branch main \
    --json conclusion,createdAt,url \
    --limit 5
done
# Check if latest run on default branch has conclusion=failure
```

**C3. Flaky tests (pass/fail alternation in last 10 runs)**

```bash
for workflow in {{GH_ACTIONS_WORKFLOWS}}; do
  gh run list --repo {{REPO_OWNER}}/{{REPO_NAME}} \
    --workflow "$workflow" --branch main \
    --json conclusion \
    --limit 10
done
# Detect alternating success/failure pattern — 3+ alternations = flaky
```

**C4. Average CI duration trend**

```bash
for workflow in {{GH_ACTIONS_WORKFLOWS}}; do
  gh run list --repo {{REPO_OWNER}}/{{REPO_NAME}} \
    --workflow "$workflow" --branch main \
    --json createdAt,updatedAt \
    --limit 20
done
# Calculate average duration and compare recent (5) vs older (5)
```

{{#if AZDO}}
### Azure DevOps Pipelines

**A1. Pipeline status — last run result**

```bash
for pipeline in {{AZDO_PIPELINES}}; do
  curl -s -u ":$AZDO_PAT" \
    "https://dev.azure.com/{{AZDO_ORG}}/{{AZDO_PROJECT}}/_apis/build/builds?definitions=$pipeline&\$top=1&api-version=7.0" \
    | jq '.value[0] | {id, buildNumber, status, result, queueTime, finishTime}'
done
```

**A2. Pipeline failure rate (last 7 days)**

```bash
SINCE=$(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-7d +%Y-%m-%dT%H:%M:%SZ)
for pipeline in {{AZDO_PIPELINES}}; do
  curl -s -u ":$AZDO_PAT" \
    "https://dev.azure.com/{{AZDO_ORG}}/{{AZDO_PROJECT}}/_apis/build/builds?definitions=$pipeline&minTime=$SINCE&api-version=7.0" \
    | jq '[.value[] | .result] | group_by(.) | map({result: .[0], count: length})'
done
```

**A3. Queue times**

```bash
for pipeline in {{AZDO_PIPELINES}}; do
  curl -s -u ":$AZDO_PAT" \
    "https://dev.azure.com/{{AZDO_ORG}}/{{AZDO_PROJECT}}/_apis/build/builds?definitions=$pipeline&\$top=10&api-version=7.0" \
    | jq '[.value[] | {queueTime, startTime} | {wait: ((.startTime | fromdateiso8601) - (.queueTime | fromdateiso8601))}] | {avg_wait_seconds: (map(.wait) | add / length)}'
done
```
{{/if}}

---

## Step 2 — Fingerprint & Diff

Load previous findings from cache-memory. Generate deterministic fingerprints for current findings and classify each.

### Fingerprint Format

Each finding gets an ID: `{CHECK_ID}-{hash}` where hash is derived from the key attributes.

| Category | Fingerprint Components |
|----------|-----------------------|
| Issue finding | Check ID + issue numbers involved |
| PR finding | Check ID + PR numbers involved |
| Pipeline finding | Check ID + workflow name + failure type |

### Classification

```
For each current finding:
  fingerprint = generate_fingerprint(finding)
  if fingerprint in baseline_file:
    status = "📋 BASELINED"
  elif fingerprint in previous_run:
    days = (today - previous_run[fingerprint].first_seen).days
    status = "📌 EXISTING (Day {days})"
  else:
    status = "🆕 NEW"

For each previous finding NOT in current findings:
  status = "✅ RESOLVED"
  resolved_date = today
```

### Load Baseline

```bash
# Read baseline file if it exists
gh api repos/{{REPO_OWNER}}/{{REPO_NAME}}/contents/{{KNOWN_BASELINE_PATH}} \
  --jq '.content' | base64 -d 2>/dev/null || echo "No baseline file"
```

### Save to Cache-Memory

Store the full findings list with fingerprints, statuses, and first-seen dates for the next run.

---

## Step 3 — Analysis

### Executive Summary

Write 1–2 sentences covering:
- Overall health status (Healthy / Warning / Critical)
- Most important change since last run
- Key trend direction

### Severity Classification

| Severity | Criteria |
|----------|----------|
| 🔴 Critical | CI failing on default branch (C2), P1/Critical issues without assignee (I1), untriaged security issues (I3) |
| 🟡 Warning | Stale PRs > 5 (P5), issue backlog growing (I2 negative velocity), flaky tests (C3), CI slowing > 20% (C4) |
| ℹ️ Info | Normal velocity, resolved items, stable metrics |

### Correlations

Look for connections between findings:
- CI failures ↔ stale PRs (PRs may be blocked by CI)
- Rising untriaged issues ↔ missing area labels (triage process gap)
- Slow CI ↔ large PR count (resource contention)

---

## Step 4 — Dashboard Output

### Find or Create Dashboard Issue

```bash
# Find existing dashboard issue
ISSUE=$(gh issue list --repo {{REPO_OWNER}}/{{REPO_NAME}} \
  --label "repo-health" --state open \
  --json number --jq '.[0].number')

if [ -z "$ISSUE" ]; then
  # Create new dashboard issue
  ISSUE=$(gh issue create --repo {{REPO_OWNER}}/{{REPO_NAME}} \
    --title "🏥 Repo Health Dashboard" \
    --label "repo-health" \
    --body "$DASHBOARD_BODY")
  # Pin the issue
  gh issue pin "$ISSUE" --repo {{REPO_OWNER}}/{{REPO_NAME}}
fi
```

### Update Issue Body

Replace the entire issue body with the current state using the dashboard format from the reference doc. Include:

1. **Header** — Last updated timestamp, overall status emoji and counts
2. **Summary** — Executive summary (1-2 sentences)
3. **Findings tables** — Critical, Warning, Recently Resolved, Baselined
4. **Trends (7-day)** — Key metrics with directional arrows
5. **Footer** — Link to workflow run and baseline file

### Post Daily Comment

```bash
gh issue comment "$ISSUE" --repo {{REPO_OWNER}}/{{REPO_NAME}} \
  --body "$DELTA_SUMMARY"
```

The delta comment should include:
- Number of new/resolved/existing findings
- Any severity changes (warning → critical, etc.)
- Key metric changes with direction

---

## Step 5 — Triage Dispatch

For findings classified as 🔴 Critical or 🟡 Warning (high confidence):

```bash
# Budget: max {{MAX_INVESTIGATE_DISPATCHES}} dispatches
DISPATCHED=0

for finding in critical_and_high_findings; do
  if [ $DISPATCHED -ge {{MAX_INVESTIGATE_DISPATCHES}} ]; then
    break
  fi

  gh workflow run {{INVESTIGATE_WORKFLOW}}.lock.yml \
    --repo {{REPO_OWNER}}/{{REPO_NAME}} \
    -f finding_id="$FINDING_ID" \
    -f category="$CATEGORY" \
    -f severity="$SEVERITY" \
    -f summary="$SUMMARY" \
    -f health_issue_number="$ISSUE"

  DISPATCHED=$((DISPATCHED + 1))
done
```

Prioritize dispatches:
1. 🔴 Critical findings — always dispatch
2. 🟡 Warning findings — dispatch if budget remains, prefer NEW over EXISTING

---

## Rules

1. **Idempotent** — Running twice in the same state produces the same dashboard
2. **Budget-aware** — Never exceed safe-output limits
3. **Baseline-respecting** — Never flag baselined items as NEW
4. **Cache-dependent** — First run classifies everything as NEW (no previous data)
5. **Non-destructive** — Only creates/updates the dashboard issue, never modifies source issues or PRs
