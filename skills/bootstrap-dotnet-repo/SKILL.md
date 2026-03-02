---
name: bootstrap-dotnet-repo
description: Analyze any .NET repository and bootstrap it with a complete AI-native development layer — agents, instructions, prompts, hooks, CI, and Claude Code skills. Use when a user wants to make their .NET repo AI-native, add Copilot agents, set up Claude Code skills, or establish an AI development workflow from scratch.
---

# Bootstrap .NET Repo to AI-Native

Transform any .NET repository from AI-unaware (L0) to fully orchestrated (L4) by analyzing its stack and generating a tailored AI-native skill layer of 14+ files.

## What you produce

A complete AI-native skill layer customized to the target repo:

```
repo/
├── AGENTS.md                           ← Shared agent context
├── CLAUDE.md                           ← Claude Code context
├── .github/
│   ├── copilot-instructions.md         ← Auto-injected repo context
│   ├── agents/                         ← 6 specialized agents
│   ├── prompts/                        ← 3 slash-command prompts
│   ├── hooks/copilot-pre-commit.sh     ← Pre-commit validation
│   └── workflows/copilot-setup-steps.yml ← CI for Copilot coding agent
└── .claude/skills/                     ← Claude Code skills (optional)
```

Every file is customized using patterns discovered from the actual repo — never generic templates.

## Procedure

### Step 1: Discover the repo's DNA (read-only)

Before writing anything, run these discovery commands. Capture all output — you'll use it to customize every generated file.

**Solution structure:**
```bash
find . -name "*.sln" -maxdepth 2
find . -name "*.csproj" | head -30
echo "Source:" && find . -path "*/src/*.csproj" | wc -l
echo "Test:" && find . -path "*/test/*.csproj" | wc -l
```

**Build system:**
```bash
ls build.sh build.cmd Makefile 2>/dev/null
cat Directory.Build.props 2>/dev/null | head -30
cat global.json 2>/dev/null
```

**Test framework:**
```bash
grep -r "xunit\|nunit\|mstest\|NUnit\|MSTest" --include="*.csproj" test/ | head -10
grep -r "class.*TestBase\|class.*BaseTest\|: TestBase\|: BaseTest" --include="*.cs" test/ | head -10
grep -r "ITestOutputHelper\|TestContext" --include="*.cs" test/ | head -5
```

**Style and quality:**
```bash
cat .editorconfig 2>/dev/null | head -20
grep -r "TreatWarningsAsErrors\|EnforceCodeStyleInBuild" --include="*.props" --include="*.csproj" | head -5
grep -r "StyleCop\|Roslyn\|SonarAnalyzer" --include="*.csproj" | head -5
```

**Architecture:**
```bash
ls src/ 2>/dev/null || ls -d */ | head -20
find . -name "Program.cs" -o -name "Startup.cs" | head -10
grep -rl "interface I[A-Z]" --include="*.cs" src/ | head -10
```

