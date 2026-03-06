# Repo Health Check

Detailed reference for the repo health check system — a 3-tier agentic workflow that maintains a pinned dashboard issue tracking the ongoing health of a repository.

## Architecture

```
┌──────────────────────────┐
│  repo-health-check       │  Daily (scheduled + manual)
│  (Orchestrator)          │
│                          │
│  Collect → Diff →        │──── dispatch ────►  repo-health-investigate
│  Analyze → Dashboard →   │                     (per-finding deep dive)
│  Triage                  │
└──────────────────────────┘
            │
            │  runs 3h later
            ▼
┌──────────────────────────┐
│  repo-health-groom       │
│  (Dashboard Groomer)     │
│                          │
│  Link results → Resolve  │
│  → Hide stale → Trim     │
└──────────────────────────┘
```

### Tier 1: Orchestrator (`repo-health-check`)

Runs daily on schedule. Collects data on issues, PRs, and CI pipelines. Compares with the previous run (stored in cache-memory) to classify findings as NEW / EXISTING / RESOLVED. Updates or creates a pinned dashboard issue.

### Tier 2: Investigator (`repo-health-investigate`)

Dispatched by the orchestrator for critical/high-severity findings. Performs deep-dive analysis specific to the finding category (issue/PR/pipeline). Reports results back as a comment on the dashboard issue.

### Tier 3: Groomer (`repo-health-groom`)

Runs a few hours after the orchestrator. Links investigation results into the dashboard issue body, marks resolved findings, hides stale comments, and keeps the dashboard clean.

---

## Requirements

### gh-aw (GitHub Agentic Workflows)

All three workflows require `gh-aw` — the GitHub CLI extension for agentic workflows.

```bash
gh extension install gh-aw
```

### Authentication

