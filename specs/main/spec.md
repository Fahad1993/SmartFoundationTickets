# Feature Specification: Tickets Module

## Overview

Build a full Tickets module following the Housing-style page pattern (`WaitingListByResident`). The module provides ticket management for service requests — covering service catalog administration, ticket creation, status tracking, SLA monitoring, and quality review — all within the existing SmartFoundation MVC architecture.

## Background

The database layer is already deployed and tested on `DATACORE`:
- **21 tables** in the `[Tickets]` schema (lookups, master, transaction, flow)
- **4 stored procedures**: `TicketDL`, `TicketSP`, `ServiceDL`, `ServiceSP`
- **3 views**: `V_ServiceFullDefinition`, `V_TicketFullDetails`, `V_TicketLastAction`
- **Seed data**: 8 lookup tables with 5-11 rows each, 5 services, 5 tickets, plus routing/SLA/flow data
- **All smoke tests pass** (6 test suites, 0 failures)

## Requirements

### R1: Service Catalog Page
- PageName: `ServiceCatalogueList`
- Lists active services with routing rule info and SLA policy details (via `V_ServiceFullDefinition`)
- DDL lookups for TicketClass, Priority
- CRUD actions: INSERT_SERVICE, UPDATE_SERVICE, DELETE_SERVICE (soft delete)
- Sub-actions: INSERT_ROUTING_RULE, CLOSE_ROUTING_RULE, UPSERT_SLA_POLICY
- Permission-gated toolbar (insert, update, delete service)

### R2: Ticket List Page
- PageName: `TicketList`
- Lists active tickets filtered by status, service, assigned user, DSD
- DDL lookups for TicketStatus, Service (active only)
- Shows ticket number, title, service name, priority, status, assigned user, entry date
- Click-through to TicketDetails

### R3: Ticket Details Page
- PageName: `TicketDetails`
- Full ticket information including all joined lookup names
- TicketHistory timeline (via `TicketDL @pageName_ = 'TicketHistory'`)
- Permission-gated actions (future: ASSIGN, UPDATE_STATUS, etc.)
- Displays SLA status, pause sessions, clarification requests, arbitration cases

### R4: Ticket Creation
- Via `TicketSP @Action = 'INSERT_TICKET'`
- Business rules enforced server-side in SP:
  - BR-01: Resident tickets require `requesterResidentID_FK`, no `requesterUserID_FK`
  - BR-02: Internal tickets require `requesterUserID_FK`, no `requesterResidentID_FK`
  - BR-03: Non-Other tickets require `serviceID_FK`
  - Auto-generates `ticketNo` as `TKT-YYYY-NNNNN`
  - Sets `rootTicketID_FK = self` for top-level tickets
  - Creates CREATED history event
  - Writes AuditLog entry

### R5: Gateway Integration
- Add `pageName_` routing entries in `Masters_DataLoad.sql` for: `ServiceCatalogueList`, `ServiceDDL`, `ServiceCatalogueSuggestions`, `RoutingRuleDDL`, `TicketList`, `TicketDetails`, `TicketHistory`, `StatusDDL`
- Add `pageName_` + `ActionType` routing entries in `Masters_CRUD.sql` for all Ticket SP actions

## Non-Goals (Future Phases)
- Ticket assignment workflow
- Status transition engine (beyond creation)
- SLA breach notifications
- Quality review workflow
- Arbitration management UI
- Child ticket creation
- Pause/resume UI
- File attachments on tickets

## Technical Constraints
- MUST follow Housing-style pattern (Constitution Principle I)
- MUST use `MastersServies.GetDataLoadDataSetAsync` for reads
- MUST use `CrudController` -> `MastersServies.GetCrudDataSetAsync` for writes
- MUST derive permissions from DataSet table 0
- MUST build `SmartPageViewModel` server-side
- MUST keep views thin (SmartRenderer only)
- MUST NOT bypass `ProcedureMapper` for SP resolution
- MUST NOT map downstream Ticket SPs directly in `ProcedureMapper`
