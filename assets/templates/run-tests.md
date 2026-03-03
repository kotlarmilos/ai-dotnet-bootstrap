---
name: run-tests
description: "Build and run tests locally with filtering. Use when asked to run tests, verify a fix, or check test results."
---

# Run Tests

## Quick Start

```bash
# All tests
{{TEST_COMMAND_ALL}}

# Specific project
{{TEST_COMMAND_PROJECT}}

# Filter by name
{{TEST_COMMAND_FILTER}}
```

## Test Projects

| Project | Path | Framework |
|---------|------|-----------|
{{TEST_PROJECTS_TABLE}}

## Filtering

```bash
# By name
dotnet test PROJECT --filter "FullyQualifiedName~ClassName.Method"

# By trait/category
dotnet test PROJECT --filter "Category=Unit"
```

## Prerequisites

```bash
{{RESTORE_COMMAND}}
{{BUILD_COMMAND}}
```
