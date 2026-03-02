---
name: bootstrap-dotnet-repo
description: Analyze any .NET repository and generate a complete AI-native development layer — GitHub Copilot agents, slash-command prompts, pre-commit hooks, and CI workflows — all customized to the repo's actual patterns. Use this skill when the user says any of these things (or similar): "make this repo AI-native", "add Copilot agents to this C# project", "set up .github/agents", "generate AGENTS.md", "create copilot-instructions.md", "bootstrap AI development workflow", "prepare this repo for AI coding agents", "add GitHub Copilot prompts", "set up agent pipeline for this dotnet project", "I want AI agents that know how to build and test this repo", "create .github/prompts for this project", "add orchestrator agent", "set up pre-commit hook for Copilot", "configure Copilot coding agent CI". Also triggers when the user has a .NET repo open and asks to "add AI development infrastructure", "make this AI-ready", or "set up agents".
---

# .NET AI-Native Bootstrap

Analyze a .NET repo and generate 14 AI-native files — agents, prompts, hooks, CI — each customized to the repo's actual build system, test framework, validation patterns, and architecture.

For .NET stack detection tables (test frameworks, validation patterns, logging, security surfaces), see `dotnet-stack-detection.md`.

## Decision Tree

```
User wants to bootstrap a .NET repo →
│
├─ Repo has NO AI files yet
│   → Full bootstrap: discover → generate all 14 files → validate
│
├─ Repo has SOME files (e.g., AGENTS.md exists but no agents/)
│   → Discover what's there, generate only what's missing, enhance existing
│
├─ Repo is already fully bootstrapped
│   → Use the ai-native-audit skill instead to score and find gaps
│
├─ Monorepo with multiple .NET solutions
│   → Run discovery per solution, single AGENTS.md with domain groupings,
│     agents reference all solutions
│
└─ Not a .NET repo
    → Stop. This skill is .NET-specific.
```

## Discovery

Run these commands and capture the results. Every generated file depends on what you find here.

```bash
# Solutions and projects
find . -name "*.sln" -maxdepth 2
find . -name "*.csproj" | head -20

# SDK version
cat global.json 2>/dev/null

# Build system
ls build.sh build.cmd Makefile 2>/dev/null
cat Directory.Build.props 2>/dev/null | head -30

# Test framework (→ determines test-writer agent content)
grep -r "xunit\|nunit\|mstest\|NUnit\|MSTest" --include="*.csproj" test/ | head -10
grep -r ": BaseTest\|: TestBase\|: TestFixture" --include="*.cs" test/ | head -10
grep -r "ITestOutputHelper\|TestContext" --include="*.cs" test/ | head -5

# Validation patterns (→ determines implementer agent content)
grep -rn "Contracts\.Check\|Guard\.Against\|ThrowIfNull" --include="*.cs" src/ | head -5

# Logging (→ implementer and reviewer agents)
grep -rn "ILogger\|IChannel\|Serilog\|NLog" --include="*.cs" src/ | head -5

# Style enforcement (→ copilot-instructions.md, pre-commit hook)
cat .editorconfig 2>/dev/null | head -20
grep -r "TreatWarningsAsErrors\|EnforceCodeStyleInBuild" --include="*.props" --include="*.csproj" | head -5

# Architecture (→ AGENTS.md directory map)
ls src/ 2>/dev/null || ls -d */ | head -20
find . -name "Program.cs" -o -name "Startup.cs" | head -10

# What already exists (→ never overwrite)
ls AGENTS.md .github/copilot-instructions.md .github/agents/ .github/prompts/ 2>/dev/null
```

### Extract a real test example

Find the simplest passing test class and copy it **verbatim**. This goes into `AGENTS.md` and the `test-writer` agent as the canonical example. Do not fabricate one.

```bash
# Find short test files
find test/ -name "*Test*.cs" -exec wc -l {} \; 2>/dev/null | sort -n | head -5
```

## Generation

Generate these 14 files. Check if each exists first — enhance, don't replace.

### `AGENTS.md` (repo root)

The shared context file. Every agent reads this. Example of what good content looks like:

