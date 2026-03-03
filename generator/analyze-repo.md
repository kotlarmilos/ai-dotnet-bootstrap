# Repo Analysis Guide

Instructions for the onboarding agent to analyze a .NET repository and extract the information needed to generate AI infrastructure.

## What to Detect

Run these detection steps in order. Each step produces a variable used by later generators.

---

### 1. SDK Version

```bash
# Read from global.json
cat global.json | jq -r '.sdk.version'
```

**Output:** `DOTNET_VERSION` (e.g., `"9.0.100"`)

If `global.json` doesn't exist, check `.dotnet-version` or fall back to `dotnet --version`.

---

### 2. Solution Files

```bash
# Find all solution files
find . -maxdepth 2 -name "*.sln" -o -name "*.slnf" | head -20
```

**Output:** `SOLUTION_FILES` (list of paths)

---

### 3. Build System

Check in order:

| Signal | Build Command | Type |
|--------|--------------|------|
| `build.sh` / `build.ps1` exists | `./build.sh` / `.\build.ps1` | Custom script |
| `build.cake` exists | `dotnet cake` | Cake |
| `Makefile` exists | `make` | Make |
| `*.sln` exists | `dotnet build SOLUTION.sln` | Standard dotnet |

```bash
# Detect build system
ls build.sh build.ps1 build.cake Makefile 2>/dev/null
```

**Output:** `BUILD_COMMAND`, `RESTORE_COMMAND`, `BUILD_SYSTEM`

---

### 4. Test Framework & Projects

```bash
# Find test projects
find . -name "*Tests.csproj" -o -name "*Test.csproj" -o -name "*Tests.fsproj" 2>/dev/null

# Detect framework from NuGet refs
for proj in $(find . -name "*Tests.csproj" | head -5); do
  echo "=== $proj ==="
  grep -oE "xunit|nunit|mstest|NUnit|xUnit|MSTest" "$proj" | sort -u
done
```

**Output:** `TEST_FRAMEWORK` (xunit/nunit/mstest), `TEST_PROJECTS` (list of paths), `TEST_COMMAND`

Test command inference:

| Framework | Command |
|-----------|---------|
| xunit | `dotnet test PROJECT.csproj` |
| nunit | `dotnet test PROJECT.csproj` |
| mstest | `dotnet test PROJECT.csproj` |

---

### 5. CI System

```bash
# GitHub Actions
ls .github/workflows/*.yml 2>/dev/null | head -10

# Azure DevOps
ls azure-pipelines.yml eng/pipelines/*.yml 2>/dev/null | head -10

# Both can coexist
```

**Output:** `CI_SYSTEM` (github-actions / azure-devops / both / none), `CI_PIPELINES` (list of pipeline files)

---

### 6. Project Structure & Domains

```bash
# Top-level source directories
ls -d src/*/ 2>/dev/null || ls -d */ | grep -v -E "test|bin|obj|node_modules|\.git"

# Count projects per area
for dir in src/*/; do
  echo "$dir: $(find "$dir" -name "*.csproj" | wc -l) projects"
done
```

**Output:** `PROJECT_AREAS` (list of {name, path, description})

---

### 7. Platform-Specific Code

```bash
# Platform-specific files
find . -name "*.Android.cs" -o -name "*.iOS.cs" -o -name "*.Windows.cs" 2>/dev/null | head -5

# Platform directories
find . -type d -name "Android" -o -name "iOS" -o -name "Windows" -o -name "MacCatalyst" 2>/dev/null | head -10
```

**Output:** `PLATFORMS` (list of detected platforms), `HAS_PLATFORM_CODE` (true/false)

---

### 8. Code Formatting

```bash
# Check for .editorconfig
cat .editorconfig 2>/dev/null | head -20

# Check for format command
grep -r "dotnet format" build.sh build.ps1 Makefile .github/workflows/*.yml 2>/dev/null | head -5
```

**Output:** `FORMAT_COMMAND` (e.g., `dotnet format SOLUTION.sln`)

---

### 9. Branching Strategy

```bash
# Check default branch
git remote show origin 2>/dev/null | grep "HEAD branch" | awk '{print $NF}'

# Check for release branches
git branch -r | grep -E "release|develop|dev" | head -10

# Check for CONTRIBUTING.md guidance
grep -i "branch" CONTRIBUTING.md README.md 2>/dev/null | head -10
```

**Output:** `DEFAULT_BRANCH`, `BRANCHING_STRATEGY` (description)

---

### 10. Existing AI Files

```bash
# Check if AI infrastructure already exists
ls .github/copilot-instructions.md 2>/dev/null
ls .github/instructions/*.instructions.md 2>/dev/null
ls .github/agents/*.md 2>/dev/null
ls .github/skills/*/SKILL.md 2>/dev/null
```

**Output:** `EXISTING_AI_FILES` (list), `SKIP_FILES` (files that already exist)

---

### 11. README & Documentation

```bash
# Extract repo description
head -30 README.md

# Check for docs
ls docs/ 2>/dev/null | head -10
ls CONTRIBUTING.md DEVELOPMENT.md 2>/dev/null
```

**Output:** `REPO_DESCRIPTION`, `REPO_NAME`, `HAS_DOCS`

---

## Summary Output

After all detection steps, produce a JSON summary:

```json
{
  "repo_name": "...",
  "repo_description": "...",
  "dotnet_version": "9.0.100",
  "build_command": "dotnet build Solution.sln",
  "restore_command": "dotnet restore Solution.sln",
  "format_command": "dotnet format Solution.sln",
  "test_framework": "xunit",
  "test_command": "dotnet test Solution.sln",
  "test_projects": ["tests/UnitTests/UnitTests.csproj"],
  "ci_system": "github-actions",
  "project_areas": [{"name": "Core", "path": "src/Core/"}],
  "platforms": [],
  "has_platform_code": false,
  "default_branch": "main",
  "branching_strategy": "main + release branches",
  "existing_ai_files": [],
  "solution_files": ["Solution.sln"]
}
```
