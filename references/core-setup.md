# Core Setup — Required Infrastructure

The two things every AI-native repo needs. Everything else is optional.

## 1. AGENTS.md — The System Prompt

**What**: A markdown file that tells AI agents what your repo is, how to build/test it, and how to behave.

**Where**: `AGENTS.md` at repo root. This is the cross-tool standard — supported by GitHub Copilot, Cursor, Claude, and others. Tool-specific files (`.github/copilot-instructions.md`, `CLAUDE.md`) can symlink or reference it.

**Template**: `assets/core/AGENTS.md`

**Why it matters**: Without this, agents guess at your build commands, conventions, and structure.

### How to Fill It In

1. Run the repo analysis from `references/repo-analysis.md` (or just answer the questions manually)
2. Fill in the template placeholders
3. Add 3-5 conventions that an AI wouldn't know from reading code alone
4. Keep it under 100 lines

### Verification

After creating the file, test it:
- Open Copilot in your repo and ask "How do I build this project?"
- The answer should match your AGENTS.md exactly
- If it doesn't, the file isn't being picked up (check the path)

---

## 2. RL Environment — The Feedback Loop

**What**: Infrastructure that lets an agent observe a task, make changes, get CI feedback, and iterate. This is the reinforcement learning loop for code agents.

**Two components**:

### 2a. Build Environment

Ensures the CI pipeline builds the repo so agents can read results.

**GitHub Actions** — `assets/core/copilot-setup-steps.yml`
Pre-builds the repo so remote agents (like GitHub Copilot Coding Agent) start with a working environment.
Place at `.github/workflows/copilot-setup-steps.yml`.

**Azure Pipelines** — `assets/core/agent-build-pipeline.yml`
Pipeline template that builds and tests the repo on PRs.
Place at repo root or `eng/pipelines/`.

**Fill in** (both templates):
- `{{DOTNET_VERSION}}` — SDK version from `global.json` or `dotnet --version`
- `{{RESTORE_COMMAND}}` — e.g., `dotnet restore Solution.sln`
- `{{BUILD_COMMAND}}` — e.g., `dotnet build Solution.sln`
- `{{TEST_COMMAND}}` — e.g., `dotnet test Solution.sln` (Azure Pipelines template only)

### 2b. CI Results Reader (`pr-build-status` skill)

**Template**: `assets/core/pr-build-status.md`

Gives agents the ability to read CI failure logs. Without this, agents push code and hope for the best. With this, they can diagnose failures and fix them.

**Fill in**:
- `{{CI_SYSTEM}}` — `github-actions` or `azure-pipelines`
- `{{PIPELINE_NAMES}}` — Names of your CI workflows

Place at `.github/skills/pr-build-status/SKILL.md`.

---

## The Complete RL Loop

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│   TRIGGER                                           │
│   Issue assigned to agent / scheduled run            │
│                      │                              │
│                      ▼                              │
│   OBSERVE ──────► AGENTS.md                         │
│   Read issue        (what is this repo?             │
│   Read repo          how to build/test?)            │
│                      │                              │
│                      ▼                              │
│   ACT                                               │
│   Make code changes                                 │
│   Run tests locally                                 │
│                      │                              │
│                      ▼                              │
│   SUBMIT                                            │
│   Push to branch, create PR                         │
│                      │                              │
│                      ▼                              │
│   FEEDBACK ─────► pr-build-status                   │
│   CI runs            (what failed? why?)            │
│   Read results                                      │
│                      │                              │
│               ┌──────┴──────┐                       │
│               │             │                       │
│            CI Pass      CI Fail                     │
│               │             │                       │
│          Ready for      Fix + push                  │
│          review         again ──► (loop back)       │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Quick Start

1. Copy `assets/core/AGENTS.md` template to `AGENTS.md` in the repo root
2. Fill in your build/test commands and 3-5 conventions
3. Set up build environment:
   - **GitHub Actions**: Copy `assets/core/copilot-setup-steps.yml` to `.github/workflows/`
   - **Azure Pipelines**: Copy `assets/core/agent-build-pipeline.yml` to repo root or `eng/pipelines/`
4. Fill in SDK version and build commands

For specialized agents, skills, and workflows, see the Optional tier in `SKILL.md`.