```markdown
# MyProject

## Architecture
\```
src/
├── MyProject.Core/          ← Domain models, interfaces
├── MyProject.Api/           ← ASP.NET Web API, controllers
└── MyProject.Infrastructure/ ← EF Core, external services
test/
├── MyProject.Core.Tests/    ← Unit tests (xUnit)
└── MyProject.Api.Tests/     ← Integration tests
\```

## Build
\```bash
dotnet build MyProject.sln
\```

## Test
\```bash
dotnet test test/MyProject.Core.Tests --no-build
\```

## Test Patterns
\```csharp
public class OrderServiceTests : TestBase
{
    private readonly OrderService _sut;

    public OrderServiceTests(ITestOutputHelper output) : base(output)
    {
        _sut = new OrderService(MockLogger);
    }

    [Fact]
    public void CreateOrder_WithValidInput_ReturnsOrder()
    {
        var result = _sut.Create(new OrderRequest("item-1", 2));
        Assert.NotNull(result);
        Assert.Equal("item-1", result.ItemId);
    }
}
\```

## Agent Pipeline
Plan → Implement → Test → Review → Consolidate

Each stage produces a structured artifact consumed by the next. If any stage
fails, stop. Public API changes require human review.

## Safety
- Never commit secrets, connection strings, or API keys
- Run the full test suite before marking work complete
- Do not modify files outside the scope of the current task
```

Replace every value above with what you actually discovered. The test example must be a real test from the repo.

### `.github/copilot-instructions.md`

Auto-injected into every Copilot conversation. Keep it under 100 lines. Example:

```markdown
# MyProject — Copilot Instructions

MyProject is an ASP.NET Core 8 API for order management with a clean architecture.

## Build & Test
\```bash
dotnet build MyProject.sln
dotnet test --no-build
\```

## Conventions
- C# 12, .NET 8, nullable enabled, warnings-as-errors
- Guard clauses: `ArgumentNullException.ThrowIfNull(value)`
- Logging: `ILogger<T>` via DI
- Tests: xUnit + FluentAssertions, inherit from `TestBase`
- Naming: PascalCase for public members, `_camelCase` for private fields

## Key Directories
| Path | Purpose |
|------|---------|
| `src/MyProject.Core/` | Domain models and interfaces |
| `src/MyProject.Api/` | Controllers, middleware |
| `test/` | xUnit test projects |

## Agents
See `.github/agents/` for specialized agents: orchestrator, planner,
implementer, test-writer, reviewer, security-reviewer.
```

### `.github/agents/*.agent.md`

Each agent file needs YAML frontmatter with `name`, `description`, and `tools`. Here's what makes each agent work:

**`orchestrator.agent.md`** — Coordinates the 5-stage pipeline. Must contain the exact build and test commands (discovered, not guessed). References other agent files by path. Defines halt conditions: stage failure → stop, public API change → human review.

Example of the critical section:
```markdown
## Pipeline

1. **Plan** — Ask @planner to analyze the request and produce an implementation plan
2. **Implement** — Pass the plan to @implementer to write the code
3. **Test** — Ask @test-writer to generate tests for all new/changed code
4. **Review** — @reviewer checks for correctness and pattern compliance
5. **Consolidate** — Summarize changes, list files modified, confirm build passes

## Build Verification (run between each stage)
\```bash
dotnet build MyProject.sln
dotnet test --no-build
\```
If either command fails, stop and fix before proceeding.
```

**`planner.agent.md`** — Read-only (tools: `[read, search]`). Produces implementation plan with file-change table, dependency order, risk assessment. Knows which projects couple to which.

**`implementer.agent.md`** — The repo's coding patterns must be in this file. If the repo uses `Contracts.Check`, this agent says "use Contracts.Check". If it uses `ILogger<T>`, this agent says "inject ILogger<T>". Builds after each file change.

**`test-writer.agent.md`** — Must include the real test example from the repo. Specifies exact framework (xUnit/NUnit/MSTest), base class, constructor pattern, assertion style. Never modifies source code, only creates test files.

**`reviewer.agent.md`** — Read-only. Checks: correctness, pattern compliance, backward compatibility for public APIs, performance (no allocations in hot paths), thread safety (shared state). Outputs structured report with `file:line` references.

**`security-reviewer.agent.md`** — Threat model must match the project type. See `dotnet-stack-detection.md` for the mapping. Cites CWE identifiers. Example: a Web API project gets XSS (CWE-79), CSRF (CWE-352), SQLi (CWE-89); a class library gets deserialization (CWE-502), path traversal (CWE-22).

### `.github/prompts/*.prompt.md`

Slash-command prompts. Each needs `mode: agent` frontmatter:

```yaml
---
mode: agent
description: "[what it does]"
---
```

**`fix-build.prompt.md`** — Runs the build, captures the error, classifies it (missing SDK? NuGet restore needed? format violation? native dependency? first-build setup?), applies the fix, rebuilds to confirm.

**`add-test.prompt.md`** — Takes a source file, finds its test project, reads 2–3 existing tests for style, generates a new test class with the correct base class and constructor pattern, builds and runs it.

