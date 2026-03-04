# AI-Native .NET Bootstrap

Turn any .NET repository into an AI-native development environment.

## What is this?

A skill that analyzes a .NET repo and scaffolds AI infrastructure: instructions, agents, skills, workflows, and a CI feedback loop.

## Quick Start

1. Add this skill to your Copilot configuration
2. Say: **"Bootstrap AI infrastructure for this repo"**
3. The skill analyzes your repo and creates everything in `.github/`

## What Gets Created

```
.github/
├── copilot-instructions.md          ← Generated from your repo
├── instructions/*.instructions.md   ← Scoped by glob pattern
├── workflows/copilot-setup-steps.yml ← Agent can build your repo remotely
├── agents/
│   ├── pr.md                        ← PR review + fix workflow
│   ├── pr/post-gate.md              ← Multi-model fix exploration
│   ├── pr/SHARED-RULES.md           ← Model config + shared rules
│   ├── write-tests-agent.md         ← Test writer
│   └── learn-from-pr.md             ← Continuous improvement
├── skills/
│   ├── pr-build-status/             ← Agent reads CI failures
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

Files are either **universal** (copied as-is), **configured** (template filled with your build/test commands), or **generated** (produced by analyzing your repo).

## The CI Feedback Loop

The most critical piece. Without it, AI agents push code blindly.

```
Agent writes code → CI runs → pr-build-status reads results → Agent iterates
```

Three components:
1. **copilot-setup-steps.yml** — Remote agent can build the repo
2. **pr-build-status skill** — Agent can read what failed and why
3. **Clear test commands in instructions** — Agent knows how to run tests

## How It Works

```
SKILL.md                    ← Entry point (5-step workflow)
├── references/             ← Detailed guides, read when needed
│   ├── repo-analysis.md         Detection commands
│   ├── ci-feedback-loop.md      The feedback loop
│   ├── generating-instructions.md  Instruction templates
│   └── agents-and-skills.md     Agent/skill catalog
├── assets/
│   ├── skills/             ← Universal (copy unchanged)
│   ├── templates/          ← Fill in {{PLACEHOLDERS}}
│   └── workflows/          ← Universal (copy unchanged)
└── evals/                  ← Test cases
```

## License

MIT
