---
name: bootstrap-ai-native-dotnet
description: Turn any .NET repository into an AI-native development environment. Use when someone wants to set up Copilot infrastructure, add AI skills/agents/workflows to a .NET repo, onboard a repo for AI-assisted development, or make a repo "AI-native". Also use when asked about setting up copilot-instructions, CI feedback loops for agents, or GitHub Copilot Coding Agent support for .NET projects.
---

# Bootstrap AI-Native .NET

Turn any .NET repository into an AI-native development environment.

Two tiers: **Required** covers the core setup. **Optional** adds specialized agents, skills, and workflows.

---

## Required

### Step 1: Analyze the Repo

Read `references/repo-analysis.md` and run the detection commands against the target repo.

You're detecting: SDK version, build command, test framework, test projects, CI system, project structure, platforms, branching strategy, and any existing AI files.

**Output**: a summary table you show the user for confirmation before proceeding.

```markdown
## Repo Analysis: [name]

| Property | Detected |
|----------|----------|
| .NET SDK | 9.0.100 |
| Build | `dotnet build Solution.sln` |
| Tests | xUnit, 3 projects |
| CI | GitHub Actions (ci.yml) / Azure Pipelines |
| Structure | src/Core/, src/Api/, tests/ |
| Platforms | None (standard .NET) |
| Existing AI | None |
```

**Ask the user to confirm** before moving on. They may correct the build command or add context.

### Step 2: Create AGENTS.md

Read `references/core-setup.md` for details.

A markdown file that tells AI agents what your repo is, how to build/test it, and what conventions to follow.

**Template**: `assets/core/AGENTS.md`

**Place at**: `AGENTS.md` in the repo root (cross-tool standard — supported by GitHub Copilot, Cursor, Claude, and others)

Fill in the template using the analysis from Step 1. Read 3-5 representative files from the repo to understand conventions before writing. Keep it under 100 lines — agents read this on every interaction.

A good AGENTS.md has:
- Real build/test commands (not "run the build" but `dotnet build MyApp.sln`)
- Project structure map (key directories, one-line descriptions)
- 3-5 conventions the AI wouldn't know from code alone
- Agent behavior rules (branch strategy, testing expectations)

### Step 3: Set Up the RL Environment

Read `references/core-setup.md` and `references/ci-feedback-loop.md` for details.

The feedback loop for code agents:

```
Agent gets task (issue assigned or scheduled)
    ↓
Agent reads AGENTS.md (understands repo)
    ↓
Agent makes code changes
    ↓
Push to PR → CI runs
    ↓
Agent reads CI results  ← THIS IS THE KEY PIECE
    ↓
CI pass → ready for review
CI fail → diagnose, fix, push again (loop)
```

**Two components**:

1. **Agent build environment** — So agents (remote or CI) can build the repo.
   - **GitHub Actions**: Uses `assets/core/copilot-setup-steps.yml`. Place at `.github/workflows/copilot-setup-steps.yml`.
   - **Azure Pipelines**: Uses `assets/core/agent-build-pipeline.yml`. Place at the repo root or `eng/pipelines/`.

2. **`pr-build-status` skill** — Agent can read CI failure logs. Uses `assets/core/pr-build-status.md`, filled with your CI system details (supports both GitHub Actions and Azure Pipelines). Place at `.github/skills/pr-build-status/SKILL.md`.

---

## Optional

Everything below adds specialized capabilities. Install what you need, skip what you don't.

**Ask the user**: "Do you want the full setup, or is the core (AGENTS.md + CI feedback loop) enough?"

### Step 4: Generate Scoped Instructions

Read `references/generating-instructions.md` for generation prompts.

Scoped `.instructions.md` files activate only when the AI touches matching files. Create one per domain area with distinct conventions:

- **Test projects** — almost always worth it (naming, assertion style, fixtures)
- **Platform-specific code** — if targeting Android/iOS/WASM
- **Config directories** — if templates or config have special rules

Skip for areas where the global AGENTS.md covers things adequately.

### Step 5: Configure Agents and Skills

Read `references/agents-and-skills.md` for the catalog and templates.

For each file, read the template from `assets/templates/`, replace `{{PLACEHOLDERS}}` with analysis results, and write to `.github/`.

