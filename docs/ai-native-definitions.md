# AI-Native Development: Definitions & Architecture

## What is AI-Native?

**AI-native** describes a software repository that has been structured from the ground up (or retrofitted) to be deeply understood and effectively operated on by AI coding agents. An AI-native repository doesn't just contain code — it contains **machine-readable context, behavioral instructions, and composable skills** that enable AI agents to plan, implement, test, review, and ship code with minimal human guidance.

The key distinction: a traditional repository stores code for humans to read and tools to compile. An AI-native repository additionally stores **intent, conventions, and workflows** in formats that AI agents consume as first-class inputs.

### The AI-Native Maturity Model

| Level | Name | Description |
|-------|------|-------------|
| **L0** | Unaware | No AI context. Agents operate on raw code with no guidance. |
| **L1** | Instructed | Has `copilot-instructions.md` or `CLAUDE.md` — agents know build commands and conventions. |
| **L2** | Skilled | Has reusable prompts/skills — agents can perform common tasks (fix builds, add tests, review PRs). |
| **L3** | Agentic | Has specialized agents with roles — agents can plan, implement, test, and review independently. |
| **L4** | Orchestrated | Has a pipeline orchestrator — agents chain together in a structured workflow with artifact handoff. |
| **L5** | Self-Improving | Has CI feedback loops — agents learn from build failures, test results, and review feedback to improve over time. |

---

## Core Concepts

### 1. Agents

An **agent** is a specialized AI persona with a defined role, tool access, and behavioral constraints. Each agent is an expert in one phase of the software development lifecycle.

**Properties of an agent:**
- **Name** — Unique identifier (e.g., `implementer`, `reviewer`, `test-writer`)
- **Description** — One-line summary of what it does
- **Tools** — Which tools it can use (`read`, `edit`, `search`, `terminal`)
- **Role constraints** — What it must do and must NOT do
- **Output format** — Structured artifact format for handoff to other agents
- **Domain knowledge** — Repository-specific patterns, conventions, and rules

**Agent file format (GitHub Copilot):**
```yaml
---
name: implementer
description: Writes production code following repo patterns
tools: [read, edit, search, terminal]
---
# Agent instructions in markdown...
```

**Agent file format (Claude Code / Anthropic Skills):**
```markdown
---
name: implement
description: Writes production code following repo patterns. Use when the user asks to implement a feature, fix a bug, or write code.
---
# Instructions and context in markdown...
```

**Anthropic Skill Package structure** (for distributable, testable skills):
```
skill-name/
├── SKILL.md              ← Main skill instructions with YAML frontmatter
├── agents/               ← Subagent instructions (grader, comparator, analyzer)
├── scripts/              ← Automation scripts (eval runners, benchmarks)
├── references/           ← Reference docs (schemas, detection tables)
├── evals/
│   ├── evals.json        ← Test cases with expectations
│   └── files/            ← Test input files
└── assets/               ← Images, diagrams
```

**The 6 Standard Agents:**

| Agent | Role | Input | Output |
|-------|------|-------|--------|
| **Planner** | Analyzes requirements, designs solutions | User request + codebase | Implementation plan |
| **Implementer** | Writes production code | Plan artifact | Code changes |
| **Test Writer** | Generates tests | Implementation artifact | Test files |
| **Reviewer** | Reviews for quality and patterns | Code + tests | Review report |
| **Security Reviewer** | Scans for vulnerabilities | Code changes | Security report |
| **Orchestrator** | Coordinates the pipeline | User request | Final report |

---

### 2. Skills

A **skill** is a reusable, composable unit of AI capability. Skills are the building blocks that agents use. A skill is narrower than an agent — it does one thing well.

**Types of skills:**

