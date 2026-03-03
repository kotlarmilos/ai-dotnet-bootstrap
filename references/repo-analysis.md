# Repo Analysis

How to analyze a .NET repository and extract everything needed for onboarding.

Run these commands against the target repo. Store results as variables for later steps.

## Detection Commands

### 1. Basics

```bash
# Repo name and description
basename $(git rev-parse --show-toplevel)
head -5 README.md

# SDK version
cat global.json 2>/dev/null | grep -oP '"version"\s*:\s*"\K[^"]+' || dotnet --version

# Solution files
find . -maxdepth 2 \( -name "*.sln" -o -name "*.slnf" \) 2>/dev/null | head -10
```

### 2. Build System

Check in order — first match wins:

| Signal | Build Command | Restore Command |
|--------|--------------|-----------------|
| `build.sh` exists | `./build.sh` | (included in build) |
| `build.cake` exists | `dotnet cake` | `dotnet tool restore` |
| `Makefile` exists | `make` | `make restore` |
| `*.sln` found | `dotnet build SOLUTION.sln` | `dotnet restore SOLUTION.sln` |
| Single `.csproj` | `dotnet build PROJECT.csproj` | `dotnet restore PROJECT.csproj` |

```bash
ls build.sh build.ps1 build.cake Makefile 2>/dev/null
```

### 3. Test Framework & Projects

```bash
# Find test projects
find . \( -name "*Tests.csproj" -o -name "*Test.csproj" -o -name "*Tests.fsproj" \) 2>/dev/null | head -20

# Detect framework per project
for proj in $(find . -name "*Tests.csproj" -o -name "*Test.csproj" | head -5); do
  framework=$(grep -oiE "xunit|nunit|mstest" "$proj" | sort -u | head -1)
  echo "$proj → $framework"
done
```

Test command is always `dotnet test PROJECT` for .NET, but the project path and any filter syntax varies.

### 4. CI System

```bash
# GitHub Actions
ls .github/workflows/*.yml 2>/dev/null | head -10

# Azure DevOps
ls azure-pipelines.yml 2>/dev/null
find eng/pipelines -name "*.yml" 2>/dev/null | head -10
```

For GitHub Actions, extract the main CI workflow name:
```bash
grep -l "pull_request" .github/workflows/*.yml 2>/dev/null | head -3
```

### 5. Project Structure

```bash
# Source directories (skip common non-source dirs)
find . -maxdepth 2 -name "*.csproj" -not -path "*/bin/*" -not -path "*/obj/*" | \
  sed 's|/[^/]*$||' | sort -u

# Top-level areas
ls -d src/*/ 2>/dev/null || ls -d */ | grep -vE "^(bin|obj|test|\.)" | head -15
```

### 6. Platform-Specific Code

```bash
# Multi-target detection
grep -r "TargetFrameworks" $(find . -name "*.csproj" | head -5) 2>/dev/null | grep -oE "net[0-9.]+-[a-z]+" | sort -u

# Platform files
find . \( -name "*.Android.cs" -o -name "*.iOS.cs" -o -name "*.Windows.cs" \) 2>/dev/null | head -5

# Platform directories
find . -type d \( -name "Android" -o -name "iOS" -o -name "Windows" -o -name "Platforms" \) 2>/dev/null | head -10
```

### 7. Code Formatting

```bash
# .editorconfig
test -f .editorconfig && echo "Has .editorconfig"

# Format command in build scripts or CI
grep -rn "dotnet format" build.sh build.ps1 Makefile .github/workflows/*.yml 2>/dev/null | head -3
```

Default: `dotnet format SOLUTION.sln --no-restore`

### 8. Branching

```bash
git remote show origin 2>/dev/null | grep "HEAD branch" | awk '{print $NF}'
git branch -r 2>/dev/null | grep -E "release|develop|dev" | head -5
```

### 9. Existing AI Files

```bash
ls .github/copilot-instructions.md 2>/dev/null
ls .github/instructions/*.instructions.md 2>/dev/null
ls .github/agents/*.md 2>/dev/null
ls .github/skills/*/SKILL.md 2>/dev/null
ls .github/workflows/copilot-setup-steps.yml 2>/dev/null
```

If files exist, note them. Don't overwrite — ask the user whether to merge or skip.

## Output Format

Present results as a table and wait for user confirmation:

```
| Property | Value |
|----------|-------|
| Name | repo-name |
| SDK | 9.0.100 |
| Build | dotnet build Solution.sln |
| Restore | dotnet restore Solution.sln |
| Format | dotnet format Solution.sln |
| Test Framework | xunit |
| Test Projects | tests/Unit/, tests/Integration/ |
| Test Command | dotnet test Solution.sln |
| CI | GitHub Actions (ci.yml, tests.yml) |
| Areas | src/Core/, src/Api/, src/Web/ |
| Platforms | None |
| Branch | main |
| Existing AI | None |
```
