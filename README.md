# AI-Native .NET Bootstrap

Turn any .NET open-source repository into an AI-native development environment.

Point the onboarding agent at a cloned .NET repo on disk and it will scaffold the full AI infrastructure — instructions, skills, agents, workflows, and scripts.

## Quick Start

```bash
# Clone the toolkit
git clone https://github.com/user/ai-native-dotnet-bootstrap.git

# Point it at your .NET repo
cd /path/to/your-dotnet-repo
copilot
# Then: @onboard-repo /path/to/ai-native-dotnet-bootstrap
```

Or manually:

```bash
# 1. Copy the onboarding agent into your repo
cp ai-native-dotnet-bootstrap/agent/onboard-repo.md /path/to/your-repo/.github/agents/

# 2. Invoke it
copilot
/agent onboard-repo
# "Please onboard this repo"
```

## What Gets Created

The agent analyzes your repo and creates a `.github/` tree:

```
.github/
├── copilot-instructions.md         ← GENERATED (repo-specific)
├── README-AI.md                    ← GENERATED
├── instructions/                   ← GENERATED (one per domain area)
│   ├── tests.instructions.md
│   └── ...
├── agents/
│   ├── pr.md                       ← TEMPLATED (filled with your build/test commands)
│   ├── write-tests-agent.md        ← TEMPLATED
│   └── learn-from-pr.md            ← COPIED (universal)
├── skills/
│   ├── try-fix/SKILL.md            ← TEMPLATED
│   ├── run-tests/SKILL.md          ← TEMPLATED
│   ├── pr-finalize/SKILL.md        ← COPIED (universal)
│   ├── issue-triage/SKILL.md       ← COPIED (universal)
│   ├── learn-from-pr/SKILL.md      ← COPIED (universal)
│   └── ai-summary-comment/SKILL.md ← COPIED (universal)
├── workflows/
│   ├── copilot-setup-steps.yml     ← TEMPLATED
│   ├── find-similar-issues.yml     ← COPIED (universal)
│   └── ...
└── prompts/
    └── release-notes.prompt.md     ← TEMPLATED
```

## Feature Tiers

| Tier | Description | Count |
|------|-------------|-------|
| **COPY** | Universal files that work on any .NET OSS repo as-is | 8 |
| **TEMPLATE** | Skeletons filled with repo-specific values (build cmd, test framework, paths) | 8 |
| **GENERATE** | Agent analyzes repo and produces from scratch | 3 |

### COPY (drop-in universal)
- `pr-finalize` skill — verifies PR title/description match implementation
- `issue-triage` skill — queries and triages open issues
- `find-reviewable-pr` skill — finds PRs needing review
- `learn-from-pr` skill + agent — extracts lessons from completed PRs
- `ai-summary-comment` skill — posts unified progress comments on PRs
- `find-similar-issues.yml` workflow — AI duplicate detection on new issues
- `inclusive-heat-sensor.yml` workflow — detects heated language
- `agentics-maintenance.yml` workflow — auto-closes expired agentic issues

### TEMPLATE (customized per repo)
- `copilot-setup-steps.yml` — pre-builds repo for remote Copilot
- PR agent — 4-phase workflow with repo's build/test commands
- `write-tests-agent` — routes to correct test skill
- `try-fix` skill — single-shot fix → test → report cycle
- `run-tests` skill — build + run tests locally
- `pr-build-status` skill — query CI for build results
- `verify-tests-fail-without-fix` skill — proves tests catch bugs
- `release-notes.prompt.md` — commit classifier + generator

### GENERATE (produced by analysis)
- `copilot-instructions.md` — full repo overview, structure, conventions
- Pattern-scoped `*.instructions.md` — one per domain area detected
- `README-AI.md` — documents all AI features installed

## Repository Structure

```
ai-native-dotnet-bootstrap/
├── README.md                    ← You are here
├── agent/
│   └── onboard-repo.md          ← The onboarding agent
├── copy/                         ← Universal files (COPY tier)
│   ├── skills/
│   │   ├── pr-finalize/
│   │   ├── issue-triage/
│   │   ├── find-reviewable-pr/
│   │   ├── learn-from-pr/
│   │   └── ai-summary-comment/
│   └── workflows/
│       ├── find-similar-issues.yml
│       ├── inclusive-heat-sensor.yml
│       └── agentics-maintenance.yml
├── templates/                    ← Skeleton files (TEMPLATE tier)
│   ├── agents/
│   │   ├── pr.md
│   │   └── write-tests-agent.md
│   ├── skills/
│   │   ├── try-fix/
│   │   ├── run-tests/
│   │   ├── pr-build-status/
│   │   └── verify-tests-fail/
│   ├── workflows/
│   │   └── copilot-setup-steps.yml
│   └── prompts/
│       └── release-notes.prompt.md
└── generator/                    ← Prompts/logic for GENERATE tier
    ├── analyze-repo.md
    ├── generate-copilot-instructions.md
    ├── generate-scoped-instructions.md
    └── generate-readme-ai.md
```

## How the Onboarding Agent Works

### Step 1: Analyze
Reads `global.json`, `*.sln`, `*.csproj`, `README.md`, build scripts to detect:
- .NET SDK version, build system, test framework
- CI system (GitHub Actions, Azure DevOps)
- Project areas and platform-specific code
- Existing `.github/` AI files (skip/merge)

### Step 2: Generate
Produces repo-specific files using the generator prompts:
- `copilot-instructions.md` with full repo context
- Pattern-scoped instructions for each domain area found

### Step 3: Template
Fills skeleton templates with detected values:
- Build command, test command, project paths
- CI pipeline names, test categories

### Step 4: Copy
Drops in universal files unchanged.

### Step 5: Validate
- Checks YAML syntax
- Verifies glob patterns reference real paths
- Tests that build command works

## License

MIT
