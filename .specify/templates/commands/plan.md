---
description: "Plan a feature implementation with constitution-gated research"
---

# /plan Command

## Purpose

Create an implementation plan for a feature, gated by the project
constitution.

## Execution Steps

1. Read `.specify/memory/constitution.md` for active principles.
2. Read the feature spec (if provided) or gather requirements from user
   input.
3. Check if the feature resembles a Housing-style page (Principle I).
4. If yes, use `WaitingListByResident` as the template pattern.
5. Run the Constitution Check gate from the plan template.
6. Produce `specs/[###-feature-name]/plan.md` using
   `.specify/templates/plan-template.md`.
7. Produce `specs/[###-feature-name]/research.md` if research phase is
  needed.

## Constitution Gates

Before proceeding past Phase 0, verify all 8 principles pass. Record
any violations in the Complexity Tracking table with justification.

## Output

- `specs/[###-feature-name]/plan.md`
- `specs/[###-feature-name]/research.md` (if applicable)
