---
name: setup-repo-health-check
description: "Interactive skill that deploys the 3-tier repo health check system to a target repository. Analyzes the repo, creates a known baseline, configures and compiles agentic workflows, and guides secrets setup. Use when asked to set up health monitoring, repo health checks, or pipeline observability."
---

# Setup Repo Health Check

Interactive skill that deploys the repo health check system to a target repository. This creates three agentic workflows (orchestrator, investigator, groomer) that maintain a pinned dashboard issue tracking repo health.

**Requires**: `gh-aw` (GitHub Agentic Workflows CLI extension)

Read `references/repo-health-check.md` for the full architecture reference.

---

## Phase 1 — Repo Discovery

### 1.1 Identify the Target Repo

Determine the target repo from context or ask:

```bash
# If in a git repo
cd TARGET_REPO_PATH
REPO_OWNER=$(gh repo view --json owner --jq '.owner.login')
REPO_NAME=$(gh repo view --json name --jq '.name')
echo "Target: $REPO_OWNER/$REPO_NAME"
```

### 1.2 Detect CI Systems

**GitHub Actions:**

```bash
# List workflow files
ls .github/workflows/*.yml 2>/dev/null | while read f; do
  name=$(basename "$f")
  # Check if it's a CI workflow (has push/PR triggers, not a bot workflow)
  if grep -qE "push:|pull_request" "$f"; then
    echo "GH_ACTIONS: $name"
  fi
done
```

**Azure Pipelines:**

```bash
# Check for Azure Pipelines config
ls azure-pipelines.yml 2>/dev/null && echo "AZDO: azure-pipelines.yml"
find eng/pipelines build -name "*.yml" 2>/dev/null | while read f; do
  if grep -qE "trigger|pr:" "$f"; then
    echo "AZDO: $f"
  fi
done

# Check for YAML pipeline references
grep -r "pipeline:" azure-pipelines.yml eng/pipelines/*.yml build/*.yml 2>/dev/null | head -10
```

If AzDO detected, ask the user:
- What is the AzDO org? (e.g., `dnceng`)
- What is the AzDO project? (e.g., `internal`)
- Which pipelines should be monitored? (list detected names)

Set `CI_SYSTEM` to `github-actions`, `azure-pipelines`, or `both`.

### 1.3 Detect Issue/PR Patterns

**Priority labels:**

```bash
# Get all labels, look for priority/severity patterns
gh label list --repo $REPO_OWNER/$REPO_NAME --json name --limit 200 \
  | jq -r '.[].name' | grep -iE "priority|severity|critical|urgent|P[0-4]|bug" | sort
```

**Triage patterns:**

```bash
# Check milestone usage
gh issue list --repo $REPO_OWNER/$REPO_NAME --state open --json milestone --limit 100 \
  | jq '[.[] | select(.milestone != null)] | length' 

# Check for area/team labels
gh label list --repo $REPO_OWNER/$REPO_NAME --json name --limit 200 \
  | jq -r '.[].name' | grep -iE "area-|team-|component-" | sort
```

**PR review workflow:**

```bash
# Check for CODEOWNERS
test -f .github/CODEOWNERS && echo "Has CODEOWNERS" || test -f CODEOWNERS && echo "Has CODEOWNERS (root)"

# Check for review-related labels
gh label list --repo $REPO_OWNER/$REPO_NAME --json name --limit 200 \
  | jq -r '.[].name' | grep -iE "review|waiting|needs-author|needs-review" | sort
```

### 1.4 Present Discovery Summary

Show the user what was detected and ask for confirmation:

```markdown
## Repo Health Check — Discovery Summary

| Property | Detected |
|----------|----------|
| Repository | OWNER/REPO |
| CI System | github-actions / azure-pipelines / both |
| GH Actions Workflows | ci.yml, test.yml, ... |
| AzDO Org/Project | org/project (if applicable) |
| AzDO Pipelines | pipeline1, pipeline2 (if applicable) |
| Priority Labels | Priority:1, Priority:2, bug, ... |
| Review Labels | needs-review, waiting-on-author, ... |
| Area Labels | area-System.Net, area-Interop, ... |
| CODEOWNERS | Yes / No |

Does this look correct? (You can adjust any values before proceeding)
```

