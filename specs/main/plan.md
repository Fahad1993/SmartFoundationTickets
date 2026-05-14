# Implementation Plan: Tickets Module

**Branch**: `main` | **Date**: 2026-04-14 | **Spec**: `specs/main/spec.md`
**Input**: Feature specification from `specs/main/spec.md`

## Summary

Build a full Tickets module following the Housing-style `WaitingListByResident` pattern. The database layer (21 tables, 4 SPs, 3 views) is already deployed and tested. This plan covers the application layer: gateway SP routing, controller actions, views, and DI registration for Service Catalog, Ticket List, and Ticket Details pages.

## Technical Context

**Language/Version**: C# / .NET 8.0 (ASP.NET Core MVC)
**Primary Dependencies**: Dapper, System.Text.Json, Tailwind CSS
**Storage**: SQL Server (stored procedures via gateway SPs `dbo.Masters_DataLoad` and `dbo.Masters_CRUD`)
**Testing**: xUnit + Moq (`SmartFoundation.Application.Tests`)
**Target Platform**: Windows Server / IIS or Kestrel
**Project Type**: Internal web application (multi-tenant MVC)
**Performance Goals**: Per-page load under server-side rendering norms
**Constraints**: Housing-style pages use `DataSet`/`DataTable`; `CrudController` contract frozen; gateway SP routing architecture
**Scale/Scope**: Multi-department government ticket management

### Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Controller pattern | Partial class `TicketController` with `TicketController.Base` | Matches `HousingController` pattern exactly |
| Read path | `MastersServies.GetDataLoadDataSetAsync` | Existing gateway; no new service needed |
| Write path | `MastersServies.GetCrudDataSetAsync` via `CrudController` | Frozen CRUD contract |
| Gateway SP routing | Add `@pageName_` branches to `Masters_DataLoad` and `Masters_CRUD` | Constitution Principle IV |
| ProcedureMapper | No new entries needed | Gateway SPs already mapped |
| Views | Thin Razor views using `SmartRenderer` | Constitution Principle V |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **I. Housing-First**: YES — Ticket pages follow `WaitingListByResident` pattern. Partial controller with Base, positional SP args, `GetDataLoadDataSetAsync`, `SplitDataSet`, `SmartPageViewModel`.
- [x] **II. Layer Boundary**: PASS — Controllers call `MastersServies` only. No direct DataEngine calls. Gateway SPs already mapped in `ProcedureMapper`.
- [x] **III. Contract Preservation**: PASS — All frozen identifiers preserved (`pageName_`, `ActionType`, `idaraID`, `entrydata`, `hostname`, `p01`..`p50`, `parameter_01`..`parameter_50`).
- [x] **IV. Gateway Procedure Architecture**: PASS — Only `Masters_DataLoad` and `Masters_CRUD` mapped. New `@pageName_` branches route to `[Tickets].[TicketDL]`/`[Tickets].[ServiceDL]` and `[Tickets].[TicketSP]`/`[Tickets].[ServiceSP]`.
- [x] **V. Server-Side UI Composition**: PASS — All UI state built in controller via `FormConfig`, `SmartTableDsModel`, `SmartPageViewModel`. Views thin.
- [x] **VI. Permission-Gated Actions**: PASS — Permissions from DataSet table 0 (`permissionTypeName_E`). Toolbar actions gated server-side.
- [x] **VII. Trust Active Code**: PASS — `SmartFoundation.Database` is reference only; verified against live deployed DB.
- [x] **VIII. Build And Test**: PASS — Will verify with `dotnet build` and `dotnet test` after implementation.

## Project Structure

### Documentation (this feature)

```text
specs/main/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
SmartFoundation.Mvc/
├── Controllers/
│   ├── Tickets/
│   │   ├── TicketController.Base.cs         # Session context, SplitDataSet, DI
│   │   ├── TicketController.ServiceCatalog.cs  # ServiceCatalogueList action
│   │   ├── TicketController.TicketList.cs       # TicketList action
│   │   └── TicketController.TicketDetails.cs    # TicketDetails action
│   ├── CrudController.cs                    # Generic CRUD contract (unchanged)
│   └── Housing/                             # Existing Housing controllers (unchanged)
├── Views/
│   └── Tickets/
│       ├── ServiceCatalogueList.cshtml      # Thin view: SmartRenderer
│       ├── TicketList.cshtml                # Thin view: SmartRenderer
│       └── TicketDetails.cshtml             # Thin view: SmartRenderer
└── Program.cs                               # Add TicketController DI registration

SmartFoundation.Application/
├── Services/
│   ├── MastersServies.cs                    # Unchanged — already handles gateway calls
│   └── BaseService.cs                       # Unchanged
├── Mapping/
│   └── ProcedureMapper.cs                   # Unchanged — gateway SPs already mapped
└── Extensions/
    └── ServiceCollectionExtensions.cs       # No change needed (MastersServies already registered)

SmartFoundation.Database/
├── dbo/Stored Procedures/
│   ├── Masters_DataLoad.sql                 # Add @pageName_ branches for Tickets
│   └── Masters_CRUD.sql                     # Add @pageName_ + @ActionType branches for Tickets
└── Tickets/                                  # Already deployed (reference only)
```

**Structure Decision**: Follows Housing pattern exactly. `TicketController` is a partial class split into Base + per-page files, mirroring `HousingController`. No new services needed — `MastersServies` already provides the gateway methods. Gateway SPs get new routing branches.

## Complexity Tracking

No violations. All 8 constitution principles pass.
