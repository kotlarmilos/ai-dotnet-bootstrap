# AI-Native .NET Bootstrap

Turn any .NET repository into an AI-native development environment.

## What is this?

A skill that analyzes a .NET repo and scaffolds AI infrastructure. Two tiers:

- **Required** — `AGENTS.md` + CI feedback loop
- **Optional** — Specialized agents, skills, and workflows

## Required

### 1. AGENTS.md

Tells AI agents what your repo is, how to build it, and how to behave.

```
AGENTS.md    ← Place at repo root (cross-tool standard: Copilot, Cursor, Claude, etc.)
```

Template: [`assets/core/AGENTS.md`](assets/core/AGENTS.md)

Contains: repo description, build/test commands, project structure, conventions, agent behavior rules.

### 2. RL Environment

Lets agents make changes, get CI feedback, and iterate.

```
Issue assigned → Agent reads AGENTS.md → Makes changes → Pushes PR → CI runs → Reads results → Iterates
```

Three components:

| Component | GitHub Actions | Azure Pipelines | Purpose |
|-----------|---------------|-----------------|---------|
| Agent build environment | [`copilot-setup-steps.yml`](assets/core/copilot-setup-steps.yml) | [`agent-build-pipeline.yml`](assets/core/agent-build-pipeline.yml) | Agent can build the repo |
| `pr-build-status` skill | [`pr-build-status.md`](assets/core/pr-build-status.md) | (same — supports both) | Agent can read CI failure logs |

---

## Optional

### Agents (multi-step workflows)

| Agent | Template | What it does |
|-------|----------|-------------|
| PR workflow | [`pr.md`](assets/templates/pr.md) + [`pr/post-gate.md`](assets/templates/pr/post-gate.md) | 4-phase PR review + multi-model fix |
| Test writer | [`write-tests-agent.md`](assets/templates/write-tests-agent.md) | Routes to correct test project |
| Learn from PR | [`learn-from-pr.md`](assets/templates/learn-from-pr.md) | Continuous improvement |

### Skills (focused capabilities)

**Configured** (need your repo's commands):

| Skill | Template |
|-------|----------|
| try-fix | [`assets/templates/try-fix.md`](assets/templates/try-fix.md) |
| run-tests | [`assets/templates/run-tests.md`](assets/templates/run-tests.md) |
| verify-tests-fail | [`assets/templates/verify-tests-fail.md`](assets/templates/verify-tests-fail.md) |

**Universal** (copy as-is):

| Skill | Source |
|-------|--------|
| pr-finalize | [`assets/skills/pr-finalize.md`](assets/skills/pr-finalize.md) |
| issue-triage | [`assets/skills/issue-triage.md`](assets/skills/issue-triage.md) |
| find-reviewable-pr | [`assets/skills/find-reviewable-pr.md`](assets/skills/find-reviewable-pr.md) |
| learn-from-pr | [`assets/skills/learn-from-pr.md`](assets/skills/learn-from-pr.md) |
| ai-summary-comment | [`assets/skills/ai-summary-comment.md`](assets/skills/ai-summary-comment.md) |

### Workflows & Prompts (copy as-is)

| File | Source |
|------|--------|
| find-similar-issues | [`assets/workflows/find-similar-issues.yml`](assets/workflows/find-similar-issues.yml) |
| inclusive-heat-sensor | [`assets/workflows/inclusive-heat-sensor.yml`](assets/workflows/inclusive-heat-sensor.yml) |
| release-notes | [`assets/templates/release-notes.prompt.md`](assets/templates/release-notes.prompt.md) |

### Repo Health Monitoring (GitHub only, requires `gh-aw`)

| Component | Source |
|-----------|--------|
| Setup skill | [`assets/skills/setup-repo-health-check.md`](assets/skills/setup-repo-health-check.md) |
| Health check orchestrator | [`assets/templates/repo-health-check.md`](assets/templates/repo-health-check.md) |
| Investigation worker | [`assets/templates/repo-health-investigate.md`](assets/templates/repo-health-investigate.md) |
| Dashboard groomer | [`assets/templates/repo-health-groom.md`](assets/templates/repo-health-groom.md) |

## Quick Start

1. Add this skill to your Copilot configuration
2. Say: **"Bootstrap AI infrastructure for this repo"**
3. The skill analyzes your repo and creates everything in `.github/`

Or for just the required tier: **"Set up the core AI infrastructure — just AGENTS.md and CI feedback loop"**

## How It Works

```
SKILL.md                    ← Entry point (Required → Optional flow)
├── references/
│   ├── core-setup.md            Required tier guide
│   ├── repo-analysis.md         Detection commands
│   ├── ci-feedback-loop.md      Feedback loop details
│   ├── generating-instructions.md  Instruction templates
│   ├── agents-and-skills.md     Optional tier catalog
│   └── repo-health-check.md     Health monitoring architecture
├── assets/
│   ├── core/              ← Required: AGENTS.md, CI setup
│   ├── templates/         ← Optional: fill in {{PLACEHOLDERS}}
│   ├── skills/            ← Optional: copy unchanged
│   └── workflows/         ← Optional: copy unchanged
└── evals/                 ← Test cases
```

## License

MIT