| Type | Format | Trigger | Example |
|------|--------|---------|---------|
| **Prompt** | `.github/prompts/*.prompt.md` | Slash command (`/fix-build`) | Diagnose and fix build failures |
| **Instruction** | `.github/copilot-instructions.md` | Auto-injected into every conversation | Build commands, coding conventions |
| **Claude Skill** | `.claude/skills/*/SKILL.md` | Invoked by name in Claude Code | Bootstrap a .NET repo |
| **Hook** | `.github/hooks/*.sh` | Git lifecycle events | Pre-commit validation |
| **Workflow** | `.github/workflows/*.yml` | CI/CD triggers | Copilot agent setup |

**Skill quality is measurable.** Following the [Anthropic skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator) pattern, every skill can have:
- **Evals** (`evals/evals.json`) — Test prompts with verifiable expectations
- **Grading** — Automated scoring of skill outputs against expectations
- **Benchmarking** — With-skill vs without-skill comparison (does the skill actually help?)
- **Iteration** — Draft → test → review → improve → repeat until expectations pass

**The difference between agents and skills:**
- An **agent** is a persistent persona with a role and constraints
- A **skill** is a discrete capability that can be invoked on demand
- Agents USE skills. Skills are standalone.
- Skills can be **evaluated** — agents can only be evaluated through their skill outputs
- Example: The `implementer` agent uses the "ML.NET coding conventions" skill (from `copilot-instructions.md`)

---

### 3. Layers

An AI-native repository is organized into **5 layers**, each serving a different purpose:

```
┌─────────────────────────────────────────────────────────┐
│  Layer 5: CI & Automation                               │
│  copilot-setup-steps.yml, pre-commit hooks              │
│  → Automated guardrails that run without human trigger   │
├─────────────────────────────────────────────────────────┤
│  Layer 4: Orchestration                                 │
│  orchestrator.agent.md                                   │
│  → Chains agents into a pipeline with artifact handoff   │
├─────────────────────────────────────────────────────────┤
│  Layer 3: Specialized Agents                            │
│  planner, implementer, test-writer, reviewer, security   │
│  → Role-specific AI personas with constrained behavior   │
├─────────────────────────────────────────────────────────┤
│  Layer 2: Skills & Prompts                              │
│  fix-build, add-test, review-pr prompts                  │
│  → Reusable capabilities triggered by slash commands     │
├─────────────────────────────────────────────────────────┤
│  Layer 1: Foundation Context                            │
│  AGENTS.md, copilot-instructions.md, CLAUDE.md           │
│  → Always-on context: architecture, conventions, rules   │
└─────────────────────────────────────────────────────────┘
```

| Layer | Files | When Active | Purpose |
|-------|-------|-------------|---------|
| **Foundation** | `AGENTS.md`, `copilot-instructions.md`, `CLAUDE.md` | Always (auto-injected) | Base context for all AI interactions |
| **Skills** | `.github/prompts/*.prompt.md`, `.claude/skills/*.md` | On-demand (slash commands) | Repeatable tasks |
| **Agents** | `.github/agents/*.agent.md` | On-demand (`@agent` mention) | Role-specific workflows |
| **Orchestration** | `orchestrator.agent.md` | On-demand | Multi-stage pipeline coordination |
| **Automation** | Workflows, hooks | Event-driven (CI, git hooks) | Guardrails without human trigger |

---

### 4. Pipeline Pattern

The **agent pipeline** is the recommended workflow for feature development. It follows a strict sequence with structured artifact handoff between stages:

```
  User Request
       │
       ▼
  ┌─────────┐    design     ┌──────────────┐    code      ┌─────────────┐
  │ PLANNER │───artifact───▶│ IMPLEMENTER  │───artifact──▶│ TEST WRITER │
  └─────────┘               └──────────────┘              └─────────────┘
                                                                 │
                                                            test artifact
                                                                 │
                              ┌──────────┐                       ▼
                              │ SECURITY │◀──── code + tests ────┤
                              │ REVIEWER │       (parallel)      │
                              └──────────┘                       │
                              ┌──────────┐                       │
                              │ REVIEWER │◀──────────────────────┘
                              └──────────┘
                                    │
                               review reports
                                    │
                                    ▼
                            ┌───────────────┐
                            │ CONSOLIDATION │──▶ Final Report
                            └───────────────┘
```

