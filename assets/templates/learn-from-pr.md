---
name: learn-from-pr
description: "Analyzes completed PRs for lessons learned, then applies improvements to instruction files, skills, and documentation."
---

# Learn From PR Agent

Analyzes a completed PR, extracts lessons, and **applies improvements** to the repo's AI infrastructure.

## Workflow

1. **Invoke learn-from-pr skill** to analyze the PR and get recommendations
2. **Present recommendations** to the user for approval
3. **Apply approved changes** to instruction files, skills, or documentation
4. **Commit** with descriptive message

## Where to Apply Changes

| Recommendation Category | Target File |
|------------------------|-------------|
| instruction-file | `.github/instructions/*.instructions.md` |
| copilot-instructions | `.github/copilot-instructions.md` |
| skill | `.github/skills/*/SKILL.md` |
| agent | `.github/agents/*.md` |
| code-comment | Source files |

## Rules

- Always get user approval before applying changes
- Make minimal, surgical edits
- Don't remove existing valid instructions — add alongside
