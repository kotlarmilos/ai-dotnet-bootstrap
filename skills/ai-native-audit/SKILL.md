---
name: ai-native-audit
description: Audit any repository's AI-native readiness and produce a scored report (L0–L5) with gap analysis. Use this skill when the user says any of these things (or similar): "check if this repo is AI-native", "audit AI readiness", "score this repo's AI maturity", "how AI-ready is this project", "compare AI readiness", "verify bootstrap completed", "what's missing from the AI setup", "rate the AI layer", "is this repo ready for Copilot agents", "grade the AI-native files", "what level is this repo", "find gaps in the agent setup", "review the AI-native configuration", "did the bootstrap work". Also triggers after a bootstrap to verify the output quality, or when comparing readiness across multiple repos.
---

# AI-Native Readiness Audit

Score a repository's AI-native maturity from L0 (nothing) to L5 (fully automated) and identify exactly what's missing or incomplete.

## Decision Tree

```
User wants to audit a repo →
│
├─ Quick check: does ANYTHING exist?
│   ├─ No AI files at all → Report L0, recommend starting with bootstrap skill
│   └─ Some files exist → Continue to full audit below
│
├─ Just bootstrapped (verifying output)
│   → Focus on quality checks: are values discovered or placeholder?
│     Does every agent have repo-specific content?
│
├─ Comparing multiple repos
│   → Run full audit on each, output side-by-side score table
│
└─ Partially set up (some files hand-written)
    → Score what exists, identify which layers are missing entirely
```

## Quick Check

```bash
# Existence check — what's there?
for f in AGENTS.md .github/copilot-instructions.md; do
  [ -f "$f" ] && echo "✅ $f" || echo "❌ $f"
done
ls .github/agents/*.agent.md 2>/dev/null || echo "❌ No agents"
ls .github/prompts/*.prompt.md 2>/dev/null || echo "❌ No prompts"
ls .github/workflows/copilot-setup-steps.yml 2>/dev/null || echo "❌ No CI workflow"
ls .github/hooks/copilot-pre-commit.sh 2>/dev/null || echo "❌ No pre-commit hook"
```

If nothing exists, report L0 and stop — no need to score empty layers.

## Scoring

### Foundation (L1) — 6 points max

Check `AGENTS.md` and `.github/copilot-instructions.md` for substance, not just existence.

```bash
# Do the files contain real build commands (not placeholders)?
grep -l "dotnet build\|dotnet test\|build\.sh\|build\.cmd" .github/copilot-instructions.md 2>/dev/null
grep -l "src/\|test/" AGENTS.md 2>/dev/null

# Are there unfilled placeholders?
grep -n '{{.*}}\|YOUR_.*_HERE\|TODO:\|FIXME:' AGENTS.md .github/copilot-instructions.md 2>/dev/null
```

Award 1 point each for:
- Correct, runnable build commands (verified by reading them — would they actually work?)
- Correct, runnable test commands
- Key directories listed with descriptions
- Coding conventions with concrete examples (not "follow best practices")
- Domain areas or module map
- Architecture structure (directory tree or diagram)

**Passing example** — a `copilot-instructions.md` that says:
```
## Build
./build.sh -c Release
## Test
dotnet test test/MyApp.Tests --no-build -c Release
```

**Failing example** — one that says:
```
## Build
dotnet build
## Test
dotnet test
```
...when the repo actually uses `build.sh` with custom targets. Generic commands that happen to work by accident still get the point, but only if they actually produce correct results.

### Skills (L2) — 4 points max

```bash
for f in .github/prompts/{fix-build,add-test,review-pr}.prompt.md; do
  [ -f "$f" ] && head -3 "$f" | grep -q "mode: agent" && echo "✅ $f" || echo "❌ $f"
done
```

1 point for each prompt that has correct `mode: agent` frontmatter AND contains repo-specific content (references actual build commands, test framework, or project paths — not just generic advice).

**Passing**: `fix-build.prompt.md` that says "run `./build.sh`, classify the error..." referencing the repo's actual build system.

**Failing**: A prompt that says "run the build command and fix any errors" with no specifics.

Extra point for a 4th prompt beyond the standard three (e.g., `add-migration.prompt.md` for EF Core repos).

### Agents (L3) — 5 points max

```bash
for a in planner implementer test-writer reviewer security-reviewer; do
  f=".github/agents/${a}.agent.md"
  [ -f "$f" ] && head -3 "$f" | grep -q "name:" && echo "✅ $a" || echo "❌ $a"
done
```

