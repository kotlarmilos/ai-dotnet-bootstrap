---
name: bootstrap-ai-native-dotnet
description: Turn any .NET repository into an AI-native development environment. Use when someone wants to set up Copilot infrastructure, add AI skills/agents/workflows to a .NET repo, onboard a repo for AI-assisted development, or make a repo "AI-native". Also use when asked about setting up copilot-instructions, CI feedback loops for agents, or GitHub Copilot Coding Agent support for .NET projects.
---

# Bootstrap AI-Native .NET

Turn any .NET open-source repository into an AI-native development environment — with instructions that teach the AI your codebase, skills that let it act, and a CI feedback loop so it can learn from build results.

## What This Creates

```
.github/
├── copilot-instructions.md          ← Teaches AI your repo (GENERATED)
├── instructions/*.instructions.md   ← Domain-specific AI guidance (GENERATED)
├── agents/pr.md                     ← PR review + fix workflow (CONFIGURED)
├── agents/pr/post-gate.md           ← Multi-model fix exploration (CONFIGURED)
├── agents/pr/SHARED-RULES.md        ← Model config + shared rules (CONFIGURED)
├── agents/write-tests-agent.md      ← Test writing dispatcher (CONFIGURED)
├── skills/                          ← Capabilities the AI can invoke
│   ├── try-fix/                     ← Fix → test → report cycle (CONFIGURED)
│   ├── run-tests/                   ← Build + run tests locally (CONFIGURED)
│   ├── pr-finalize/                 ← Verify PR quality (UNIVERSAL)
│   ├── pr-build-status/             ← Read CI results (CONFIGURED)
│   ├── issue-triage/                ← Triage open issues (UNIVERSAL)
│   ├── find-reviewable-pr/          ← Find PRs to review (UNIVERSAL)
│   ├── learn-from-pr/               ← Extract lessons from PRs (UNIVERSAL)
│   └── ai-summary-comment/          ← Post progress to PRs (UNIVERSAL)
├── workflows/
│   ├── copilot-setup-steps.yml      ← Remote Copilot can build (CONFIGURED)
│   ├── find-similar-issues.yml      ← AI duplicate detection (UNIVERSAL)
│   └── inclusive-heat-sensor.yml    ← Detects heated comments (UNIVERSAL)
└── prompts/
    └── release-notes.prompt.md      ← Generate release notes (CONFIGURED)
```

Files are either:
- **UNIVERSAL** — Copied as-is, works on any repo
- **CONFIGURED** — Template filled with your repo's build/test commands
- **GENERATED** — Produced by analyzing your specific repo

---

## Steps

There are 5 steps. Go in order. Each step has a reference doc in `references/` — read it just-in-time, not upfront.

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
| CI | GitHub Actions (ci.yml) |
| Structure | src/Core/, src/Api/, tests/ |
| Platforms | None (standard .NET) |
| Existing AI | None |
```

**Ask the user to confirm** before moving on. They may correct the build command or add context.

### Step 2: Set Up the CI Feedback Loop

This is the most important step. Without it, AI agents are blind — they can make changes but can't see if those changes break CI.

Read `references/ci-feedback-loop.md` for details.

Three components, in this order:

1. **`copilot-setup-steps.yml`** — So GitHub's remote Copilot Coding Agent can build your repo. Uses the template in `assets/templates/copilot-setup-steps.yml`, filled with your SDK version and build command.

2. **`pr-build-status` skill** — So any agent (local or remote) can query CI results for a PR. Reads GitHub Actions job status, failed job logs, extracts error messages. Uses template in `assets/templates/pr-build-status.md`.

3. **`ci-doctor` workflow** (optional) — Automatic investigation when CI fails on main. Uses GitHub Models AI to analyze failure logs and create diagnostic issues.

This gives agents the feedback loop: `make change → push → CI runs → read results → iterate`.

### Step 3: Generate Repo-Specific Instructions

Read `references/generating-instructions.md` for the generation prompts.

1. **`copilot-instructions.md`** — The single most impactful file. Teaches AI your repo's structure, build commands, conventions, project areas. Read 3-5 representative files from the repo to understand conventions before writing.

2. **Scoped instructions** — One per domain area that has distinct conventions. Test projects almost always get one. Platform-specific code gets one if present. Only create them for areas where the AI would make mistakes without guidance.

### Step 4: Configure Agents and Skills

Read `references/agents-and-skills.md` for the catalog and templates.

For each file, read the template from `assets/templates/`, replace `{{PLACEHOLDERS}}` with analysis results, and write to `.github/`.

**Agents** (how AI works on your repo):
- `pr.md` + `pr/post-gate.md` + `pr/SHARED-RULES.md` — 4-phase PR workflow with multi-model try-fix exploration (Phase 3 dispatches try-fix to multiple AI models sequentially, each generating independent fix ideas, then cross-pollinates)
- `write-tests-agent.md` — Test writing dispatcher

**Skills** (what AI can do):
- `try-fix` — Single-shot fix → test → report
- `run-tests` — Build + run tests with filtering
- `verify-tests-fail` — Prove tests catch bugs

### Step 5: Copy Universal Files

Copy files from `assets/skills/` and `assets/workflows/` into the target repo. These work on any GitHub repo unchanged.

**Skills**: pr-finalize, issue-triage, find-reviewable-pr, learn-from-pr, ai-summary-comment
**Workflows**: find-similar-issues, inclusive-heat-sensor

Skip any files that already exist in the target repo.

### Optional: Repo Health Monitoring

If the user asks for health monitoring, repo health checks, or pipeline observability, use the `setup-repo-health-check` skill (`assets/skills/setup-repo-health-check.md`). This requires `gh-aw` and sets up agentic workflows that maintain a pinned health dashboard issue.

This is NOT part of the core 5-step bootstrap — it's a post-onboarding add-on for repos that want continuous health visibility. See `references/repo-health-check.md` for architecture details.

---

## After Onboarding

Generate a `README-AI.md` listing everything that was created. Then tell the user:

1. Review `copilot-instructions.md` — it's the highest-impact file
2. Review scoped instructions — verify glob patterns match your project
3. Commit: `git add .github/ && git commit -m "Add AI-native development infrastructure"`
4. Test it: open a PR, ask Copilot to review it
5. After your first PR, use `learn-from-pr` to improve the instructions

---

## Key Concepts

### The CI Feedback Loop

AI agents without CI feedback are like developers who never run their code. The feedback loop is:

```
Agent writes code
    ↓
Push to PR branch
    ↓
CI runs (build, test, lint)
    ↓
Agent reads CI results ← THIS IS THE MISSING PIECE in most repos
    ↓
Agent fixes failures
    ↓
Repeat until green
```

Three things make this work:
1. **`copilot-setup-steps.yml`** — Remote agent can build the repo
2. **`pr-build-status` skill** — Agent can read what failed and why
3. **Clear test commands in instructions** — Agent knows how to run tests locally

### File Layout

- This SKILL.md is the entry point
- `references/` has detailed guides — read only when needed
- `assets/` has the actual files to copy or fill in
