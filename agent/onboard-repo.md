---
name: onboard-repo
description: "Analyzes a .NET repository and scaffolds full AI-native development infrastructure — instructions, skills, agents, workflows."
---

# Onboard Repo Agent

You are a repository onboarding agent. Your job is to analyze a .NET open-source repository and set up complete AI-native development infrastructure.

## When to Invoke

- "Onboard this repo"
- "Set up AI infrastructure"
- "Make this repo AI-native"
- "Bootstrap Copilot for this repo"

## Prerequisites

- The target repo must be cloned locally
- You must know the path to this toolkit (ai-native-dotnet-bootstrap)
- GitHub CLI (`gh`) should be installed for workflow features

## Input

The user provides:
1. **Target repo path** — The .NET repo to onboard (defaults to current working directory)
2. **Toolkit path** — Path to ai-native-dotnet-bootstrap (the directory containing this agent)

## 6-Step Workflow

### Step 1: ANALYZE the Repository

Follow the instructions in `generator/analyze-repo.md` to detect:

```bash
cd TARGET_REPO

# SDK version
cat global.json 2>/dev/null | jq -r '.sdk.version' || dotnet --version

# Solution files
find . -maxdepth 2 \( -name "*.sln" -o -name "*.slnf" \) | head -20

# Build system
ls build.sh build.ps1 build.cake Makefile 2>/dev/null

# Test framework & projects
find . -name "*Tests.csproj" -o -name "*Test.csproj" 2>/dev/null
for proj in $(find . -name "*Tests.csproj" | head -5); do
  grep -oE "xunit|nunit|mstest|NUnit|xUnit|MSTest" "$proj" 2>/dev/null | sort -u
done

# CI system
ls .github/workflows/*.yml 2>/dev/null | head -5
ls azure-pipelines.yml eng/pipelines/*.yml 2>/dev/null | head -5

# Project structure
ls -d src/*/ 2>/dev/null || ls -d */ | grep -v -E "test|bin|obj|\.git"

# Platform-specific code
find . -name "*.Android.cs" -o -name "*.iOS.cs" -o -name "*.Windows.cs" 2>/dev/null | head -5

# Existing AI files
ls .github/copilot-instructions.md .github/instructions/*.instructions.md .github/agents/*.md .github/skills/*/SKILL.md 2>/dev/null

# README
head -50 README.md

# Branching
git remote show origin 2>/dev/null | grep "HEAD branch"
git branch -r | grep -E "release|develop|dev" | head -10

# Format command
grep -r "dotnet format" build.sh build.ps1 .github/workflows/*.yml 2>/dev/null | head -5
```

**Store results** as variables for use in later steps. Present a summary to the user:

```markdown
## Repository Analysis: {{REPO_NAME}}

| Property | Value |
|----------|-------|
| .NET SDK | {{VERSION}} |
| Build | {{BUILD_COMMAND}} |
| Test Framework | {{TEST_FRAMEWORK}} |
| Test Projects | {{COUNT}} projects |
| CI | {{CI_SYSTEM}} |
| Platforms | {{PLATFORMS or "None (standard .NET)"}} |
| Existing AI files | {{COUNT or "None"}} |

### Project Areas
{{LIST of areas with paths}}

### Proposed Actions
- Generate: copilot-instructions.md, {{N}} scoped instructions
- Template: {{LIST of template files to create}}
- Copy: {{LIST of universal files to copy}}

**Proceed with onboarding?**
```

**Wait for user confirmation before proceeding.**

---

### Step 2: GENERATE Repo-Specific Files

Follow `generator/generate-copilot-instructions.md` to create:

1. **`.github/copilot-instructions.md`** — Full repo context using analysis results
2. **Pattern-scoped instructions** — Follow `generator/generate-scoped-instructions.md`

For each domain area, read 3-5 representative files to understand conventions before generating instructions.

```bash
# Example: Read test conventions
head -50 $(find . -name "*Tests.cs" | head -3)

# Example: Read main project structure
find src/ -name "*.csproj" | head -10
```

---

### Step 3: TEMPLATE — Fill in Skeleton Files

For each template file in `TOOLKIT/templates/`, copy it to the target repo and replace `{{PLACEHOLDERS}}` with analysis results.

```bash
TOOLKIT="path/to/ai-native-dotnet-bootstrap"
TARGET="path/to/target-repo"

# Create directory structure
mkdir -p "$TARGET/.github/agents"
mkdir -p "$TARGET/.github/skills/try-fix"
mkdir -p "$TARGET/.github/skills/run-tests"
mkdir -p "$TARGET/.github/skills/pr-build-status"
mkdir -p "$TARGET/.github/skills/verify-tests-fail"
mkdir -p "$TARGET/.github/prompts"
```

**Template files to process:**