**Wait for user confirmation before proceeding.**

---

## Phase 2 — Known Baseline Assessment

### 2.1 Scan for Baseline Candidates

Items that are "old normal" — shouldn't trigger alerts every day:

**Issues: P1/Critical open > 90 days**

```bash
NINETY_DAYS_AGO=$(date -u -d '90 days ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-90d +%Y-%m-%dT%H:%M:%SZ)
for label in $PRIORITY_LABELS; do
  gh issue list --repo $REPO_OWNER/$REPO_NAME \
    --label "$label" --state open \
    --json number,title,createdAt \
    --limit 100 | jq --arg d "$NINETY_DAYS_AGO" '[.[] | select(.createdAt < $d)]'
done
```

**PRs: open > 60 days**

```bash
SIXTY_DAYS_AGO=$(date -u -d '60 days ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-60d +%Y-%m-%dT%H:%M:%SZ)
gh pr list --repo $REPO_OWNER/$REPO_NAME \
  --state open \
  --json number,title,createdAt \
  --limit 200 | jq --arg d "$SIXTY_DAYS_AGO" '[.[] | select(.createdAt < $d)]'
```

**Pipelines: failing > 7 days on default branch**

```bash
for workflow in $GH_ACTIONS_WORKFLOWS; do
  # Check if latest 7 days of runs are all failures
  gh run list --repo $REPO_OWNER/$REPO_NAME \
    --workflow "$workflow" --branch main \
    --json conclusion,createdAt \
    --limit 20
done
```

### 2.2 Present Baseline Candidates

If baseline candidates found, present to user:

```markdown
## Known Baseline Candidates

Found **N** items that appear to be known/accepted:

### Issues (X items)
| # | Title | Age | Labels |
|---|-------|-----|--------|
| #1234 | Issue title | 120 days | Priority:1 |
| ... | | | |

### PRs (Y items)
| # | Title | Age | Status |
|---|-------|-----|--------|
| #5678 | PR title | 75 days | Draft |
| ... | | | |

### Pipelines (Z items)
| Workflow | Last Success | Days Failing |
|----------|-------------|--------------|
| ci.yml | 2026-02-20 | 14 |
| ... | | |

These appear to be known/accepted items. Should I create a baseline file
so the health check doesn't flag them as new every day?
- **Yes** → I'll generate `.github/health-baseline.md`
- **No** → The health check will flag everything (you can baseline later)
```

### 2.3 Generate Baseline File

If user says yes, generate `.github/health-baseline.md`:

```markdown
# Repo Health — Known Baseline

> Last updated: {{TODAY}}
> Next review: {{TODAY + 30 days}}
>
> Items listed here are known and accepted by the team. The health check
> workflow will classify these as "baselined" rather than "new" findings.

## Baselined Issues

| # | Title | Reason | Baselined |
|---|-------|--------|-----------|
{{FOR EACH baseline issue}}
| #NUMBER | TITLE | [Ask user or auto-detect reason] | {{TODAY}} |
{{END FOR}}

## Baselined PRs

| # | Title | Reason | Baselined |
|---|-------|--------|-----------|
{{FOR EACH baseline PR}}
| #NUMBER | TITLE | [Ask user or auto-detect reason] | {{TODAY}} |
{{END FOR}}

## Baselined Pipeline Failures

| Pipeline | Failure | Reason | Baselined |
|----------|---------|--------|-----------|
{{FOR EACH baseline pipeline}}
| WORKFLOW | FAILURE_TYPE | [Ask user or auto-detect reason] | {{TODAY}} |
{{END FOR}}

## Review Policy

- Re-evaluate this file every 30 days
- Remove items when they are resolved
- Add date when baselining new items
- If an item has been baselined > 90 days, escalate it
```

