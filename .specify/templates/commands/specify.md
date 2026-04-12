---
description: "Create or update the project constitution"
---

# /specify Command

## Purpose

Initialize, update, or amend the project constitution at
`.specify/memory/constitution.md`.

## Execution Steps

1. Read the existing constitution at `.specify/memory/constitution.md`.
2. Identify placeholder tokens (if any remain).
3. Collect values from user input, repo context (AGENTS.md, README.md,
   copilot-instructions.md), or inference.
4. Determine version bump:
   - MAJOR: Principle removal or redefinition.
   - MINOR: New principle or material expansion.
   - PATCH: Clarifications, wording fixes.
5. Replace all placeholders with concrete text.
6. Validate: no remaining bracket tokens, version matches, dates in
   ISO format, principles declarative and testable.
7. Update dependent templates for consistency.
8. Write the updated constitution.
9. Produce a Sync Impact Report as an HTML comment at the top.

## Templates to Check for Consistency

- `.specify/templates/plan-template.md` (Constitution Check section)
- `.specify/templates/spec-template.md` (scope/requirements alignment)
- `.specify/templates/tasks-template.md` (task categorization)
- `.specify/templates/commands/*.md` (no stale agent-specific names)

## Output

- Updated `.specify/memory/constitution.md`
- Consistency report to user
- Suggested commit message
