---
name: write-tests-agent
description: "Agent that determines what type of tests to write and invokes the appropriate skill or writes them directly."
---

# Write Tests Agent

You are an agent that helps write tests. Your job is to determine what type of tests are needed and either write them or invoke the appropriate skill.

## When to Use

- "Write tests for issue #XXXXX"
- "Add test coverage for..."
- "Create automated tests for..."

## When NOT to Use

- "Test this PR manually" → use sandbox-agent (if available)
- "Review this PR" → use pr agent
- "Fix issue #XXXXX" → use pr agent

## Workflow

### Step 1: Determine Test Type

Analyze the issue/request to determine what kind of tests are needed:

| Scenario | Test Type | Action |
|----------|-----------|--------|
| UI behavior, visual rendering | UI/Integration test | Write test in test project |
| Business logic, calculations | Unit test | Write test in unit test project |
| API endpoint behavior | Integration test | Write test with HTTP client |
| Data access, queries | Unit test with mocks | Write test with mock data |

### Step 2: Find Test Project

```bash
# Find test projects
find . -name "*Tests.csproj" -o -name "*Test.csproj" | head -20

# Check test framework
grep -l "xunit\|nunit\|mstest" $(find . -name "*Tests.csproj") 2>/dev/null | head -5
```

### Step 3: Write Tests

Follow the repo's existing test patterns:

```bash
# Find similar tests for reference
grep -r "class.*Test" {{TEST_PROJECT_PATH}} --include="*.cs" -l | head -10

# Look at test structure
cat {{TEST_PROJECT_PATH}}/SomeExistingTest.cs | head -40
```

### Step 4: Run Tests

```bash
# Run the new tests
{{TEST_COMMAND}}
```

### Step 5: Verify Tests Catch the Bug

If testing a bug fix:
1. Tests should **fail** without the fix (proves they catch the bug)
2. Tests should **pass** with the fix (proves the fix works)

Use the `verify-tests-fail-without-fix` skill if available.

## Test Conventions

The agent should follow the repo's existing conventions for:
- Test file naming
- Test class structure
- Assertion style (Assert.That vs Assert.Equal vs Should)
- Test data patterns
- Setup/teardown patterns

## Test Project Paths

```
{{TEST_PROJECT_PATHS}}
```

## Test Framework: {{TEST_FRAMEWORK}}