**Agents** (multi-step workflows):
- `pr.md` + `pr/post-gate.md` + `pr/SHARED-RULES.md` — 4-phase PR workflow with multi-model fix exploration
- `write-tests-agent.md` — Test writing dispatcher
- `learn-from-pr.md` — Continuous improvement from PRs

**Skills** (focused capabilities):
- `try-fix` — Single-shot fix → test → report cycle
- `run-tests` — Build + run tests with filtering
- `verify-tests-fail` — Prove tests catch bugs

### Step 6: Copy Universal Files

Copy files from `assets/skills/` and `assets/workflows/` into the target repo. These work on any GitHub repo unchanged. For Azure DevOps repos, the workflow YAMLs need to be adapted to Azure Pipelines format.

**Skills**: pr-finalize, issue-triage, find-reviewable-pr, learn-from-pr, ai-summary-comment
**Workflows**: find-similar-issues, inclusive-heat-sensor
**Prompts**: release-notes.prompt.md

Skip any files that already exist in the target repo.

### Optional: Repo Health Monitoring (GitHub only)

If the user asks for health monitoring or pipeline observability, use the `setup-repo-health-check` skill (`assets/skills/setup-repo-health-check.md`). Requires `gh-aw` (GitHub Agentic Workflows) and sets up workflows that maintain a pinned health dashboard issue.

Not part of the core bootstrap — it's a post-onboarding add-on. See `references/repo-health-check.md` for architecture details.

---

## After Onboarding

Tell the user:

1. Review `AGENTS.md`
2. Test it: assign an issue to an agent or open a PR and ask for review
3. Commit the generated files
4. After your first agent PR, use `learn-from-pr` to improve the instructions

---

## What Gets Created

### Required (Core)
```
AGENTS.md                                        ← System prompt for the repo (repo root)

# GitHub Actions:
.github/
├── workflows/copilot-setup-steps.yml            ← Agent build environment
└── skills/pr-build-status/SKILL.md              ← Agent reads CI results

# Azure Pipelines:
agent-build-pipeline.yml                         ← Agent build environment
.github/skills/pr-build-status/SKILL.md          ← Agent reads CI results
```

### Optional (Enhanced)
```
.github/
├── instructions/*.instructions.md   ← Scoped guidance (GENERATED)
├── agents/
│   ├── pr.md                        ← PR review + fix (phases 1-2)
│   ├── pr/post-gate.md              ← Multi-model fix + report (phases 3-4)
│   ├── pr/SHARED-RULES.md           ← Common rules + model config
│   ├── write-tests-agent.md         ← Test writer
│   └── learn-from-pr.md             ← Continuous improvement
├── skills/
│   ├── try-fix/                     ← Fix → test → report cycle
│   ├── run-tests/                   ← Build + run tests locally
│   ├── verify-tests-fail/           ← Prove tests catch bugs
│   ├── pr-finalize/                 ← PR quality check
│   ├── find-reviewable-pr/          ← Find PRs to review
│   ├── issue-triage/                ← Triage open issues
│   ├── learn-from-pr/               ← Extract lessons from PRs
│   └── ai-summary-comment/          ← Post progress to PRs
├── workflows/
│   ├── find-similar-issues.yml      ← AI duplicate detection
│   └── inclusive-heat-sensor.yml    ← Community health
└── prompts/
    └── release-notes.prompt.md      ← Classified release notes
```

## File Layout

```
SKILL.md                    ← You are here (entry point)
├── references/
│   ├── core-setup.md            Required tier guide
│   ├── repo-analysis.md         Detection commands
│   ├── ci-feedback-loop.md      Feedback loop details
│   ├── generating-instructions.md  Instruction templates
│   ├── agents-and-skills.md     Optional tier catalog
│   └── repo-health-check.md     Health monitoring architecture
├── assets/
│   ├── core/              ← Required files (AGENTS.md, CI setup)
│   ├── templates/         ← Optional: fill in {{PLACEHOLDERS}}
│   ├── skills/            ← Optional: copy unchanged
│   └── workflows/         ← Optional: copy unchanged
└── evals/                 ← Test cases
```
