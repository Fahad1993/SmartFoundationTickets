# Tasks: Tickets Module

**Input**: Design documents from `/specs/main/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to
- Include exact file paths in descriptions

## Path Conventions

- **Controllers**: `SmartFoundation.Mvc/Controllers/Tickets/`
- **Views**: `SmartFoundation.Mvc/Views/Tickets/`
- **Services**: `SmartFoundation.Application/Services/` (unchanged — uses MastersServies)
- **Gateway SPs**: `SmartFoundation.Database/dbo/Stored Procedures/`
- **Tickets SPs**: `SmartFoundation.Database/Tickets/Stored Procedures/` (reference only)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Gateway routing and controller base class — shared by all user stories.

- [x] T001 Add Tickets page routing branches to `Masters_DataLoad.sql` before "PAGE NOT FOUND" block (line ~2123): route `ServiceCatalogueList`, `ServiceDDL`, `ServiceCatalogueSuggestions` → `[Tickets].[ServiceDL]`; route `TicketList`, `TicketDetails`, `TicketHistory`, `StatusDDL` → `[Tickets].[TicketDL]` in `SmartFoundation.Database/dbo/Stored Procedures/Masters_DataLoad.sql`
- [x] T002 Add Tickets CRUD routing branch to `Masters_CRUD.sql` before "DO NOT TOUCH" block (line ~5157): route `pageName_='Tickets'` with `@ActionType` values `INSERT_TICKET`, `INSERT_SERVICE`, `UPDATE_SERVICE`, `DELETE_SERVICE`, `INSERT_ROUTING_RULE`, `CLOSE_ROUTING_RULE`, `UPSERT_SLA_POLICY` → respective `[Tickets].[TicketSP]` and `[Tickets].[ServiceSP]` calls with permission check in `SmartFoundation.Database/dbo/Stored Procedures/Masters_CRUD.sql`
- [x] T003 [P] Execute and verify gateway routing on `appstest/DATACORE` — run `sqlcmd` to ALTER both gateway SPs, then test each `pageName_` route returns data
- [x] T004 [P] Create `TicketController.Base.cs` in `SmartFoundation.Mvc/Controllers/Tickets/TicketController.Base.cs` — partial class with session fields (`usersId`, `IdaraId`, `HostName`), `InitPageContext(out redirect)`, `SplitDataSet(ds)`, DI injection of `MastersServies` and `CrudController`, mirroring `HousingController.Base.cs`
- [x] T005 Register `TicketController` as scoped in `SmartFoundation.Mvc/Program.cs` via `builder.Services.AddScoped<TicketController>();`

---

## Phase 2: User Story 1 — Service Catalogue Page (Priority: P1) MVP

**Goal**: Service catalogue listing page with routing/SLA details and full CRUD (INSERT_SERVICE, UPDATE_SERVICE, DELETE_SERVICE, INSERT_ROUTING_RULE, CLOSE_ROUTING_RULE, UPSERT_SLA_POLICY)

**Independent Test**: Navigate to `/Tickets/ServiceCatalogueList`, see 5 seeded services, add a new service, edit it, close its routing rule, upsert SLA policy, delete the service

### Implementation for User Story 1

- [x] T006 [US1] Create `TicketController.ServiceCatalog.cs` in `SmartFoundation.Mvc/Controllers/Tickets/TicketController.ServiceCatalog.cs` — `ServiceCatalogueList()` action: call `GetDataLoadDataSetAsync("ServiceCatalogueList", ...)`, `SplitDataSet`, read permissions from table 0, build DDL lookups (TicketClassDDL, PriorityDDL via `_CrudController.GetDDLValues`), map dt1 columns/rows to `TableColumn` and `Dictionary<string, object?>`, build `SmartTableDsModel` with toolbar actions (Add/Edit/Delete service, Add/Close routing rule, Upsert SLA), build CRUD `FormConfig` field lists for each action with hidden fields (`pageName_=Tickets`, `ActionType`, `idaraID`, `entrydata`, `hostname`, `redirectAction=ServiceCatalogueList`, `redirectController=Tickets`), assemble `SmartPageViewModel`, return `View("Tickets/ServiceCatalogueList", page)`
- [x] T007 [P] [US1] Create `SmartFoundation.Mvc/Views/Tickets/ServiceCatalogueList.cshtml` — thin view: `@model SmartPageViewModel`, `@await Component.InvokeAsync("SmartRenderer", new { model = Model })`
- [x] T008 [US1] Build verification: `dotnet build SmartFoundation.Mvc/SmartFoundation.Mvc.csproj` must succeed

**Checkpoint**: Service Catalogue page renders, lists services, CRUD forms post to `/crud/insert|update|delete`

---

## Phase 3: User Story 2 — Ticket List Page (Priority: P2)

**Goal**: Ticket listing page with filters (status, service, DSD) and click-through to details

**Independent Test**: Navigate to `/Tickets/TicketList`, see 5 seeded tickets, filter by status, click ticket to open details

### Implementation for User Story 2

- [x] T009 [US2] Create `TicketController.TicketList.cs` in `SmartFoundation.Mvc/Controllers/Tickets/TicketController.TicketList.cs` — `TicketList()` action: call `GetDataLoadDataSetAsync("TicketList", idaraID, usersId, hostName, filterStatusID, filterServiceID, filterDSDID)`, `SplitDataSet`, read permissions, build DDL lookups (StatusDDL, ServiceDDL), build search `FormConfig` with filter fields, map dt1 to `SmartTableDsModel` with columns (ticketNo, title, serviceName, priority, status, assignedUser, entryDate), add click-through navigation to TicketDetails, assemble `SmartPageViewModel`
- [x] T010 [P] [US2] Create `SmartFoundation.Mvc/Views/Tickets/TicketList.cshtml` — thin view: `@model SmartPageViewModel`, `@await Component.InvokeAsync("SmartRenderer", new { model = Model })`
- [x] T011 [US2] Build verification: `dotnet build SmartFoundation.Mvc/SmartFoundation.Mvc.csproj` must succeed

**Checkpoint**: Ticket List page renders with filters, lists tickets, click-through works

---

## Phase 4: User Story 3 — Ticket Details + Creation Page (Priority: P3)

**Goal**: Ticket details page with full info, history timeline, and ticket creation form (INSERT_TICKET with business rules)

**Independent Test**: Create a new resident ticket via form → verify ticket appears in list → open details → see history timeline with CREATED event

### Implementation for User Story 3

- [x] T012 [US3] Create `TicketController.TicketDetails.cs` in `SmartFoundation.Mvc/Controllers/Tickets/TicketController.TicketDetails.cs` — `TicketDetails(int? id)` action: if `id` provided, call `GetDataLoadDataSetAsync("TicketDetails", idaraID, usersId, hostName, id)` + `GetDataLoadDataSetAsync("TicketHistory", idaraID, usersId, hostName, id)`, split both DataSets, read permissions, build detail `FormConfig` with read-only ticket fields, build history `SmartTableDsModel` from second DataSet, build create-ticket `FormConfig` with fields (ticketClassID_FK, requesterTypeID_FK, requesterUserID_FK, requesterResidentID_FK, serviceID_FK, title, description_, suggestedPriorityID_FK, locationBuildingNo, locationUnitNo, locationArea, requiresQualityReview, isOtherService) + DDL lookups (StatusDDL, ServiceDDL, TicketClassDDL, PriorityDDL, RequesterTypeDDL), assemble `SmartPageViewModel`
- [x] T013 [P] [US3] Create `SmartFoundation.Mvc/Views/Tickets/TicketDetails.cshtml` — thin view: `@model SmartPageViewModel`, `@await Component.InvokeAsync("SmartRenderer", new { model = Model })`
- [x] T014 [US3] Build verification: `dotnet build SmartFoundation.Mvc/SmartFoundation.Mvc.csproj` must succeed

**Checkpoint**: Ticket Details shows full info + history, Create ticket form posts to `/crud/insert` with `ActionType=INSERT_TICKET`

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final verification and cleanup

- [x] T015 Run `dotnet build SmartFoundation.Mvc/SmartFoundation.Mvc.csproj` — zero errors
- [x] T016 Run `dotnet test SmartFoundation.Application.Tests/SmartFoundation.Application.Tests.csproj` — all existing tests pass
- [ ] T017 Verify all 3 pages render on running app: `/Tickets/ServiceCatalogueList`, `/Tickets/TicketList`, `/Tickets/TicketDetails`
- [ ] T018 Verify CRUD flow end-to-end: insert service → insert ticket → view ticket details → see history event

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **US1 - Service Catalogue (Phase 2)**: Depends on Phase 1 (T001-T005)
- **US2 - Ticket List (Phase 3)**: Depends on Phase 1 only
- **US3 - Ticket Details (Phase 4)**: Depends on Phase 1 only
- **Polish (Phase 5)**: Depends on all user stories complete

### User Story Dependencies

- **US1**: Independent after Setup — no dependency on US2 or US3
- **US2**: Independent after Setup — no dependency on US1 or US3
- **US3**: Independent after Setup — no dependency on US1 or US2 (but end-to-end test benefits from US1 data)

### Parallel Opportunities

- T001 and T002 can run in parallel (different gateway SP files)
- T003 and T004 can run in parallel (SQL vs C#)
- T006, T009, T012 can run in parallel (different controller files)
- T007, T010, T013 can run in parallel (different view files)

---

## Parallel Example: All User Stories

```
# After Phase 1 completes, launch all stories in parallel:
Task: "T006 [US1] Create ServiceCatalog controller"
Task: "T009 [US2] Create TicketList controller"
Task: "T012 [US3] Create TicketDetails controller"

# Then all views in parallel:
Task: "T007 [US1] Create ServiceCatalogueList.cshtml"
Task: "T010 [US2] Create TicketList.cshtml"
Task: "T013 [US3] Create TicketDetails.cshtml"
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1: Setup (gateway routing + controller base + DI)
2. Complete Phase 2: US1 Service Catalogue
3. **STOP and VALIDATE**: Service CRUD works end-to-end
4. Deploy/demo if ready

### Incremental Delivery

1. Setup → Foundation ready
2. US1 → Service Catalogue works → Deploy (MVP!)
3. US2 → Ticket List works → Deploy
4. US3 → Ticket Details + Creation works → Deploy
5. Polish → All verified → Done

---

## Notes

- [P] tasks = different files, no dependencies
- Each user story independently completable and testable
- All views are thin (SmartRenderer only) per Constitution Principle V
- All CRUD posts go through existing `CrudController` → `Masters_CRUD`
- No new services needed — uses existing `MastersServies`
- Database layer already deployed and tested (21 tables, 4 SPs, 3 views)
