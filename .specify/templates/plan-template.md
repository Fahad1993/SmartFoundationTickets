# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: C# / .NET 8.0 (ASP.NET Core MVC)
**Primary Dependencies**: Dapper, System.Text.Json, Tailwind CSS
**Storage**: SQL Server (stored procedures via gateway SPs)
**Testing**: xUnit + Moq (`SmartFoundation.Application.Tests`)
**Target Platform**: Windows Server / IIS or Kestrel
**Project Type**: Internal web application (multi-tenant MVC)
**Performance Goals**: Per-page load under server-side rendering norms
**Constraints**: Housing-style pages use `DataSet`/`DataTable`; `CrudController` contract frozen
**Scale/Scope**: Multi-department government housing management

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Verify against `.specify/memory/constitution.md` (v1.0.0):

- [ ] **I. Housing-First**: Does this feature resemble a Housing-style
  page? If yes, plan MUST follow `WaitingListByResident` pattern.
- [ ] **II. Layer Boundary**: No controller calls DataEngine directly.
  Services use `ProcedureMapper`, not hard-coded SP names.
- [ ] **III. Contract Preservation**: No renaming of frozen identifiers
  (`pageName_`, `ActionType`, `idaraID`, `entrydata`, `hostname`,
  `p01`..`p50`, `parameter_01`..`parameter_50`).
- [ ] **IV. Gateway Procedure Architecture**: Only entry/gateway SPs
  mapped in `ProcedureMapper`. Downstream SPs routed by gateway.
- [ ] **V. Server-Side UI Composition**: UI state assembled in
  controller via `FormConfig`, `SmartTableDsModel`,
  `SmartPageViewModel`. Views thin; render through `SmartRenderer`.
- [ ] **VI. Permission-Gated Actions**: Permissions derived from
  DataSet table 0 (`permissionTypeName_E`). Server-side gating.
- [ ] **VII. Trust Active Code**: Active runtime code is truth.
  `SmartFoundation.Database` is reference only.
- [ ] **VIII. Build And Test**: `dotnet build` and `dotnet test` gates
  MUST pass. Tailwind build if CSS changed.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
SmartFoundation.Mvc/           # MVC app, controllers, views, composition root
├── Controllers/
│   ├── Housing/               # Housing-style page controllers
│   │   ├── WaitingList/       # Reference: HousingController.WaitingListByResident.cs
│   │   └── [Feature]/         # New feature controllers follow Housing pattern
│   ├── CrudController.cs      # Generic CRUD contract (frozen)
│   └── ...
├── Views/
│   └── Housing/               # Thin views rendering via SmartRenderer
├── Program.cs                 # Real composition root
└── wwwroot/css/               # Tailwind input/output

SmartFoundation.Application/   # Business logic and orchestration
├── Services/
│   ├── MastersServies.cs      # Active gateway service (preserve)
│   ├── BaseService.cs         # Base class for new narrow services
│   └── [Feature]Service.cs    # New focused services
├── Mapping/
│   └── ProcedureMapper.cs    # Entry/gateway SP mappings only
└── Extensions/

SmartFoundation.DataEngine/    # Dapper execution (stable, no changes)
SmartFoundation.UI/            # Reusable ViewComponents
SmartFoundation.Application.Tests/  # xUnit + Moq test project
SmartFoundation.Database/      # Snapshot/reference only (not source of truth)
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
