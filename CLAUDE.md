# CLAUDE.md — AI-Native .NET Bootstrap Toolkit

## Project
A toolkit of skills, agents, and templates for turning any .NET repo into an AI-native development environment.

## Structure
- `docs/` — Formal definitions of AI-native concepts
- `skills/` — Anthropic-format skill packages with evals
- `templates/` — Portable template files with `{{PLACEHOLDER}}` substitution

## Key Skills
- `skills/bootstrap-dotnet-repo/SKILL.md` — Analyzes a .NET repo and generates 14+ AI-native files
- `skills/ai-native-audit/SKILL.md` — Audits AI-native readiness (L0–L5 scoring)

## Conventions
- Skills use YAML frontmatter with `name` and `description`
- Evals use JSON with `prompt`, `expected_output`, and `expectations` arrays
- Templates use `{{PLACEHOLDER}}` for repo-specific values
- All content is .NET-focused (C#, dotnet CLI, xUnit/NUnit/MSTest)