| Secret | When Needed | Scope | How to Create |
|--------|-------------|-------|---------------|
| `GITHUB_TOKEN` | Always | Automatic | Built into GitHub Actions |
| `COPILOT_GITHUB_TOKEN` | Always (gh-aw engine) | Copilot access | PAT → repo secret ([gh-aw docs](https://github.github.com/gh-aw/reference/engines/)) |
| `AZDO_PAT` | If AzDO pipelines | Build (read) | AzDO PAT → repo secret |

**GitHub MCP Server auth**: For same-repo monitoring, the automatic `GITHUB_TOKEN` is sufficient — no extra secret needed. The fallback chain is: `GH_AW_GITHUB_MCP_SERVER_TOKEN` → `GH_AW_GITHUB_TOKEN` → `GITHUB_TOKEN`.

### Tools Used

- `github-mcp` — Read repos, issues, PRs, actions (via MCP gateway)
- `bash` — `gh` CLI for GitHub API, `curl` for AzDO API

---

## Data Collection Categories

### Issues

| ID | Check | What It Detects |
|----|-------|-----------------|
| I1 | Open issues by priority/severity label | Count + age distribution |
| I2 | Issues opened vs closed (24h) | Velocity — is the backlog growing? |
| I3 | Issues without triage | No milestone, no area label |
| I4 | Needs-info with no response > 14 days | Zombie issues that need action |
| I5 | Recent activity on old items | Potential escalations |

### Pull Requests

| ID | Check | What It Detects |
|----|-------|-----------------|
| P1 | Open PRs — count, age, review status | Overall PR health |
| P2 | PRs without reviewers | Missing review assignment |
| P3 | PRs with failing CI | Blocked PRs |
| P4 | PRs waiting on author > 7 days | Author may have abandoned |
| P5 | Stale PRs (no activity > 30 days) | Forgotten PRs |
| P6 | PRs merged (24h) | Merge velocity |

### GitHub Actions CI

| ID | Check | What It Detects |
|----|-------|-----------------|
| C1 | Recent run success/failure rate | CI reliability |
| C2 | Currently failing on default branch | Broken main/build |
| C3 | Flaky tests (pass/fail alternation) | Unreliable tests |
| C4 | Average CI duration trend | Performance regression |

### Azure DevOps Pipelines (if configured)

| ID | Check | What It Detects |
|----|-------|-----------------|
| A1 | Pipeline status — last run result | Current state |
| A2 | Pipeline failure rate (7 days) | Reliability trend |
| A3 | Queue times | Infrastructure pressure |

---

## Fingerprinting & Diff

Each finding gets a deterministic fingerprint based on its category and key attributes. This allows the system to track findings across runs:

- **🆕 NEW** — Finding appeared since last run
- **📌 EXISTING** — Finding was present last run too (includes day count)
- **✅ RESOLVED** — Finding from last run no longer present
- **📋 BASELINED** — Finding matches an entry in the known baseline file

Cache-memory stores the previous run's findings. On first run (no cache), all findings are classified as NEW.

---

## Known Baseline

The `.github/health-baseline.md` file lists items the team considers known and accepted. These get classified as "baselined" rather than "new" every day.

### When to Baseline

| Category | Threshold | Signal |
|----------|-----------|--------|
| Issues | P1/Critical open > 90 days | Known tech debt |
| PRs | Open > 60 days | Blocked or on-hold |
| Pipelines | Failing > 7 days on default branch | Known infra issue |

If more than 20 items qualify for baselining, strongly recommend creating the baseline file to keep the dashboard useful.

### Baseline File Format

```markdown
# Repo Health — Known Baseline

> Last updated: 2026-03-06
> Next review: 2026-04-05
>
> Items listed here are known and accepted by the team.

## Baselined Issues

| # | Title | Reason | Baselined |
|---|-------|--------|-----------|
| #1234 | Memory leak in parser | Known tech debt | 2026-03-06 |

## Baselined PRs

| # | Title | Reason | Baselined |
|---|-------|--------|-----------|
| #9012 | Large refactor (WIP) | Blocked on design | 2026-03-06 |

## Baselined Pipeline Failures

| Pipeline | Failure | Reason | Baselined |
|----------|---------|--------|-----------|
| official-ci | Timeout on macOS | Known pool issue | 2026-03-06 |

## Review Policy

- Re-evaluate every 30 days
- Remove resolved items
- Escalate items baselined > 90 days
```

---

## Dashboard Issue Format

The orchestrator maintains a single pinned issue labeled `repo-health`. The issue body contains the current state; daily comments contain the delta summary.

### Issue Body Structure

```markdown
# 🏥 Repo Health Dashboard

**Last updated**: 2026-03-06 06:00 UTC
**Status**: 🟡 Warning (2 critical, 5 warnings)

## Summary

[1-2 sentence executive summary]

## Findings

### 🔴 Critical
| ID | Category | Finding | Status | Since |
|----|----------|---------|--------|-------|
| `C1-abc123` | Pipeline | CI failing on main | 🆕 NEW | 2026-03-06 |

### 🟡 Warning
| ID | Category | Finding | Status | Since |
|----|----------|---------|--------|-------|
| `P3-ghi789` | PRs | 8 PRs with failing CI | 📌 Day 2 | 2026-03-04 |

### ✅ Recently Resolved
| ID | Category | Finding | Resolved |
|----|----------|---------|----------|
| `C2-jkl012` | Pipeline | Flaky test in auth | 2026-03-05 |

### 📋 Baselined (Known / Accepted)
| ID | Category | Finding | Baselined |
|----|----------|---------|-----------|
| `I1-mno345` | Issues | Memory leak #1234 | 2026-02-01 |

## Trends (7-day)
| Metric | Current | 7d Ago | Trend |
|--------|---------|--------|-------|
| Open P1 Issues | 5 | 7 | ✅ ↓ |
| Open PRs | 23 | 20 | ⚠️ ↑ |
| CI Success Rate | 82% | 91% | 🔴 ↓ |

---
*Updated by repo-health-check workflow • [Known baseline](.github/health-baseline.md)*
```

---

## Safe-Outputs Budget

Each workflow has strict limits on what it can do:

| Workflow | create-issue | update-issue | add-comment | dispatch-workflow | hide-comment |
|----------|-------------|-------------|-------------|-------------------|-------------|
| repo-health-check | 1 | 1 | 1 | MAX_INVESTIGATE (default: 5) | — |
| repo-health-investigate | — | — | 1 | — | — |
| repo-health-groom | — | 1 | — | — | 50 |

---

## Severity Classification

| Severity | Criteria | Action |
|----------|----------|--------|
| 🔴 Critical | CI failing on default branch, P1 issues without assignee, security-labeled issues untriaged | Dispatch investigator |
| 🟡 Warning | Stale PRs, rising issue backlog, flaky tests, slow CI trend | Report in dashboard |
| ℹ️ Info | Normal velocity metrics, recently resolved items | Trend tracking only |

---

## Scheduling

| Workflow | Default Schedule | Rationale |
|----------|-----------------|-----------|
| repo-health-check | `0 6 * * *` (daily 6 AM UTC) | Start of day for most teams |
| repo-health-groom | `0 9 * * *` (daily 9 AM UTC) | 3h after check — investigations complete |

Both support `workflow_dispatch` for manual runs.

---

## Setup

Use the `setup-repo-health-check` skill to deploy. It will:

1. Analyze the target repo (CI systems, labels, patterns)
2. Create a known baseline for existing accepted items
3. Fill and compile all three workflow templates
4. Guide you through secrets configuration
5. Suggest a first manual run to verify

See `assets/skills/setup-repo-health-check.md` for the interactive setup flow.