**`review-pr.prompt.md`** — Reads the diff, checks pattern compliance, API backward compatibility, test coverage for changed code, security surfaces, produces a structured report.

### `.github/workflows/copilot-setup-steps.yml`

CI environment for the Copilot coding agent. Use discovered values:

```yaml
name: "Copilot Setup Steps"
on: workflow_dispatch
jobs:
  copilot-setup-steps:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive
      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "[from global.json]"
      - name: Restore
        run: dotnet restore
      - name: Build
        run: "[discovered build command]"
      - name: Smoke Test
        run: "dotnet test [fastest test project] --no-build"
```

### `.github/hooks/copilot-pre-commit.sh`

Format check + secrets scan for staged C# files:

```bash
#!/bin/bash
set -e
STAGED=$(git diff --cached --name-only --diff-filter=ACM | grep '\.cs$' || true)
[ -z "$STAGED" ] && exit 0

echo "Checking formatting..."
dotnet format --verify-no-changes --include $STAGED 2>/dev/null || {
    echo "❌ Run 'dotnet format' to fix."; exit 1
}

echo "Scanning for secrets..."
PATTERN='(password|secret|api[_-]?key|token|connectionstring)\s*=\s*"[^"]+'
for f in $STAGED; do
    grep -iEn "$PATTERN" "$f" 2>/dev/null && { echo "❌ Secret in $f"; exit 1; }
done

echo "✅ Pre-commit passed."
```

## Validation

After generating everything, verify:

```bash
# All 14 files exist
ls AGENTS.md \
   .github/copilot-instructions.md \
   .github/agents/{orchestrator,planner,implementer,test-writer,reviewer,security-reviewer}.agent.md \
   .github/prompts/{fix-build,add-test,review-pr}.prompt.md \
   .github/workflows/copilot-setup-steps.yml \
   .github/hooks/copilot-pre-commit.sh

# Agent frontmatter is valid YAML
for f in .github/agents/*.agent.md; do
  head -4 "$f" | grep -q "name:" && echo "✅ $f" || echo "❌ $f missing frontmatter"
done

# Prompt frontmatter has mode: agent
for f in .github/prompts/*.prompt.md; do
  head -3 "$f" | grep -q "mode: agent" && echo "✅ $f" || echo "❌ $f missing mode"
done

# No placeholders left
grep -rn '{{.*}}\|YOUR_.*\|\[from .*\]\|\[discovered' .github/ AGENTS.md 2>/dev/null && \
  echo "❌ Placeholders remain" || echo "✅ No placeholders"

# Hook is executable
chmod +x .github/hooks/copilot-pre-commit.sh
```

## Common Pitfalls

❌ **Guessing build commands** — Writing `dotnet build` when the repo uses `./build.sh`
✅ Always run the discovery commands. If `build.sh` exists, use it.

❌ **Fabricating test examples** — Inventing a test class that looks plausible
✅ Find a real test with `find test/ -name "*Test*.cs"` and copy it verbatim.

❌ **Generic security surfaces** — Every agent gets the same XSS/CSRF checklist
✅ Match threats to project type. A class library has deserialization risks, not CSRF. See `dotnet-stack-detection.md`.

❌ **Overwriting existing files** — Replacing a hand-written AGENTS.md with generated content
✅ Check first. If the file exists, read it and enhance what's already there.

❌ **Leaving placeholders** — Files containing `{{PROJECT_NAME}}` or `[discovered build command]`
✅ Every value in every file must come from the discovery phase. If you can't discover it, investigate — don't placeholder it.

❌ **Monorepo tunnel vision** — Only bootstrapping one solution in a multi-solution repo
✅ Discover all `.sln` files. AGENTS.md covers the whole repo; agents reference all solutions.

## Quick Reference

| Discovery Finding | Affects These Files |
|-------------------|---------------------|
| `build.sh` / `build.cmd` exists | copilot-instructions, orchestrator, CI workflow |
| xUnit / NUnit / MSTest detected | test-writer agent, AGENTS.md test patterns |
| `Contracts.Check` / `Guard.Against` / `ThrowIfNull` | implementer agent |
| `ILogger<T>` / `Serilog` / `IChannel` | implementer agent, reviewer agent |
| ASP.NET endpoints found | security-reviewer (web threat model) |
| Class library only | security-reviewer (library threat model) |
| `.editorconfig` present | copilot-instructions conventions, pre-commit hook |
| `global.json` SDK version | CI workflow `dotnet-version` |
| Multiple `.sln` files | AGENTS.md structure, all agents need multi-solution awareness |
