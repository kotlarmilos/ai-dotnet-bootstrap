# AI-Native .NET Bootstrap Toolkit

Turn any .NET repo into an AI-native development environment.

## What's In Here

Two skills for GitHub Copilot (or any AI coding agent) and the concepts behind them:

| Path | What It Does |
|------|-------------|
| `skills/bootstrap-dotnet-repo/SKILL.md` | Analyzes a .NET repo and generates 14 AI-native files (agents, prompts, hooks, CI) |
| `skills/bootstrap-dotnet-repo/dotnet-stack-detection.md` | Reference tables for .NET stack detection (test frameworks, validation, logging, security) |
| `skills/ai-native-audit/SKILL.md` | Scores a repo's AI-native readiness from L0 (nothing) to L5 (fully automated) |

## How to Use

### Bootstrap a .NET repo

Copy `skills/bootstrap-dotnet-repo/SKILL.md` into the target repo as `.github/agents/ai-native-bootstrap.agent.md`, then in VS Code Copilot Chat:

```
@ai-native-bootstrap Analyze this repo and generate the full AI-native layer
```

Or hand the SKILL.md to any AI agent (Copilot CLI, GitHub Copilot coding agent) and say "follow these instructions on this repo."

The skill will:
1. Discover the repo's build system, test framework, validation patterns, logging, architecture
2. Generate 14 files customized to what it found — not generic templates
3. Validate the output (no placeholders left, all frontmatter valid)

### Audit an existing repo

Same approach with `skills/ai-native-audit/SKILL.md`. It produces a scored report:

```
| Layer        | Score | Max | Status    |
|--------------|-------|-----|-----------|
| Foundation   | 5     | 6   | ⚠️ Partial |
| Skills       | 3     | 4   | ✅ Complete |
| Agents       | 4     | 5   | ⚠️ Partial |
| Orchestration| 5     | 5   | ✅ Complete |
| Automation   | 2     | 4   | ⚠️ Partial |
```

## What Gets Generated

The bootstrap skill produces these files, all customized to the target repo:

```
repo/
├── AGENTS.md                              ← Architecture, test patterns, pipeline
├── .github/
│   ├── copilot-instructions.md            ← Build commands, conventions, directory map
│   ├── agents/
│   │   ├── orchestrator.agent.md          ← Chains: plan → implement → test → review
│   │   ├── planner.agent.md              ← Implementation planning
│   │   ├── implementer.agent.md          ← Code writing
│   │   ├── test-writer.agent.md          ← Test generation
│   │   ├── reviewer.agent.md             ← Code review
│   │   └── security-reviewer.agent.md    ← Security scanning
│   ├── prompts/
│   │   ├── fix-build.prompt.md           ← /fix-build slash command
│   │   ├── add-test.prompt.md            ← /add-test slash command
│   │   └── review-pr.prompt.md           ← /review-pr slash command
│   ├── hooks/copilot-pre-commit.sh       ← Format + secrets check
│   └── workflows/copilot-setup-steps.yml ← CI for Copilot coding agent
└── .vscode/mcp.json                      ← MCP server config
```

## Maturity Levels

| Level | Name | You Have |
|-------|------|----------|
| L0 | Unaware | Nothing — agents fly blind |
| L1 | Instructed | `copilot-instructions.md` + `AGENTS.md` |
| L2 | Skilled | + Slash-command prompts |
| L3 | Agentic | + Specialized agents |
| L4 | Orchestrated | + Pipeline orchestrator |
| L5 | Self-Improving | + CI guardrails + hooks |

## Evals

Both skills include eval cases following the [Anthropic skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator) format:

- `skills/bootstrap-dotnet-repo/evals/evals.json` — 4 scenarios (ML.NET-style, ASP.NET API, partial existing setup, monorepo)
- `skills/ai-native-audit/evals/evals.json` — 4 scenarios (L0 empty, L1 foundation-only, L5 full bootstrap, placeholder content detection)

Each eval has a prompt, expected output description, and verifiable expectations that can be graded against the agent's actual output.

## License

MIT
