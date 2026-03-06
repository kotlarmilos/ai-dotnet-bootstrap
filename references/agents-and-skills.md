# Agents and Skills Catalog

What to install, when it's useful, and how to configure each piece.

## Agents (How AI Works on Your Repo)

Agents are multi-step workflows. They orchestrate multiple tools and skills.

### pr.md — PR Workflow Agent

**Always install.** Every repo benefits from structured PR review.

4-phase workflow:
1. **Pre-Flight** — Read issue/PR, understand the problem
2. **Gate** — Verify tests exist and catch the issue
3. **Fix** — Multi-model exploration: invoke `try-fix` with multiple AI models sequentially, each generating an independent fix idea, then cross-pollinate and select the best
4. **Report** — Summarize findings, post comment, create PR

The PR agent is split across multiple files:
- `pr.md` — Phases 1-2 (Pre-Flight, Gate)
- `pr/post-gate.md` — Phases 3-4 (multi-model Fix, Report)
- `pr/SHARED-RULES.md` — Common rules including model configuration

**Templates**: `assets/templates/pr.md`, `assets/templates/pr/post-gate.md`, `assets/templates/pr/SHARED-RULES.md`

**Placeholders**:
- `{{BUILD_COMMAND}}` — How to build
- `{{TEST_COMMAND}}` — How to run tests
- `{{FORMAT_COMMAND}}` — How to format code
- `{{DEFAULT_BRANCH}}` — Default branch name
- `{{MODEL_COUNT}}` — Number of AI models to use for try-fix
- `{{MODEL_TABLE}}` — Markdown table of models (order + model ID)

### write-tests-agent.md — Test Writer

**Install if repo has tests.** Routes to the correct test project and follows conventions.

**Template**: `assets/templates/write-tests-agent.md`

**Placeholders**:
- `{{TEST_FRAMEWORK}}` — xunit, nunit, or mstest
- `{{TEST_PROJECT_PATHS}}` — List of test project paths
- `{{TEST_COMMAND}}` — How to run tests

### learn-from-pr.md — Self-Improvement Agent

**Always install.** Closes the improvement loop by extracting lessons from PRs and applying them to instruction files.

**Template**: `assets/templates/learn-from-pr.md` — Minimal configuration needed.

---

## Skills (What AI Can Do)

Skills are focused capabilities. Each does one thing well.

### Configured Skills (need your repo's commands)

| Skill | Template | Key Placeholders | Install When |
|-------|----------|-----------------|--------------|
| **try-fix** | `assets/templates/try-fix.md` | BUILD_COMMAND, TEST_COMMAND | Always — enables fix→test→report cycle |
| **run-tests** | `assets/templates/run-tests.md` | TEST_COMMAND_*, TEST_PROJECTS_TABLE | Always — agents need to run tests |
| **pr-build-status** | `assets/core/pr-build-status.md` | CI_SYSTEM, PIPELINE_NAMES | Always — the CI feedback loop |
| **verify-tests-fail** | `assets/templates/verify-tests-fail.md` | BUILD_COMMAND, TEST_COMMAND | If repo has bug-fix PRs |

### Universal Skills (copy as-is)

| Skill | Source | What It Does |
|-------|--------|-------------|
| **pr-finalize** | `assets/skills/pr-finalize.md` | Verifies PR title/description match implementation |
| **issue-triage** | `assets/skills/issue-triage.md` | Queries and triages open issues |
| **find-reviewable-pr** | `assets/skills/find-reviewable-pr.md` | Finds PRs that need review |
| **learn-from-pr** | `assets/skills/learn-from-pr.md` | Analyzes PRs for lessons (read-only) |
| **ai-summary-comment** | `assets/skills/ai-summary-comment.md` | Posts unified progress comments on PRs |

### Universal Workflows (copy as-is)

| Workflow | Source | What It Does |
|----------|--------|-------------|
| **find-similar-issues** | `assets/workflows/find-similar-issues.yml` | AI duplicate detection on new issues |
| **inclusive-heat-sensor** | `assets/workflows/inclusive-heat-sensor.yml` | Detects heated language in comments |

---

## Agentic Workflows (require gh-aw)

These are autonomous workflows compiled and run via `gh-aw`. They require separate setup — use the `setup-repo-health-check` skill to deploy.

| Workflow | Template | What It Does | Install When |
|----------|----------|-------------|--------------|
| **repo-health-check** | `assets/templates/repo-health-check.md` | Daily health dashboard — collects data on issues, PRs, CI; diffs against previous run; updates pinned dashboard issue | Active repos with CI |
| **repo-health-investigate** | `assets/templates/repo-health-investigate.md` | Deep-dive on critical findings — dispatched by orchestrator for root cause analysis | With health-check |
| **repo-health-groom** | `assets/templates/repo-health-groom.md` | Dashboard maintenance — links investigation results, hides stale comments, enforces sanity | With health-check |

**Setup skill**: `assets/skills/setup-repo-health-check.md` — Interactive skill that walks through repo discovery, baseline creation, template configuration, and compilation.

**Reference**: `references/repo-health-check.md` — Full architecture guide.

---

## Installation

### For Templates

1. Read the template from `assets/templates/`
2. Replace all `{{PLACEHOLDER}}` values with analysis results
3. Create the directory: `mkdir -p .github/skills/SKILL_NAME`
4. Write the filled template to `.github/skills/SKILL_NAME/SKILL.md`

### For Universal Files

```bash
TOOLKIT="path/to/ai-native-dotnet-bootstrap"
TARGET=".github"

# Skills — each gets its own directory
for skill in pr-finalize issue-triage find-reviewable-pr learn-from-pr ai-summary-comment; do
  mkdir -p "$TARGET/skills/$skill"
  cp "$TOOLKIT/assets/skills/$skill.md" "$TARGET/skills/$skill/SKILL.md"
done

# Workflows
cp "$TOOLKIT/assets/workflows/"*.yml "$TARGET/workflows/"
```

### Skip Existing Files

Before copying, check if the target already exists:
```bash
if [ -f "$TARGET/skills/pr-finalize/SKILL.md" ]; then
  echo "SKIP: pr-finalize already exists"
fi
```

Never overwrite without asking.

---

## Choosing What to Install

### Minimum Viable (every repo) — See Required tier

- `copilot-instructions.md` / AGENTS.md (generated) — `assets/core/AGENTS.md` (place at repo root)
- `copilot-setup-steps.yml` (CI feedback) — `assets/core/copilot-setup-steps.yml`
- `pr-build-status` skill (CI feedback) — `assets/core/pr-build-status.md`

### Recommended (active OSS repo)

Everything above, plus:
- Scoped instructions for test projects
- `try-fix` skill
- `write-tests-agent`
- `pr-finalize` skill
- `find-similar-issues` workflow
- `learn-from-pr` skill

### Full (high-traffic repo)

Everything above, plus:
- `issue-triage` skill
- `find-reviewable-pr` skill
- `ai-summary-comment` skill
- `inclusive-heat-sensor` workflow
- `verify-tests-fail` skill
- `release-notes` prompt
