# AI-Native .NET Bootstrap

Turn any .NET repository into an AI-native development environment.

## What is this?

A single skill — following the [Anthropic skill-creator pattern](https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md) — that analyzes a .NET repo and scaffolds the full AI infrastructure: instructions, agents, skills, workflows, and CI feedback loop.

## Quick Start

1. Add this skill to your Copilot configuration
2. Say: **"Bootstrap AI infrastructure for this repo"**
3. The skill analyzes your repo and creates everything in `.github/`

Or run it manually by reading `SKILL.md` and following the 5 steps.

## What Gets Created

```
.github/
├── copilot-instructions.md       ← Generated: repo overview, build cmds, conventions
├── instructions/*.instructions.md ← Generated: scoped by glob pattern
├── workflows/copilot-setup-steps.yml ← CI feedback loop (agent can build)
├── agents/pr.md                  ← PR review + fix workflow
├── agents/write-tests-agent.md   ← Test writer
├── agents/learn-from-pr.md       ← Continuous improvement
├── skills/pr-build-status/       ← Agent reads CI failures
├── skills/try-fix/               ← Empirical fix attempts
├── skills/run-tests/             ← Local test runner
├── skills/verify-tests-fail/     ← Prove tests catch bugs
├── skills/pr-finalize/           ← PR description check
├── skills/find-reviewable-pr/    ← Find PRs to review
├── skills/issue-triage/          ← Triage open issues
├── skills/learn-from-pr/         ← Extract lessons from PRs
├── skills/ai-summary-comment/    ← PR progress comments
├── workflows/find-similar-issues.yml ← AI duplicate detection
├── workflows/inclusive-heat-sensor.yml ← Community health
└── prompts/release-notes.prompt.md ← Classified release notes
```

## Architecture

```
SKILL.md                    ← Entry point (what to do)
├── references/             ← How to do it (read just-in-time)
│   ├── repo-analysis.md         Step 1: Detection commands
│   ├── ci-feedback-loop.md      Step 2: The RL environment
│   ├── generating-instructions.md Step 3: Instruction templates
│   └── agents-and-skills.md     Step 4: Agent/skill catalog
├── assets/
│   ├── skills/             ← Universal (copy unchanged)
│   ├── templates/          ← Configured (fill {{PLACEHOLDERS}})
│   └── workflows/          ← Universal (copy unchanged)
└── evals/                  ← Test cases
```

## The CI Feedback Loop

The most critical piece. Without it, AI agents push code blindly.

```
Agent writes code → CI runs → pr-build-status reads results → Agent iterates
```

Three components:
1. **copilot-setup-steps.yml** — Agent can build the repo
2. **pr-build-status skill** — Agent can read CI failures
3. **The iterate loop** — Agent fixes based on CI feedback

## Distilled From

[dotnet/maui](https://github.com/dotnet/maui) — 4 agents, 13 skills, 8 scoped instructions, 6 AI workflows.

## License

MIT
