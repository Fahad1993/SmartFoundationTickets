# Research: Tickets Module

## R1: Gateway SP Routing Pattern

**Decision**: Add `ELSE IF @pageName_` branches to `Masters_DataLoad.sql` (line ~2123) and `Masters_CRUD.sql` (line ~5157), before the "DO NOT TOUCH" blocks.

**Rationale**: Every Housing/VIC page follows this exact pattern:
- `Masters_DataLoad`: `ELSE IF @pageName_ = 'X'` → `EXEC [Schema].[PageDL]` passing through `@pageName_`, `@idaraID`, `@entrydata`, `@hostName`, plus `@parameter_01..NN` as filter params
- `Masters_CRUD`: `ELSE IF @pageName_ = 'X'` → permission check via `V_GetListUserPermission` → `IF @ActionType = 'Y'` → `EXEC [Schema].[PageSP]` mapping `@parameter_01..NN` to typed SP params

**Alternatives considered**:
- Separate `Tickets_DataLoad` / `Tickets_CRUD` gateway SPs: Rejected because it would require new `ProcedureMapper` entries and break the single-gateway architecture
- Direct SP calls from app layer: Rejected by Constitution Principle IV

## R2: Controller Architecture

**Decision**: `TicketController` as a partial class with `TicketController.Base.cs` mirroring `HousingController.Base.cs`.

**Rationale**: Exact same pattern proven across 30+ Housing pages. Base provides:
- `InitPageContext(out redirect)` — reads session (usersID, IdaraID, HostName, etc.)
- `SplitDataSet(ds)` — splits into permissionTable + dt1..dt9
- DI injection of `MastersServies` and `CrudController`

**Alternatives considered**:
- Single `TicketController.cs` file: Rejected — Housing uses partial classes per page for maintainability
- New base class `TicketControllerBase`: Rejected — Housing reuses the same `HousingController` partial; follow same

## R3: pageName_ Values for Tickets

**Decision**: Use these `pageName_` values matching the existing `TicketDL` and `ServiceDL` procedures:

| pageName_ | Gateway Routes To | Returns |
|-----------|------------------|---------|
| `ServiceCatalogueList` | `[Tickets].[ServiceDL] @pageName_='ServiceCatalogueList'` | Table1: Services with routing/SLA (via view) |
| `ServiceDDL` | `[Tickets].[ServiceDL] @pageName_='ServiceDDL'` | DDL: Active services |
| `ServiceCatalogueSuggestions` | `[Tickets].[ServiceDL] @pageName_='ServiceCatalogueSuggestions'` | DDL: Suggestions |
| `TicketList` | `[Tickets].[TicketDL] @pageName_='TicketList'` | Table1: Tickets list |
| `TicketDetails` | `[Tickets].[TicketDL] @pageName_='TicketDetails'` | Table1: Full ticket |
| `TicketHistory` | `[Tickets].[TicketDL] @pageName_='TicketHistory'` | Table1: History events |
| `StatusDDL` | `[Tickets].[TicketDL] @pageName_='StatusDDL'` | DDL: Active statuses |

**Rationale**: These pageName_ values match the IF/ELSE IF branches already coded in `TicketDL.sql` and `ServiceDL.sql`. The gateway SPs just need to route to these downstream procedures.

## R4: CRUD Action Mapping

**Decision**: For `Masters_CRUD`, route all Ticket writes through a single `pageName_ = 'Tickets'` branch, with `@ActionType` values:

| ActionType | Downstream SP Call |
|-----------|-------------------|
| `INSERT_TICKET` | `[Tickets].[TicketSP] @Action='INSERT_TICKET'` |
| `INSERT_SERVICE` | `[Tickets].[ServiceSP] @Action='INSERT_SERVICE'` |
| `UPDATE_SERVICE` | `[Tickets].[ServiceSP] @Action='UPDATE_SERVICE'` |
| `DELETE_SERVICE` | `[Tickets].[ServiceSP] @Action='DELETE_SERVICE'` |
| `INSERT_ROUTING_RULE` | `[Tickets].[ServiceSP] @Action='INSERT_ROUTING_RULE'` |
| `CLOSE_ROUTING_RULE` | `[Tickets].[ServiceSP] @Action='CLOSE_ROUTING_RULE'` |
| `UPSERT_SLA_POLICY` | `[Tickets].[ServiceSP] @Action='UPSERT_SLA_POLICY'` |

**Rationale**: Follows the Housing pattern where a single pageName_ maps to a downstream SP that uses `@ActionType` for branching. The `@parameter_01..50` map to the typed params of the downstream SP.

## R5: No New Application Services Needed

**Decision**: Use existing `MastersServies.GetDataLoadDataSetAsync` and `MastersServies.GetCrudDataSetAsync` directly. No `TicketService` class.

**Rationale**: Constitution Principle II exception explicitly states "MastersServies is an existing gateway service and should be respected in existing flows." The gateway pattern means the app layer doesn't need feature-specific services — the gateway SPs handle routing.

## R6: View Structure

**Decision**: Three thin Razor views, each containing only `SmartRenderer` invocation (matching `WaitingListByResident.cshtml`).

**Rationale**: Constitution Principle V mandates thin views. The `SmartPageViewModel` built in the controller contains all rendering instructions.

## R7: DI Registration

**Decision**: Register `TicketController` as scoped in `Program.cs` (matching how `CrudController` is registered).

**Rationale**: `TicketController` depends on `MastersServies` and `CrudController`, both already registered as scoped.