**Existing AI context (don't overwrite!):**
```bash
ls AGENTS.md CLAUDE.md .github/copilot-instructions.md .github/agents/ .github/prompts/ 2>/dev/null
```

**Extract a real test example** — find the simplest, most representative test class in the repo and copy it verbatim. This is critical — it goes into AGENTS.md and the test-writer agent.

### Step 2: Classify the discoveries

Using what you found, determine these values (you'll substitute them into every generated file):

| Discovery | How to determine |
|-----------|-----------------|
| **Project name** | From `.sln` filename or `<RootNamespace>` in Directory.Build.props |
| **Build command** | `build.sh`/`build.cmd` if exists, else `dotnet build` |
| **SDK version** | From `global.json` → `sdk.version` |
| **Test framework** | xUnit if `<PackageReference Include="xunit"/>`, NUnit if `NUnit`, MSTest if `MSTest.TestFramework` |
| **Test base class** | From grep for class inheritance patterns in test files |
| **Test constructor** | `(ITestOutputHelper output)` for xUnit, `TestContext` for MSTest, none for NUnit |
| **Validation pattern** | `Contracts.Check*`, `Guard.Against.*`, `ArgumentNullException.ThrowIfNull`, or raw `if/throw` |
| **Logging pattern** | `ILogger<T>`, `IChannel`, Serilog, NLog, or none |
| **Security surfaces** | Web API → XSS/CSRF/SQLi; Library → deserialization/path traversal; ML → model loading/PII |

### Step 3: Generate all files

**CRITICAL**: Before creating each file, check if it already exists. If it does, enhance rather than replace.

Generate these files in order, substituting discovered values throughout:

1. **`.github/copilot-instructions.md`** — Project context, build/test commands, conventions, directory map, domain areas, agent/prompt links
2. **`AGENTS.md`** — Architecture ASCII diagram, domain groupings table, build pipeline steps, real test example, 5-stage pipeline pattern, artifact handoff format, safety rules
3. **`CLAUDE.md`** — Project one-liner, exact build commands, 3-5 key conventions, architecture summary, safety rules
4. **`.github/agents/orchestrator.agent.md`** — Pipeline coordinator with exact build/test commands, 5-stage pipeline, artifact handoff, references to other agents
5. **`.github/agents/planner.agent.md`** — Project coupling knowledge, domain planning considerations, public API rules
6. **`.github/agents/implementer.agent.md`** — Exact validation pattern, exact logging pattern, framework-specific patterns, style rules from .editorconfig
7. **`.github/agents/test-writer.agent.md`** — Exact test framework, real base class and constructor, real test example from the repo, assertion style
8. **`.github/agents/reviewer.agent.md`** — Project-specific quality checklist, API compat rules, performance patterns
9. **`.github/agents/security-reviewer.agent.md`** — Stack-specific attack surfaces with CWE references
10. **`.github/prompts/fix-build.prompt.md`** — Common failure modes for this specific build system
11. **`.github/prompts/add-test.prompt.md`** — Test scaffolding with exact framework and patterns
12. **`.github/prompts/review-pr.prompt.md`** — Stack-specific review checklist
13. **`.github/workflows/copilot-setup-steps.yml`** — Checkout, SDK setup, restore, build, smoke test
14. **`.github/hooks/copilot-pre-commit.sh`** — Format check, secrets scan, Console.WriteLine check

Each agent file MUST have YAML frontmatter:
```yaml
---
name: [agent-name]
description: [one-line description for triggering]
tools: [read, edit, search, terminal]
---
```

Each prompt file MUST have:
```yaml
---
mode: agent
description: [one-line description for triggering]
---
```

### Step 4: Validate

Run these checks after generating all files:

```bash
# Verify all files exist
ls AGENTS.md CLAUDE.md \
   .github/copilot-instructions.md \
   .github/agents/{orchestrator,planner,implementer,test-writer,reviewer,security-reviewer}.agent.md \
   .github/prompts/{fix-build,add-test,review-pr}.prompt.md \
   .github/workflows/copilot-setup-steps.yml \
   .github/hooks/copilot-pre-commit.sh

# Verify YAML frontmatter in agents
for f in .github/agents/*.agent.md; do head -5 "$f"; echo "---"; done

# Verify build command works (if safe to run)
# [discovered build command]

# Verify pre-commit hook is executable
chmod +x .github/hooks/copilot-pre-commit.sh
```

### Step 5: Report results

Output a structured summary:

```
# AI-Native Bootstrap Complete

## Repository Profile
- **Project**: [discovered name]
- **Language**: C# [version from global.json]
- **Framework**: [ASP.NET Core / Class Library / Console / ML]
- **Build**: [discovered command]
- **Test**: [framework] with [base class]
- **Style**: [enforcement method]
- **AI-Native Level**: L0 → L4

## Files Created
[table of all 14 files with layer and purpose]

## Customizations Applied
[list of repo-specific adaptations — these prove analysis happened]

## Next Steps
1. Review all generated files for accuracy
2. Test copilot-setup-steps.yml in GitHub Actions
3. Try @orchestrator in VS Code Copilot Chat
4. Run /fix-build if any issues arise
```

## Important rules

- **Always analyze before generating** — never use generic templates without repo-specific customization
- **Never overwrite existing files** — check first, enhance if something exists
- **Include real code examples** — copy actual test patterns from the repo into AGENTS.md and test-writer
- **Every agent must have YAML frontmatter** — or it won't be recognized by VS Code
- **Build commands must be verified** — don't guess, discover from the repo
- **Security surfaces must match the stack** — web APIs have different threats than libraries
