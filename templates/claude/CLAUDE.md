# CLAUDE.md — {{PROJECT_NAME}}

## Project
{{PROJECT_DESCRIPTION}}

## Build
```bash
{{BUILD_COMMAND}}
dotnet build src/{{PROJECT_PREFIX}}.Foo/
dotnet test test/{{PROJECT_PREFIX}}.Foo.Tests/
dotnet format --verify-no-changes
```

## Conventions
{{CONVENTIONS_LIST}}

## Key Architecture
{{ARCHITECTURE_SUMMARY}}

## Safety Rules
- Never break public API without `[Obsolete]` migration
- Never hardcode paths, secrets, or credentials
- Each commit must build
