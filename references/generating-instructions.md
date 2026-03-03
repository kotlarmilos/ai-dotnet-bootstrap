# Generating Instructions

How to generate `copilot-instructions.md` and scoped instruction files for a target repo.

## copilot-instructions.md

This is the single most impactful file. It's loaded into every Copilot interaction with your repo.

### Before Writing

Read 3-5 representative files to understand the repo's conventions:
- One source file from the main module
- One test file
- README.md or CONTRIBUTING.md
- A build script or CI workflow

### Structure

```markdown
---
description: "Guidance for GitHub Copilot when working on {{REPO_NAME}}."
---

# Development Instructions

## Repository Overview
[1-2 sentences: what this repo is and does]

### Key Technologies
[Bulleted list of: SDK, build system, test framework, major dependencies]

## Build & Test
[The commands. This is what agents use most.]

### Build
\`\`\`bash
{{RESTORE_COMMAND}}
{{BUILD_COMMAND}}
\`\`\`

### Test
\`\`\`bash
{{TEST_COMMAND}}
\`\`\`

### Format
\`\`\`bash
{{FORMAT_COMMAND}}
\`\`\`

## Project Structure
[Map of top-level directories with one-line descriptions]

## Conventions
[Things the AI wouldn't know from reading code alone:
 - Naming patterns
 - Architecture decisions
 - Where to put new files
 - Common gotchas]

## Git Workflow
- Default branch: {{DEFAULT_BRANCH}}
- Never commit directly to {{DEFAULT_BRANCH}}
- Branch naming: feature/description, fix/description
[Any repo-specific branching rules]

## CI
[Which CI system, main pipeline names, what the CI checks]
```

### Rules

1. **Be specific** — Use actual paths, commands, versions. Not "run the build" but `dotnet build MyApp.sln`.
2. **Be concise** — Under 200 lines. Agents read this every time.
3. **Don't repeat README** — Focus on what the AI needs to know, not what humans read.
4. **Include the "why"** — "We use xUnit (not MSTest) because..." helps agents pick the right patterns.

---

## Scoped Instructions

Pattern-scoped `.instructions.md` files activate only when the AI touches matching files. They provide domain-specific guidance without bloating the global instructions.

### When to Create One

| Signal | Create? | Example |
|--------|---------|---------|
| Test projects with distinct patterns | **Yes** | Test naming, assertion style, fixtures |
| Platform-specific code directories | **Yes** | Android lifecycle, iOS APIs |
| Config/template directories | **Yes** | Template syntax, what not to edit |
| Standard source code | **Usually no** | Global instructions cover this |
| Docs directory | **No** | Unless docs have a build system |

### Format

```markdown
---
applyTo:
  - "tests/**"
  - "**/*Tests.cs"
---

# Test Guidelines

## Framework: {{TEST_FRAMEWORK}}

### Naming
[Test class and method naming conventions from the repo]

### Structure
[Example test from the repo, showing the pattern to follow]

### Running
\`\`\`bash
dotnet test {{TEST_PROJECT}} --filter "FullyQualifiedName~ClassName"
\`\`\`
```

### How to Detect Conventions

For each area, read 2-3 existing files and extract:

```bash
# Test naming pattern
grep -r "public.*void\|public.*async.*Task\|\[Fact\]\|\[Test\]\|\[Theory\]" tests/ --include="*.cs" | head -10

# Base classes used
grep -r "class.*:.*Test\|class.*:.*Fixture" tests/ --include="*.cs" | head -5

# Assertion style
grep -r "Assert\.\|Should\.\|Expect(" tests/ --include="*.cs" | head -5 | sed 's/.*\(Assert\.\|Should\.\|Expect(\).*/\1/' | sort | uniq -c
```

### Verifying Glob Patterns

After creating instruction files, verify the globs match real files:

```bash
# For each instruction file
for file in .github/instructions/*.instructions.md; do
  echo "=== $file ==="
  # Extract patterns (rough — adapt for actual YAML parsing)
  grep -A10 "applyTo:" "$file" | grep '"' | tr -d ' "' | while read pattern; do
    matches=$(find . -path "./$pattern" 2>/dev/null | wc -l)
    echo "  $pattern → $matches files"
  done
done
```

If a glob matches 0 files, the instruction file is useless — fix the pattern or remove the file.