Show the generated file to the user for review/edit before committing.

---

## Phase 3 — Template Configuration

### 3.1 Fill Placeholders

Read the three templates from `assets/templates/` and fill all `{{PLACEHOLDER}}` values:

| Placeholder | Source |
|-------------|--------|
| `{{REPO_OWNER}}` | Phase 1.1 detection |
| `{{REPO_NAME}}` | Phase 1.1 detection |
| `{{HEALTH_CHECK_SCHEDULE}}` | Default `0 6 * * *` or user choice |
| `{{GROOM_SCHEDULE}}` | 3h after health check (default `0 9 * * *`) |
| `{{CI_SYSTEM}}` | Phase 1.2 detection |
| `{{GH_ACTIONS_WORKFLOWS}}` | Phase 1.2 detection (comma-separated) |
| `{{AZDO_ORG}}` | Phase 1.2 user input (if applicable) |
| `{{AZDO_PROJECT}}` | Phase 1.2 user input (if applicable) |
| `{{AZDO_PIPELINES}}` | Phase 1.2 user input (if applicable) |
| `{{KNOWN_BASELINE_PATH}}` | `.github/health-baseline.md` |
| `{{ISSUE_PRIORITY_LABELS}}` | Phase 1.3 detection |
| `{{PR_REVIEW_REQUIRED_LABELS}}` | Phase 1.3 detection |
| `{{TEAM_AREAS}}` | Phase 1.3 detection |
| `{{INVESTIGATE_WORKFLOW}}` | `repo-health-investigate` |
| `{{MAX_INVESTIGATE_DISPATCHES}}` | Default `5` (reduce to `3` for small repos) |

### 3.2 Adjust for Repo Size/Complexity

**No AzDO?** → Remove all `{{#if AZDO}}...{{/if}}` sections from the orchestrator template.

**No area labels?** → Remove area-based grouping from I3 check. Simplify to just milestone detection.

**Small repo** (< 50 open issues, < 10 open PRs, 1–2 CI workflows):
- Consider single-tier: merge orchestrator + groomer, skip investigator
- Reduce `MAX_INVESTIGATE_DISPATCHES` to 3
- Ask user: "This is a smaller repo. Want the full 3-tier setup or a simpler single-tier?"

### 3.3 Set Schedule

```markdown
Default schedule:
- Health check: daily at 6:00 UTC (0 6 * * *)
- Groom: daily at 9:00 UTC (0 9 * * *)

Want a different schedule?
- Weekdays only? (0 6 * * 1-5)
- Twice daily? (0 6,18 * * *)
- Custom cron expression?
```

---

## Phase 4 — Compile & Deploy

### 4.1 Write Templates

```bash
TARGET_REPO="path/to/target/repo"

# Write filled templates
cp repo-health-check.md "$TARGET_REPO/.github/workflows/repo-health-check.md"
cp repo-health-investigate.md "$TARGET_REPO/.github/workflows/repo-health-investigate.md"
cp repo-health-groom.md "$TARGET_REPO/.github/workflows/repo-health-groom.md"
```

### 4.2 Compile with gh-aw

```bash
cd "$TARGET_REPO"

gh aw compile .github/workflows/repo-health-check.md
gh aw compile .github/workflows/repo-health-investigate.md
gh aw compile .github/workflows/repo-health-groom.md
```

### 4.3 Verify Compilation

```bash
# Check that .lock.yml files were produced
ls .github/workflows/repo-health-check.lock.yml
ls .github/workflows/repo-health-investigate.lock.yml
ls .github/workflows/repo-health-groom.lock.yml

echo "✅ All workflows compiled successfully"
```

If compilation fails, show the error and help the user fix it.

### 4.4 Write Baseline (if created)