1 point each for agents with valid YAML frontmatter (`name`, `description`, `tools`) AND repo-specific substance. Verify:

- **test-writer** — contains a real test example from the repo (not invented), names the correct test framework
- **implementer** — references the actual validation pattern (`Contracts.Check`? `Guard.Against`? `ThrowIfNull`?) and logging framework
- **security-reviewer** — covers threats appropriate to the project type (Web API → XSS/CSRF/SQLi, library → deserialization/path traversal)

**Passing**: A test-writer agent that includes an actual xUnit test class copied from the repo with `ITestOutputHelper` constructor injection.

**Failing**: A test-writer agent that says "write tests using the project's test framework" without naming it or showing an example.

### Orchestration (L4) — 5 points max

```bash
[ -f ".github/agents/orchestrator.agent.md" ] && echo "✅ Orchestrator" || echo "❌ No orchestrator"
```

1 point each for:
- Defines the 5-stage pipeline: plan → implement → test → review → consolidate
- References other agent files by path (e.g., "ask @planner" or "see `.github/agents/planner.agent.md`")
- Defines artifact handoff format between stages
- Has failure handling (what to do when a stage fails — the answer should be "stop")
- Includes correct build/test commands verified against what the repo actually uses

### Automation (L5) — 4 points max

```bash
[ -f ".github/workflows/copilot-setup-steps.yml" ] && echo "✅ CI" || echo "❌ No CI"
[ -f ".github/hooks/copilot-pre-commit.sh" ] && echo "✅ Hook" || echo "❌ No hook"
[ -f ".vscode/mcp.json" ] && echo "✅ MCP" || echo "❌ No MCP"
```

1 point each for:
- CI workflow with checkout + restore + build + smoke test (verify the commands match the repo)
- Pre-commit hook with format check + secrets scan
- MCP config (`.vscode/mcp.json`) with at least GitHub MCP server
- Bootstrap agent that can reproduce the setup from scratch

## Level Determination

The level is the **highest fully satisfied level**, not cumulative:

| Condition | Level | Name |
|-----------|-------|------|
| Foundation = 0 | L0 | Unaware |
| Foundation ≥ 1 | L1 | Instructed |
| Foundation ≥ 4 AND Skills ≥ 2 | L2 | Skilled |
| Above AND Agents ≥ 3 | L3 | Agentic |
| Above AND Orchestration ≥ 3 | L4 | Orchestrated |
| Above AND Automation ≥ 3 | L5 | Self-Improving |

A repo with perfect L3 but no orchestrator is L3, not L4. Levels must be satisfied in order.

## Output Format

Produce this exact structure:

```markdown
# AI-Native Audit: [repo name]

## Level: L[0-5] — [level name] — Score: [n]/24

| Layer         | Score | Max | Status |
|---------------|-------|-----|--------|
| Foundation    | [n]   | 6   | ✅/⚠️/❌ |
| Skills        | [n]   | 4   | ✅/⚠️/❌ |
| Agents        | [n]   | 5   | ✅/⚠️/❌ |
| Orchestration | [n]   | 5   | ✅/⚠️/❌ |
| Automation    | [n]   | 4   | ✅/⚠️/❌ |

Status: ✅ = full points, ⚠️ = partial, ❌ = zero

## Missing
- [file path] — [what it should contain]

## Incomplete
- [file path] — [specific deficiency, e.g. "test-writer agent uses generic xUnit example instead of a real test from the repo"]

## Next Steps
1. [highest-impact action to reach next level]
2. [second highest]
3. [third]
```

## Common Pitfalls

❌ **Inflating scores for existing-but-empty files** — A `copilot-instructions.md` with 3 lines of boilerplate is not L1
✅ Read the content. Score the substance, not the file count.

❌ **Giving credit for generic content** — "Use best practices" is not a convention
✅ Conventions need concrete examples: "PascalCase for public, `_camelCase` for private fields"

❌ **Only checking file existence** — `ls` tells you nothing about quality
✅ `grep` inside files. Verify build commands would actually work. Check for placeholders.

❌ **Scoring agents without reading them** — Frontmatter alone doesn't earn a point
✅ Read the body. Does the test-writer include a real test? Does the security reviewer match the stack type?

❌ **Vague gap analysis** — "needs improvement" is useless feedback
✅ Be specific: "test-writer agent says 'xUnit' but the repo uses NUnit — all test examples are wrong"