**Artifact handoff format:**
```markdown
## Artifact: [stage] → [next-stage]
### Files Changed
- path/to/file.cs (created | modified | deleted)
### Summary
Brief description
### Details
Full content or diff
```

**Pipeline rules:**
1. Never skip stages
2. If a stage fails, stop — don't cascade errors
3. Show the user what each stage produced
4. Public API changes always need human review

---

### 5. Skill Lifecycle (Draft → Test → Improve)

Following the [Anthropic skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator) methodology, skills are developed through an iterative cycle:

```
  ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
  │  DRAFT   │────▶│   TEST   │────▶│  REVIEW  │────▶│ IMPROVE  │
  │ the skill│     │ run evals│     │ grade +  │     │ based on │
  └──────────┘     └──────────┘     │ feedback │     │ evidence │
       ▲                            └──────────┘     └────┬─────┘
       │                                                   │
       └───────────────────────────────────────────────────┘
                        repeat until satisfied
```

**Evals** are test cases with verifiable expectations:
```json
{
  "id": 1,
  "prompt": "Bootstrap this ML.NET repo with AI-native layer",
  "expected_output": "14 files generated with ML.NET-specific patterns",
  "expectations": [
    "AGENTS.md contains a real test example from the repo",
    "The implementer agent references Contracts.Check* pattern",
    "No existing files were overwritten"
  ]
}
```

**Grading** evaluates each expectation with evidence:
- **PASS**: Clear evidence in outputs supports the claim
- **FAIL**: No evidence, contradicting evidence, or superficial compliance

**Benchmarking** compares with-skill vs without-skill performance to prove the skill adds value. A skill that doesn't measurably improve outcomes should be rewritten or removed.

This lifecycle ensures skills are **evidence-based**, not vibes-based. A skill with 85% eval pass rate is objectively better than one with 60%.

---

### 6. AI Platform Mapping

Different AI platforms consume these artifacts differently:

| Artifact | GitHub Copilot (VS Code) | Claude Code | Copilot CLI |
|----------|------------------------|-------------|-------------|
| Foundation context | `copilot-instructions.md` (auto) | `CLAUDE.md` (auto) | `copilot-instructions.md` (auto) |
| Agents | `.github/agents/*.agent.md` (`@mention`) | `.claude/skills/*.md` | Custom agents in config |
| Prompts | `.github/prompts/*.prompt.md` (`/slash`) | Inline in CLAUDE.md | Inline in config |
| Hooks | `.github/hooks/*.sh` | `.claude/hooks/` | N/A |
| CI | `.github/workflows/*.yml` | N/A (use GitHub) | N/A (use GitHub) |
| MCP | `.vscode/mcp.json` | `.claude/mcp.json` | N/A |

---

## Why AI-Native Matters

### Without AI-Native Context (L0)
```
Developer: "Add a new tokenizer for GPT-5"
AI Agent: *writes generic C# code*
         *uses Console.WriteLine for logging*
         *uses if/throw for validation*
         *puts test in wrong directory*
         *doesn't know about IEstimator pattern*
→ Multiple rounds of correction needed
```

### With AI-Native Context (L4)
```
Developer: "Add a new tokenizer for GPT-5"
Orchestrator: 
  → Planner: analyzes existing tokenizers, produces plan with correct file locations
  → Implementer: writes code using Contracts.Check*, IChannel, following TiktokenTokenizer patterns
  → Test Writer: generates xUnit tests inheriting BaseTestClass with ITestOutputHelper
  → Reviewer: checks ML.NET pattern compliance, API compat
  → Security Reviewer: checks deserialization safety
→ Production-ready code in one pass
```

The ROI of AI-native: **fewer correction cycles, faster feature delivery, consistent quality.**
