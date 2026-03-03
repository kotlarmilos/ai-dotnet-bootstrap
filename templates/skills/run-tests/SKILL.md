---
name: run-tests
description: "Build and run tests locally. Supports filtering by project, category, or test name."
---

# Run Tests Skill

Builds and runs tests locally with filtering support.

## When to Use

- "Run the unit tests"
- "Run tests for module X"
- "Run tests matching *Button*"

## Quick Start

```bash
# Run all tests
{{TEST_COMMAND_ALL}}

# Run specific test project
{{TEST_COMMAND_PROJECT}}

# Run tests matching a filter
{{TEST_COMMAND_FILTER}}
```

## Test Projects

| Project | Path | Framework |
|---------|------|-----------|
{{TEST_PROJECTS_TABLE}}

## Filtering

```bash
# By fully qualified name
dotnet test {{TEST_PROJECT}} --filter "FullyQualifiedName~ClassName.MethodName"

# By category/trait
dotnet test {{TEST_PROJECT}} --filter "Category=UnitTest"

# By display name
dotnet test {{TEST_PROJECT}} --filter "DisplayName~search term"
```

## Prerequisites

```bash
# Restore dependencies
{{RESTORE_COMMAND}}

# Build (if separate step needed)
{{BUILD_COMMAND}}
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Build fails | Run `{{RESTORE_COMMAND}}` first |
| Tests not found | Check test project path and filter syntax |
| Timeout | Add `-- RunConfiguration.TestSessionTimeout=300000` |
