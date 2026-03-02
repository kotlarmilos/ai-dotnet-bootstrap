# AI-Native .NET Bootstrap Toolkit

> Turn any .NET repository from AI-unaware to fully orchestrated — with agents, skills, prompts, CI, and Claude Code integration.

## What Is This?

A complete, standalone toolkit for transforming any .NET repository into an **AI-native** development environment. AI-native means the repo contains machine-readable context, behavioral instructions, and composable skills that enable AI coding agents (GitHub Copilot, Claude Code, Copilot CLI) to plan, implement, test, review, and ship code with minimal human guidance.

## Concepts

Read **[docs/ai-native-definitions.md](docs/ai-native-definitions.md)** for formal definitions of:

| Concept | Definition |
|---------|-----------|
| **AI-Native** | A repo structured so AI agents operate as first-class participants |
| **Agent** | A specialized AI persona with a defined role, tools, and output format |
| **Skill** | A reusable, composable, evaluable unit of AI capability |
| **Layer** | One of 5 architectural tiers (Foundation → Skills → Agents → Orchestration → Automation) |
| **Pipeline** | The 5-stage agent workflow: Plan → Implement → Test → Review → Consolidate |

### Maturity Model (L0–L5)

| Level | Name | What You Have |
|-------|------|---------------|
| **L0** | Unaware | No AI context. Agents fly blind. |
| **L1** | Instructed | `copilot-instructions.md` + `CLAUDE.md` + `AGENTS.md` |
| **L2** | Skilled | + Slash-command prompts (`/fix-build`, `/add-test`, `/review-pr`) |
| **L3** | Agentic | + Specialized agents (`@planner`, `@implementer`, `@test-writer`, `@reviewer`, `@security-reviewer`) |
| **L4** | Orchestrated | + Pipeline orchestrator with artifact handoff between stages |
| **L5** | Self-Improving | + CI feedback loops, automated guardrails, pre-commit hooks |

## Repository Structure

```
ai-native-dotnet-bootstrap/
├── README.md                          ← You are here
├── docs/
│   └── ai-native-definitions.md       ← Formal definitions of all concepts
├── skills/                            ← Anthropic-format skill packages
│   ├── bootstrap-dotnet-repo/         ← Skill: bootstrap any .NET repo
│   │   ├── SKILL.md                   ← Main skill instructions
│   │   ├── agents/grader.md           ← Grader subagent
│   │   ├── evals/evals.json           ← 4 test cases, 30 expectations
│   │   └── references/                ← .NET stack detection tables
│   └── ai-native-audit/              ← Skill: audit AI-native readiness
│       ├── SKILL.md                   ← Audit procedure + scoring rubric
│       └── evals/evals.json           ← 4 test cases, 22 expectations
└── templates/                         ← Portable template files
    ├── agents/                        ← 6 agent templates
    ├── prompts/                       ← 3 prompt templates
    ├── hooks/                         ← Pre-commit hook template
    ├── workflows/                     ← CI workflow template
    ├── vscode/                        ← MCP config template
    └── claude/                        ← CLAUDE.md + skills templates
```

## Quick Start

### Option A: Use the Bootstrap Skill (Claude Code)

```bash
# Install the skill
cp -r skills/bootstrap-dotnet-repo ~/.claude/skills/

# In your .NET repo, ask Claude Code:
# "Use the bootstrap-dotnet-repo skill to make this repo AI-native"
```

### Option B: Use the Bootstrap Agent (VS Code Copilot)

Copy `skills/bootstrap-dotnet-repo/SKILL.md` into your repo as `.github/agents/ai-native-bootstrap.agent.md`, then:
```
@ai-native-bootstrap Analyze this repo and generate the full AI-native layer
```

### Option C: Manual Setup Using Templates

1. Copy the files from `templates/` into your target repo's `.github/` directory
2. Replace all `{{PLACEHOLDER}}` values with your repo's actual values (see [Placeholder Reference](#placeholder-reference) below)
3. Run the audit skill to verify completeness

## What Gets Generated

The toolkit generates **14+ files** across 5 layers, all customized to the target repo:

