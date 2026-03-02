# Skill: Bootstrap This .NET Repo to AI-Native

## Purpose
Analyze this .NET repository and generate a complete AI-native skill layer.

## Procedure

### 1. Analyze
- Find `*.sln` and `*.csproj` files to understand solution structure
- Read `Directory.Build.props` for build configuration
- Read `global.json` for SDK version
- Scan `test/` for test framework (xUnit/NUnit/MSTest)
- Read `.editorconfig` for style rules
- Read `CONTRIBUTING.md` and `README.md` for conventions

### 2. Generate Foundation
- `CLAUDE.md` — Build commands, conventions, architecture, safety rules
- `AGENTS.md` — Architecture diagram, domain groups, test patterns, pipeline
- `.github/copilot-instructions.md` — Auto-injected context for Copilot

### 3. Generate Agents (in `.github/agents/`)
- `orchestrator.agent.md` — Pipeline coordinator
- `planner.agent.md` — Technical planning
- `implementer.agent.md` — Code writing
- `test-writer.agent.md` — Test generation
- `reviewer.agent.md` — Code review
- `security-reviewer.agent.md` — Security scanning

### 4. Generate Skills (in `.github/prompts/`)
- `fix-build.prompt.md` — Build diagnosis
- `add-test.prompt.md` — Test scaffolding
- `review-pr.prompt.md` — PR review

### 5. Generate Automation
- `.github/workflows/copilot-setup-steps.yml` — CI for Copilot agent
- `.github/hooks/copilot-pre-commit.sh` — Pre-commit validation

### 6. Validate
- Verify build commands work
- Verify test example compiles
- Verify no files were overwritten
