# Generate Pattern-Scoped Instructions

Using the analysis results from `analyze-repo.md`, generate pattern-scoped `.instructions.md` files for each domain area that would benefit from specialized AI guidance.

## When to Create an Instruction File

Create a scoped instruction file when:
- A domain area has **distinct conventions** (e.g., test projects have different patterns than source)
- There are **platform-specific rules** (e.g., Android code has type alias conventions)
- A directory has **special build/test procedures**
- Files require **domain-specific knowledge** the AI wouldn't infer from code alone

Do NOT create instruction files for:
- Areas with no special conventions
- Directories with < 3 files
- Standard .NET patterns that Copilot already knows

## Instruction File Template

```markdown
---
applyTo:
  - "{{GLOB_PATTERN_1}}"
  - "{{GLOB_PATTERN_2}}"
---

# {{AREA_NAME}} Guidelines

{{BRIEF_DESCRIPTION of what this area is and when these instructions apply.}}

## Conventions

{{SPECIFIC conventions detected in this area:
- File naming patterns
- Class structure patterns
- Common base classes
- Import/using conventions
}}

## Common Patterns

{{PATTERNS detected from reading existing files:
- How tests are structured (if test area)
- How platform code is organized (if platform area)
- How configs are structured (if config area)
}}

## Build & Test

```bash
{{AREA-SPECIFIC build/test commands if different from global}}
```

## Common Issues

| Issue | Solution |
|-------|----------|
| {{COMMON_ISSUE}} | {{SOLUTION}} |
```

## Detection Heuristics

For each project area from the analysis, decide whether it needs scoped instructions:

### Test Projects → YES (almost always)

```
applyTo: ["src/Tests/**", "tests/**"]
```

Content: Test framework, assertion style, test naming, setup/teardown patterns, how to run specific tests.

### Platform Code → YES (if multi-platform)

```
applyTo: ["**/*.Android.cs", "**/Android/**/*.cs"]
```

Content: Platform-specific APIs, common type aliases, lifecycle patterns.

### Configuration/Templates → YES (if special rules)

```
applyTo: ["src/Templates/**"]
```

Content: Template syntax, placeholder conventions, what not to edit.

### Core/Shared Libraries → MAYBE

Only if they have non-obvious conventions. Skip if standard .NET patterns.

### Docs → USUALLY NO

Unless documentation has a build system or specific formatting requirements.

## Example: Test Instructions

For a repo using xUnit:

```markdown
---
applyTo:
  - "tests/**"
  - "**/*Tests.cs"
---

# Test Guidelines

## Test Framework: xUnit

### Naming Convention
- Test classes: `{ClassName}Tests`
- Test methods: `{MethodName}_Should_{ExpectedBehavior}_When_{Condition}`

### Structure
```csharp
public class MyServiceTests
{
    [Fact]
    public void GetById_Should_ReturnNull_When_NotFound()
    {
        // Arrange
        var sut = new MyService();

        // Act
        var result = sut.GetById(999);

        // Assert
        Assert.Null(result);
    }

    [Theory]
    [InlineData(1, "Alice")]
    [InlineData(2, "Bob")]
    public void GetById_Should_ReturnCorrectName(int id, string expected)
    {
        var sut = new MyService();
        var result = sut.GetById(id);
        Assert.Equal(expected, result.Name);
    }
}
```

### Running Tests
```bash
dotnet test tests/UnitTests/UnitTests.csproj --filter "FullyQualifiedName~MyServiceTests"
```
```

## Output

For each area that needs instructions, produce:
1. The file path (e.g., `.github/instructions/tests.instructions.md`)
2. The glob patterns for `applyTo`
3. The full content

Return as a list of `{path, content}` pairs.