| # | File | Layer | Purpose |
|---|------|-------|---------|
| 1 | `AGENTS.md` | Foundation | Shared agent context, architecture, test patterns |
| 2 | `CLAUDE.md` | Foundation | Claude Code context |
| 3 | `.github/copilot-instructions.md` | Foundation | Auto-injected Copilot context |
| 4 | `.github/agents/orchestrator.agent.md` | Orchestration | Pipeline coordinator |
| 5 | `.github/agents/planner.agent.md` | Agents | Technical planning |
| 6 | `.github/agents/implementer.agent.md` | Agents | Code writing |
| 7 | `.github/agents/test-writer.agent.md` | Agents | Test generation |
| 8 | `.github/agents/reviewer.agent.md` | Agents | Code review |
| 9 | `.github/agents/security-reviewer.agent.md` | Agents | Security scanning |
| 10 | `.github/prompts/fix-build.prompt.md` | Skills | Build diagnosis |
| 11 | `.github/prompts/add-test.prompt.md` | Skills | Test scaffolding |
| 12 | `.github/prompts/review-pr.prompt.md` | Skills | PR review |
| 13 | `.github/workflows/copilot-setup-steps.yml` | Automation | CI for Copilot coding agent |
| 14 | `.github/hooks/copilot-pre-commit.sh` | Automation | Pre-commit validation |

## Placeholder Reference

Every template contains `{{PLACEHOLDER}}` values. Here are the key ones:

| Placeholder | How to Determine | Example |
|-------------|-----------------|---------|
| `{{PROJECT_NAME}}` | `.sln` filename or `<RootNamespace>` | `Contoso.WebApi` |
| `{{BUILD_COMMAND}}` | `build.sh` if exists, else `dotnet build` | `./build.sh` |
| `{{TEST_FRAMEWORK}}` | Check `*.csproj` for xunit/NUnit/MSTest refs | `xUnit` |
| `{{TEST_BASE_CLASS}}` | Grep test files for inheritance pattern | `BaseTestClass` |
| `{{VALIDATION_PATTERN}}` | Grep source for validation approach | `Contracts.CheckValue(x, nameof(x));` |
| `{{LOGGING_PATTERN}}` | Grep source for logging approach | `_logger.LogInformation("msg");` |
| `{{SECURITY_SURFACES}}` | Based on project type (web/library/ML) | `XSS, CSRF, SQL injection` |

Full placeholder list with detection guide: see `skills/bootstrap-dotnet-repo/references/dotnet-stack-detection.md`

## AI Platform Compatibility

| Platform | Foundation | Agents | Skills | CI |
|----------|-----------|--------|--------|-----|
| **GitHub Copilot (VS Code)** | `copilot-instructions.md` ✅ | `.github/agents/` ✅ | `.github/prompts/` ✅ | workflows ✅ |
| **Claude Code** | `CLAUDE.md` ✅ | `.claude/skills/` ✅ | Inline ✅ | N/A |
| **Copilot CLI** | `copilot-instructions.md` ✅ | Custom agents ✅ | Inline | N/A |
| **Copilot Coding Agent** | `copilot-instructions.md` ✅ | N/A | N/A | `copilot-setup-steps.yml` ✅ |

## Skill Evaluation

Both skills follow the [Anthropic skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator) format with evals:

| Skill | Test Cases | Expectations | Purpose |
|-------|-----------|-------------|---------|
| `bootstrap-dotnet-repo` | 4 | 30 | Verifies correct repo analysis and customized file generation |
| `ai-native-audit` | 4 | 22 | Verifies correct scoring and gap analysis across L0–L5 |

Run evals with the Anthropic skill-creator workflow:
1. Draft the skill → 2. Run test prompts → 3. Grade with expectations → 4. Improve → 5. Repeat

## Examples

### ASP.NET Core Web API
```
PROJECT_NAME=Contoso.WebApi  BUILD_COMMAND="dotnet build"
TEST_FRAMEWORK=xUnit  VALIDATION=Guard.Against.Null  LOGGING=ILogger<T>
SECURITY=XSS, CSRF, SQL injection, auth bypass
```

### .NET Class Library
```
PROJECT_NAME=MyLib  BUILD_COMMAND="dotnet build"
TEST_FRAMEWORK=NUnit  VALIDATION=ArgumentNullException.ThrowIfNull
SECURITY=deserialization, path traversal, resource exhaustion
```

### ML.NET (reference implementation)
```
PROJECT_NAME=ML.NET  BUILD_COMMAND="./build.sh"
TEST_FRAMEWORK=xUnit  TEST_BASE=BaseTestClass  VALIDATION=Contracts.Check*
LOGGING=IChannel  SECURITY=native interop, model deserialization, PII
```

## License

MIT — see [LICENSE](LICENSE)

## Contributing

1. Fork this repo
2. Add or improve templates/skills
3. Add evals for new skills
4. Submit a PR with before/after audit scores showing improvement
