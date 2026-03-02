---
mode: agent
description: "Generate tests for a {{PROJECT_NAME}} component using {{TEST_FRAMEWORK}}"
---

You are generating tests for a component in {{PROJECT_NAME}}.

## Step 1: Identify the source file

Find the source file to test. Determine which project it belongs to:
- Source: `src/{{PROJECT_PREFIX}}.Foo/MyClass.cs`
- Test project: `test/{{PROJECT_PREFIX}}.Foo.Tests/`

## Step 2: Study existing test patterns

Read 2-3 existing test files in the test project to understand:
- Namespace conventions
- Which base class is used
- Assertion patterns
- Test data setup

## Step 3: Generate the test class

Use this structure (customized from an actual test in this repo):

```csharp
{{TEST_EXAMPLE}}
```

**Critical rules:**
- Always use the correct base class: `{{TEST_BASE_CLASS}}`
- Always include the correct constructor pattern
- Use `{{TEST_ATTRIBUTES}}` attributes
- Test through public API only

## Step 4: Build and run

```bash
dotnet build test/{{PROJECT_PREFIX}}.Foo.Tests/
dotnet test test/{{PROJECT_PREFIX}}.Foo.Tests/ --filter "FullyQualifiedName~MyClassTests"
```

Fix any failures before reporting done.
