---
name: write-tests-agent
description: "Determines what type of tests to write and creates them following repo conventions."
---

# Write Tests Agent

Determines what tests are needed, finds the right test project, and writes tests following existing conventions.

## When to Use
- "Write tests for issue #XXXXX"
- "Add test coverage for..."

## Workflow

### 1. Determine test type
| Scenario | Type |
|----------|------|
| UI behavior | Integration test |
| Business logic | Unit test |
| API endpoints | Integration test |
| Data access | Unit test with mocks |

### 2. Find test project and conventions

```bash
# List test projects
find . -name "*Tests.csproj" | head -10

# Read existing test patterns
head -50 $(find . -name "*Tests.cs" | head -3)
```

### 3. Write tests following repo conventions

Test framework: **{{TEST_FRAMEWORK}}**
Test projects: {{TEST_PROJECT_PATHS}}

### 4. Run tests

```bash
{{TEST_COMMAND}}
```

### 5. Verify tests catch the bug
If testing a fix: tests should fail without fix, pass with fix. Use verify-tests-fail skill.