| Source | Destination | Key Placeholders |
|--------|-------------|------------------|
| `templates/workflows/copilot-setup-steps.yml` | `.github/workflows/copilot-setup-steps.yml` | DOTNET_VERSION, BUILD_COMMAND, RESTORE_COMMAND |
| `templates/agents/pr.md` | `.github/agents/pr.md` | BUILD_COMMAND, TEST_COMMAND, FORMAT_COMMAND |
| `templates/agents/write-tests-agent.md` | `.github/agents/write-tests-agent.md` | TEST_FRAMEWORK, TEST_PROJECT_PATHS, TEST_COMMAND |
| `templates/agents/learn-from-pr.md` | `.github/agents/learn-from-pr.md` | (minimal customization) |
| `templates/skills/try-fix/SKILL.md` | `.github/skills/try-fix/SKILL.md` | BUILD_COMMAND, TEST_COMMAND |
| `templates/skills/run-tests/SKILL.md` | `.github/skills/run-tests/SKILL.md` | TEST_COMMAND_*, TEST_PROJECTS_TABLE, RESTORE_COMMAND |
| `templates/skills/pr-build-status/SKILL.md` | `.github/skills/pr-build-status/SKILL.md` | CI_SYSTEM, PIPELINE_NAMES, ORG |
| `templates/skills/verify-tests-fail/SKILL.md` | `.github/skills/verify-tests-fail/SKILL.md` | BUILD_COMMAND, TEST_COMMAND, FIX_FILES |
| `templates/prompts/release-notes.prompt.md` | `.github/prompts/release-notes.prompt.md` | REPO_NAME |

**For each file:**
1. Read the template from toolkit
2. Replace all `{{PLACEHOLDER}}` values with analysis results
3. Write to the target repo's `.github/` directory

---

### Step 4: COPY Universal Files

Copy files from `TOOLKIT/copy/` to the target repo unchanged:

```bash
# Skills
cp -r "$TOOLKIT/copy/skills/pr-finalize" "$TARGET/.github/skills/"
cp -r "$TOOLKIT/copy/skills/issue-triage" "$TARGET/.github/skills/"
cp -r "$TOOLKIT/copy/skills/find-reviewable-pr" "$TARGET/.github/skills/"
cp -r "$TOOLKIT/copy/skills/learn-from-pr" "$TARGET/.github/skills/"
cp -r "$TOOLKIT/copy/skills/ai-summary-comment" "$TARGET/.github/skills/"

# Workflows
cp "$TOOLKIT/copy/workflows/find-similar-issues.yml" "$TARGET/.github/workflows/"
cp "$TOOLKIT/copy/workflows/inclusive-heat-sensor.yml" "$TARGET/.github/workflows/"
```

**Skip any files that already exist** in the target repo (don't overwrite).

---

### Step 5: SCAFFOLD — Final Assembly

1. **Generate README-AI.md** — Follow `generator/generate-readme-ai.md`, listing all files actually created

2. **Update .gitignore** — Append agent temp directories if not already present:
```bash
echo "" >> "$TARGET/.gitignore"
echo "# AI agent temporary files" >> "$TARGET/.gitignore"
echo "CustomAgentLogsTmp/" >> "$TARGET/.gitignore"
```

3. **Verify no overwrites** — Confirm no existing files were replaced

---

### Step 6: VALIDATE

```bash
cd "$TARGET"

# Check YAML syntax (if yamllint available)
yamllint .github/workflows/*.yml 2>/dev/null || echo "yamllint not available, skipping"

# Verify glob patterns reference real paths
for file in .github/instructions/*.instructions.md; do
  # Extract applyTo patterns and check they match real files
  grep -A5 "applyTo:" "$file" | grep '"' | tr -d ' "' | while read pattern; do
    count=$(find . -path "./$pattern" 2>/dev/null | wc -l)
    echo "$file: '$pattern' matches $count files"
  done
done

# Test build command works
{{BUILD_COMMAND}} || echo "⚠️ Build command failed — verify BUILD_COMMAND in analysis"
```

---

## Final Report

Present the user with a summary of everything created:

```markdown
## ✅ Onboarding Complete: {{REPO_NAME}}

### Files Created

| Category | Files | Status |
|----------|-------|--------|
| Global instructions | 1 | ✅ |
| Scoped instructions | {{N}} | ✅ |
| Agents | {{N}} | ✅ |
| Skills | {{N}} | ✅ |
| Workflows | {{N}} | ✅ |
| Prompts | {{N}} | ✅ |
| README-AI.md | 1 | ✅ |

**Total: {{TOTAL}} files**

### Skipped (already existed)
{{LIST or "None"}}

### Next Steps
1. Review the generated `copilot-instructions.md` — it's the most impactful file
2. Review scoped instructions — verify glob patterns match your project
3. Commit: `git add .github/ && git commit -m "Add AI-native development infrastructure"`
4. Push and try it: `copilot` → "Review PR #1"
5. After your first PR, run `learn-from-pr` to improve the instructions
```

## Rules

1. **Always ask before proceeding** after Step 1 analysis
2. **Never overwrite existing files** — skip or ask
3. **Be honest about detection** — if unsure about a value, say so and use a sensible default
4. **Validate at the end** — don't leave broken files
5. **Show the user everything** — full transparency on what was created and where
