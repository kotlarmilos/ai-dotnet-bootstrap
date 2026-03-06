# AGENTS.md — System Prompt for Your Repository

> Place this file at `AGENTS.md` in your repo root. This is the cross-tool standard —
> supported by GitHub Copilot, Cursor, Claude, and others.
> Fill in each section. Keep it short — agents read this on every interaction.

---

```markdown
# {{REPO_NAME}}

{{ONE_LINE_DESCRIPTION}}

## Build & Test

```bash
# Build
{{BUILD_COMMAND}}

# Test
{{TEST_COMMAND}}

# Lint / Format (if applicable)
{{FORMAT_COMMAND}}
```

## Project Structure

```
{{PROJECT_TREE}}
```

## Conventions

- {{CONVENTION_1}}
- {{CONVENTION_2}}
- {{CONVENTION_3}}

## Agent Behavior

- Always run tests before submitting changes
- Create a feature branch, never commit to `{{DEFAULT_BRANCH}}`
- Keep PRs focused — one issue per PR
- If CI fails, read the failure logs and fix before requesting review
```

---

## How to Fill This In

| Placeholder | What to put | Example |
|---|---|---|
| `{{REPO_NAME}}` | Repository name | `my-awesome-api` |
| `{{ONE_LINE_DESCRIPTION}}` | What this repo does, one sentence | `REST API for user management built with ASP.NET Core` |
| `{{BUILD_COMMAND}}` | How to build | `dotnet build MyApp.sln` |
| `{{TEST_COMMAND}}` | How to run tests | `dotnet test MyApp.sln` |
| `{{FORMAT_COMMAND}}` | How to lint/format | `dotnet format MyApp.sln` |
| `{{PROJECT_TREE}}` | Key directories, 1-line descriptions | `src/Api/ — HTTP endpoints` |
| `{{CONVENTION_*}}` | Things an AI wouldn't know from code alone | `Use xUnit, not MSTest` |
| `{{DEFAULT_BRANCH}}` | Default branch | `main` |

## Why This File Matters

Without it, agents guess at your build commands, conventions, and structure. Keep it short (under 100 lines), specific (real commands, real paths), and honest (include gotchas).
