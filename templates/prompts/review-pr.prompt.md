---
mode: agent
description: "Review a pull request for {{PROJECT_NAME}} pattern compliance, API compatibility, and security"
---

You are reviewing a pull request in {{PROJECT_NAME}}.

## Step 1: Understand the change

Read the PR diff and identify:
- Which projects are affected
- Whether public API is changed
- Whether tests are included

## Step 2: Pattern compliance check

| Pattern | Check |
|---------|-------|
| Validation | {{VALIDATION_CHECK}} |
| Logging | {{LOGGING_CHECK}} |
| Public API | XML doc comments on all new public members |
| Style | No `TreatWarningsAsErrors` violations, passes `dotnet format` |

## Step 3: API backward compatibility

If public API is changed:
- Are existing signatures preserved?
- Are removed members marked `[Obsolete]` first?
- Could this break downstream consumers?

## Step 4: Test coverage

- Is there a corresponding test for each new public method?
- Do tests follow the project's test patterns?
- Are edge cases covered (null, empty, boundary values)?
- Are tests deterministic?

## Step 5: Security scan

- Any `DllImport` / `unsafe` changes — are inputs validated?
- Any file path handling — protected against traversal?
- Any deserialization — safe patterns used?
- Any hardcoded strings that look like secrets?

## Step 6: Report

Provide a structured review with specific file:line references and concrete fix suggestions.