```bash
if [ -f health-baseline.md ]; then
  cp health-baseline.md "$TARGET_REPO/.github/health-baseline.md"
fi
```

---

## Phase 5 — Auth & Secrets Guidance

Present the authentication requirements clearly:

```markdown
## Secrets Configuration

### Required (always)

1. **`GITHUB_TOKEN`** — ✅ Automatic
   No action needed. Built into GitHub Actions.

2. **`COPILOT_GITHUB_TOKEN`** — ⚠️ Manual setup required
   This is a PAT that authenticates the Copilot engine powering the agent.
   - Create a PAT with Copilot access
   - Store as a repository secret named `COPILOT_GITHUB_TOKEN`
   - See [gh-aw docs](https://github.github.com/gh-aw/reference/engines/) for details

### GitHub MCP Server

For same-repo monitoring, the automatic `GITHUB_TOKEN` is sufficient.
The gh-aw MCP gateway falls back: `GH_AW_GITHUB_MCP_SERVER_TOKEN` →
`GH_AW_GITHUB_TOKEN` → `GITHUB_TOKEN`. **No extra secret needed.**

{{#if AZDO}}
### Azure DevOps (required for pipeline monitoring)

3. **`AZDO_PAT`** — ⚠️ Manual setup required
   A Personal Access Token with Build (read) scope on your AzDO org.
   - Create at: https://dev.azure.com/{{AZDO_ORG}}/_usersSettings/tokens
   - Scope: Build → Read
   - Store as a repository secret named `AZDO_PAT`
{{/if}}

### gh-aw Setup

The workflows require `gh-aw` to be installed:
```
gh extension install gh-aw
```

**Safe-outputs model**: The agent can ONLY perform actions explicitly listed
in the safe-outputs section of each workflow. It CANNOT modify source code,
merge PRs, or close issues — only create/update the dashboard issue and
dispatch the investigation workflow.
```

---

## Phase 6 — Summary & Next Steps

```markdown
## ✅ Repo Health Check — Setup Complete

### Files Created

| File | Purpose |
|------|---------|
| `.github/workflows/repo-health-check.md` | Orchestrator workflow (source) |
| `.github/workflows/repo-health-check.lock.yml` | Orchestrator workflow (compiled) |
| `.github/workflows/repo-health-investigate.md` | Investigator workflow (source) |
| `.github/workflows/repo-health-investigate.lock.yml` | Investigator workflow (compiled) |
| `.github/workflows/repo-health-groom.md` | Groomer workflow (source) |
| `.github/workflows/repo-health-groom.lock.yml` | Groomer workflow (compiled) |
| `.github/health-baseline.md` | Known baseline (if created) |

### Secrets to Configure

| Secret | Status |
|--------|--------|
| `GITHUB_TOKEN` | ✅ Automatic |
| `COPILOT_GITHUB_TOKEN` | ⚠️ Add as repo secret |
| `AZDO_PAT` | ⚠️ Add as repo secret (if AzDO) |

### First Run

```bash
# Trigger manually to verify
gh workflow run repo-health-check.lock.yml
```

The first run will:
1. Collect all health data (issues, PRs, CI)
2. Create a pinned dashboard issue labeled `repo-health`
3. Classify all findings as 🆕 NEW (no previous data)
4. Dispatch investigators for critical findings

### Recommended Follow-up

1. **Day 1** — Review the dashboard issue after first run
2. **Day 3** — Check that diffs are working (NEW → EXISTING tracking)
3. **Week 1** — Tune thresholds if too noisy or too quiet
4. **Month 1** — Review and update the baseline file
```

---

## Rules

1. **Interactive** — Always show discovery results and get user confirmation
2. **Non-destructive** — Never overwrite existing files without asking
3. **Complete** — Don't skip phases; each builds on the previous
4. **Transparent** — Show all placeholders and their values before writing
5. **Testable** — Always suggest a manual first run to verify
