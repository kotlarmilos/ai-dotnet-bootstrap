---
name: ai-native-audit
description: Audit any repository's AI-native readiness level (L0–L5) and produce a gap analysis with prioritized recommendations. Use when checking if a repo is AI-native, comparing AI readiness across repos, or verifying a bootstrap was complete.
---

# AI-Native Readiness Audit

Evaluate a repository's AI-native maturity level and produce a structured gap analysis.

## What you produce

A scored audit report showing which AI-native layers are present, which are missing, and what to do about it. The output is a structured markdown report with scores per layer and prioritized recommendations.

## Procedure

### Step 1: Check Foundation Layer (L1 requirements)

Verify these files exist and contain repo-specific content (not generic placeholders):

```bash
# Check file existence
for f in .github/copilot-instructions.md CLAUDE.md AGENTS.md; do
  [ -f "$f" ] && echo "✅ $f" || echo "❌ $f MISSING"
done
```

For each file that exists, verify quality by checking:
- [ ] Contains correct, runnable build commands
- [ ] Contains correct, runnable test commands  
- [ ] Lists key directories with descriptions
- [ ] Describes coding conventions with examples
- [ ] Describes domain areas or module map
- [ ] Includes architecture diagram or structure overview

Score: 1 point per quality check that passes. Max 6.

### Step 2: Check Skill Layer (L2 requirements)

```bash
# Check prompts
for f in .github/prompts/fix-build.prompt.md .github/prompts/add-test.prompt.md .github/prompts/review-pr.prompt.md; do
  [ -f "$f" ] && echo "✅ $f" || echo "❌ $f MISSING"
done

# Check Claude skills
ls .claude/skills/*.md 2>/dev/null && echo "✅ Claude skills found" || echo "❌ No Claude skills"
```

For each skill/prompt that exists, verify:
- [ ] Has correct YAML frontmatter (`mode: agent` for prompts)
- [ ] Contains repo-specific commands (not generic)
- [ ] Includes a step-by-step workflow
- [ ] References actual patterns from the codebase

Score: 1 point per skill with quality. Max 4+.

### Step 3: Check Agent Layer (L3 requirements)

```bash
# Check agents
for a in planner implementer test-writer reviewer security-reviewer; do
  f=".github/agents/${a}.agent.md"
  [ -f "$f" ] && echo "✅ $f" || echo "❌ $f MISSING"
done
```

For each agent that exists, verify:
- [ ] Has valid YAML frontmatter with `name`, `description`, `tools`
- [ ] Contains repo-specific patterns (not generic .NET advice)
- [ ] Defines a clear structured output format
- [ ] Test-writer includes a real test example from the repo
- [ ] Implementer references the actual validation/logging patterns
- [ ] Security-reviewer covers stack-appropriate attack surfaces

Score: 1 point per agent with quality. Max 5.

### Step 4: Check Orchestration Layer (L4 requirements)

```bash
[ -f ".github/agents/orchestrator.agent.md" ] && echo "✅ Orchestrator" || echo "❌ Orchestrator MISSING"
```

If the orchestrator exists, verify:
- [ ] Defines 5-stage pipeline (plan → implement → test → review → consolidate)
- [ ] References other agent files correctly
- [ ] Defines artifact handoff format between stages
- [ ] Includes failure handling rules (stop on error)
- [ ] Includes correct build/test commands

Score: 0-5 checks passing.

### Step 5: Check Automation Layer (L5 requirements)

```bash
for f in .github/workflows/copilot-setup-steps.yml .github/hooks/copilot-pre-commit.sh; do
  [ -f "$f" ] && echo "✅ $f" || echo "❌ $f MISSING"
done
ls .vscode/mcp.json .claude/mcp.json 2>/dev/null || echo "❌ No MCP config"
```

Verify:
- [ ] CI workflow includes checkout, restore, build, and smoke test
- [ ] Pre-commit hook checks formatting and scans for secrets
- [ ] MCP config includes at least the GitHub MCP server
- [ ] Bootstrap agent exists (can reproduce the setup)

Score: 1 point per passing check. Max 4.

### Step 6: Calculate overall level

```
Total score = Foundation + Skills + Agents + Orchestration + Automation (max 24)

Level determination:
- Foundation score 0     → L0 (Unaware)
- Foundation score 1-6   → L1 (Instructed)
- Skills score > 0       → L2 (Skilled)  
- Agents score >= 3      → L3 (Agentic)
- Orchestration score >= 3 → L4 (Orchestrated)
- Automation score >= 3  → L5 (Self-Improving)

The level is the highest fully satisfied level.
```

### Step 7: Output the audit report

```markdown
# AI-Native Readiness Audit

## Repository: [owner/repo]
## Overall Level: L[0-5] — [level name]
## Total Score: [n]/24

| Layer | Level | Score | Max | Status |
|-------|-------|-------|-----|--------|
| Foundation | L1 | [n] | 6 | ✅ Complete / ⚠️ Partial / ❌ Missing |
| Skills | L2 | [n] | 4 | ✅ / ⚠️ / ❌ |
| Agents | L3 | [n] | 5 | ✅ / ⚠️ / ❌ |
| Orchestration | L4 | [n] | 5 | ✅ / ⚠️ / ❌ |
| Automation | L5 | [n] | 4 | ✅ / ⚠️ / ❌ |

## Gap Analysis

### 🔴 Missing (blocks next level)
- [file] — [what it should contain and why it matters]

### 🟡 Incomplete (has file, needs improvement)
- [file] — [specific deficiency: "uses placeholder build command" or "missing real test example"]

### 🟢 Complete
- [file] — passes all quality checks

## Recommendations (priority order)
1. [Highest-impact action to reach next level]
2. [Second highest]
3. ...

## Quick Wins
- [Changes that take < 5 minutes but improve the score]
```

## Important rules

- **Run actual commands** to verify — don't just check if files exist, verify their content is correct
- **Be specific in gap analysis** — "uses placeholder build command 'YOUR_BUILD_COMMAND'" is useful; "needs improvement" is not
- **Score consistently** — same criteria every time, same thresholds
- **Don't inflate scores** — a file with generic content gets 0 quality points even though it exists
- **Prioritize recommendations** by impact on the score and on actual AI agent effectiveness
