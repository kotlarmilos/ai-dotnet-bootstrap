# Generate copilot-instructions.md

Using the analysis results from `analyze-repo.md`, generate a comprehensive `copilot-instructions.md` for the target repo.

## Template

Generate the following, filling in all `{{VARIABLES}}` from the analysis:

```markdown
---
description: "Guidance for GitHub Copilot when working on the {{REPO_NAME}} repository."
---

# GitHub Copilot Development Environment Instructions

This document provides specific guidance for GitHub Copilot when working on the {{REPO_NAME}} repository.

## Repository Overview

**{{REPO_NAME}}** — {{REPO_DESCRIPTION}}

### Key Technologies

- **.NET SDK** — Version defined in `global.json` (currently {{DOTNET_VERSION}})
{{FOR EACH TECHNOLOGY detected}}
- **{{TECHNOLOGY}}** — {{DESCRIPTION}}
{{END FOR}}

## Development Environment Setup

### Prerequisites

- .NET SDK {{DOTNET_VERSION}} (verify with `dotnet --version` against `global.json`)
{{FOR EACH PREREQUISITE detected}}
- {{PREREQUISITE}}
{{END FOR}}

### Build

```bash
{{RESTORE_COMMAND}}
{{BUILD_COMMAND}}
```

### Test

```bash
{{TEST_COMMAND}}
```

### Format

```bash
{{FORMAT_COMMAND}}
```

## Project Structure

### Important Directories
{{FOR EACH PROJECT_AREA}}
- `{{PATH}}` — {{DESCRIPTION}}
{{END FOR}}

### Test Projects
{{FOR EACH TEST_PROJECT}}
- `{{PATH}}` — {{FRAMEWORK}} tests
{{END FOR}}

{{IF HAS_PLATFORM_CODE}}
### Platform-Specific Code

Platform-specific files use naming conventions:
{{FOR EACH PLATFORM}}
- `.{{PLATFORM_EXT}}.cs` — {{PLATFORM}} specific code
{{END FOR}}
{{END IF}}

## Contribution Guidelines

### Branching

- `{{DEFAULT_BRANCH}}` — Default branch
{{BRANCHING_STRATEGY_DETAILS}}

### Git Workflow

🚨 **NEVER commit directly to `{{DEFAULT_BRANCH}}`.**

```bash
git checkout -b feature/description
git add .
git commit -m "Description of the change"
git push -u origin feature/description
```

### Code Formatting

```bash
{{FORMAT_COMMAND}}
```

### Before Committing

- Run tests: `{{TEST_COMMAND}}`
- Format code: `{{FORMAT_COMMAND}}`
- Ensure no unrelated changes are included

## CI/CD

{{CI_DESCRIPTION}}
```

## Rules for Generation

1. **Be specific** — Use actual paths, commands, and versions from the analysis
2. **Be concise** — Only include sections relevant to this repo
3. **Match conventions** — Mirror the style of existing docs (README, CONTRIBUTING)
4. **Don't invent** — Only document what was actually detected
5. **Skip empty sections** — If no platforms detected, omit the platform section
