# Tasks: Multi-Department Ticketing System with Service Catalogue

**Input**: Design documents from `plan.md`
**Prerequisites**: plan.md (required), spec.md (not yet created — user stories derived from plan.md Section 19 specs)

**Tests**: Test tasks are included per plan.md Section 20 testing strategy.

**Organization**: Tasks are grouped by user story (Spec 01–Spec 12 from plan.md Section 19) to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Database tables**: `SmartFoundation.Database/Tickets/Tables/`
- **Database stored procedures**: `SmartFoundation.Database/Tickets/Stored Procedures/`
- **Database views**: `SmartFoundation.Database/Tickets/Views/`
- **Seed scripts**: `SmartFoundation.Database/Tickets/Scripts/`
- **Application services**: `SmartFoundation.Application/Services/`
- **MVC controllers**: `SmartFoundation.Mvc/Controllers/Tickets/`
- **MVC views**: `SmartFoundation.Mvc/Views/Tickets/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the `[Tickets]` schema and prepare the folder structure for all database objects.

- [X] T001 Create `[Tickets]` schema in `SmartFoundation.Database/Tickets/Scripts/CreateSchema.sql`
- [X] T002 [P] Create folder structure under `SmartFoundation.Database/Tickets/` for Tables, Stored Procedures, Views, Functions, Scripts
- [X] T003 [P] Add new Tickets folders to `SmartFoundation.Database/SmartFoundation.Database.sqlproj` ItemGroup
- [X] T004 [P] Create folder structure under `SmartFoundation.Mvc/Controllers/Tickets/` for controllers
- [X] T005 [P] Create folder structure under `SmartFoundation.Mvc/Views/Tickets/` for views

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish lookup tables and seed data required by ALL subsequent specs. MUST be complete before any user story work begins.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T006 [P] Create `[Tickets].[TicketStatus]` lookup table in `SmartFoundation.Database/Tickets/Tables/TicketStatus.sql`
- [X] T007 [P] Create `[Tickets].[TicketClass]` lookup table in `SmartFoundation.Database/Tickets/Tables/TicketClass.sql`
- [X] T008 [P] Create `[Tickets].[Priority]` lookup table in `SmartFoundation.Database/Tickets/Tables/Priority.sql`
- [X] T009 [P] Create `[Tickets].[RequesterType]` lookup table in `SmartFoundation.Database/Tickets/Tables/RequesterType.sql`
- [X] T010 [P] Create `[Tickets].[PauseReason]` lookup table in `SmartFoundation.Database/Tickets/Tables/PauseReason.sql`
- [X] T011 [P] Create `[Tickets].[ArbitrationReason]` lookup table in `SmartFoundation.Database/Tickets/Tables/ArbitrationReason.sql`
- [X] T012 [P] Create `[Tickets].[ClarificationReason]` lookup table in `SmartFoundation.Database/Tickets/Tables/ClarificationReason.sql`
- [X] T013 [P] Create `[Tickets].[QualityReviewResult]` lookup table in `SmartFoundation.Database/Tickets/Tables/QualityReviewResult.sql`
- [X] T014 Create seed script for all lookup values in `SmartFoundation.Database/Tickets/Scripts/SeedLookups.sql`
- [X] T015 Add all lookup table `.sql` files and seed script to `SmartFoundation.Database.sqlproj` Build ItemGroup
- [X] T016 Validate lookup uniqueness and seed integrity via SQL smoke tests in `SmartFoundation.Database/Tickets/Scripts/TestLookups.sql`

**Checkpoint**: All lookup tables exist, seed values inserted, codes unique — foundation ready for user story implementation

---

## Phase 3: User Story 1 — Service Catalogue Foundations (Priority: P1) 🎯 MVP

**Goal**: Establish the service catalogue, routing rules, SLA policies, and catalogue suggestion tables plus their write procedures and read models.

**Independent Test**: Services can be created/updated/deactivated through `ServiceSP`; routing rules can be added with valid `TargetDSDID_FK`; SLA policies are retrievable per service and priority.

### Database Structure for US1

- [X] T017 [P] [US1] Create `[Tickets].[Service]` master table in `SmartFoundation.Database/Tickets/Tables/Service.sql`
- [X] T018 [P] [US1] Create `[Tickets].[ServiceRoutingRule]` master table in `SmartFoundation.Database/Tickets/Tables/ServiceRoutingRule.sql`
- [X] T019 [P] [US1] Create `[Tickets].[ServiceSLAPolicy]` master table in `SmartFoundation.Database/Tickets/Tables/ServiceSLAPolicy.sql`
- [X] T020 [P] [US1] Create `[Tickets].[ServiceCatalogSuggestion]` master table in `SmartFoundation.Database/Tickets/Tables/ServiceCatalogSuggestion.sql`
- [X] T021 [US1] Add all US1 table files to `SmartFoundation.Database.sqlproj` Build ItemGroup

### Database Stored Procedures for US1

- [X] T022 [US1] Create `[Tickets].[ServiceSP]` with actions `INSERT_SERVICE`, `UPDATE_SERVICE`, `DELETE_SERVICE`, `INSERT_ROUTING_RULE`, `CLOSE_ROUTING_RULE`, `UPSERT_SLA_POLICY`, `APPROVE_SERVICE_SUGGESTION`, `REJECT_SERVICE_SUGGESTION` in `SmartFoundation.Database/Tickets/Stored Procedures/ServiceSP.sql`
- [X] T023 [US1] Implement service insert/update/deactivate actions in `[Tickets].[ServiceSP]`
- [X] T024 [US1] Implement routing rule insert/close actions with `TargetDSDID_FK` validation and effective dating in `[Tickets].[ServiceSP]`
- [X] T025 [US1] Implement SLA policy upsert action in `[Tickets].[ServiceSP]`
- [X] T026 [US1] Implement service suggestion approve/reject actions in `[Tickets].[ServiceSP]`

### Database Views & Read Models for US1

- [X] T027 [US1] Create `[Tickets].[V_ServiceFullDefinition]` view in `SmartFoundation.Database/Tickets/Views/V_ServiceFullDefinition.sql`
- [X] T028 [US1] Create `[Tickets].[ServiceDL]` procedure for catalogue listing, routing rule lookup, SLA policy lookup, suggestion review in `SmartFoundation.Database/Tickets/Stored Procedures/ServiceDL.sql`

### Tests for US1

- [X] T029 [US1] Test service CRUD through `ServiceSP` in `SmartFoundation.Database/Tickets/Scripts/TestServiceSP.sql`
- [X] T030 [US1] Test routing rule insert/close and historical replacement in `SmartFoundation.Database/Tickets/Scripts/TestServiceRoutingRule.sql`
- [X] T031 [US1] Test SLA policy upsert and retrieval per service+priority in `SmartFoundation.Database/Tickets/Scripts/TestServiceSLAPolicy.sql`

**Checkpoint**: Service catalogue foundation fully functional — services, routing rules, SLA policies all manageable through SPs

---

## Phase 4: User Story 2 — Core Ticket Backbone (Priority: P2)

**Goal**: Enable ticket creation, current-state storage, history logging, and basic read models.

**Independent Test**: Tickets can be created for resident or internal user; `Other` tickets work without `ServiceID_FK`; `TicketHistory` receives creation events; `rootTicketID_FK` is set correctly.

### Database Structure for US2

- [X] T032 [P] [US2] Create `[Tickets].[Ticket]` transaction table in `SmartFoundation.Database/Tickets/Tables/Ticket.sql`
- [X] T033 [P] [US2] Create `[Tickets].[TicketHistory]` history table in `SmartFoundation.Database/Tickets/Tables/TicketHistory.sql`
- [X] T034 [US2] Add US2 table files to `SmartFoundation.Database.sqlproj` Build ItemGroup

### Database Stored Procedures for US2

- [X] T035 [US2] Create `[Tickets].[TicketSP]` with `INSERT_TICKET` action in `SmartFoundation.Database/Tickets/Stored Procedures/TicketSP.sql`
- [X] T036 [US2] Implement requester-type validation (resident vs internal, mutual exclusivity) in `[Tickets].[TicketSP]` `INSERT_TICKET`
- [X] T037 [US2] Implement `rootTicketID_FK` initialization logic in `[Tickets].[TicketSP]` `INSERT_TICKET`
- [X] T038 [US2] Implement `TicketHistory` creation-event insertion within `INSERT_TICKET` transaction in `[Tickets].[TicketSP]`
- [X] T039 [US2] Implement JSON audit logging to `dbo.AuditLog` within `INSERT_TICKET` in `[Tickets].[TicketSP]`

### Database Views & Read Models for US2

- [X] T040 [US2] Create `[Tickets].[V_TicketFullDetails]` view in `SmartFoundation.Database/Tickets/Views/V_TicketFullDetails.sql`
- [X] T041 [US2] Create `[Tickets].[V_TicketLastAction]` view in `SmartFoundation.Database/Tickets/Views/V_TicketLastAction.sql`
- [X] T042 [US2] Create `[Tickets].[TicketDL]` procedure for ticket details and basic list actions in `SmartFoundation.Database/Tickets/Stored Procedures/TicketDL.sql`

### Tests for US2

- [X] T043 [US2] Test ticket creation for resident requester type in `SmartFoundation.Database/Tickets/Scripts/TestTicketCreation.sql`
- [X] T044 [US2] Test ticket creation for internal user requester type in `SmartFoundation.Database/Tickets/Scripts/TestTicketCreation.sql`
- [X] T045 [US2] Test `Other` ticket creation without `ServiceID_FK` in `SmartFoundation.Database/Tickets/Scripts/TestTicketCreation.sql`
- [X] T046 [US2] Test `TicketHistory` creation event logging in `SmartFoundation.Database/Tickets/Scripts/TestTicketHistory.sql`

**Checkpoint**: Core ticket creation works — tickets storeable, history logged, basic details queryable

---

## Phase 5: User Story 3 — Assignment and Work Start (Priority: P3)

**Goal**: Support organizational queue handling, direct execution assignment, and supervisor rejection.

**Independent Test**: Eligible users can be assigned only within allowed scope; ticket status changes are logged to history; inbox queries return correct tickets by scope.

### Database Stored Procedures for US3

- [ ] T047 [US3] Implement `ASSIGN_TICKET` action with `UserDistributor` eligibility validation in `[Tickets].[TicketSP]`
- [ ] T048 [US3] Implement `MOVE_TO_IN_PROGRESS` action in `[Tickets].[TicketSP]`
- [ ] T049 [US3] Implement `REJECT_TO_SUPERVISOR` action in `[Tickets].[TicketSP]`
- [ ] T050 [US3] Implement assignment and status-change history entries within each action in `[Tickets].[TicketSP]`

### Database Read Models for US3

- [ ] T051 [US3] Extend `[Tickets].[TicketDL]` with inbox-style reads by current queue and assignee in `SmartFoundation.Database/Tickets/Stored Procedures/TicketDL.sql`

### Tests for US3

- [ ] T052 [US3] Test assignment with valid and invalid `UserDistributor` scope in `SmartFoundation.Database/Tickets/Scripts/TestAssignment.sql`
- [ ] T053 [US3] Test move-to-in-progress status transition and history logging in `SmartFoundation.Database/Tickets/Scripts/TestAssignment.sql`
- [ ] T054 [US3] Test reject-to-supervisor action and history logging in `SmartFoundation.Database/Tickets/Scripts/TestAssignment.sql`
- [ ] T055 [US3] Test inbox query returns correct tickets by organizational scope in `SmartFoundation.Database/Tickets/Scripts/TestAssignment.sql`

**Checkpoint**: Assignment and work-start flow operational — queue inbox, assignment, status transitions all working

---

## Phase 6: User Story 4 — Clarification Flow (Priority: P4)

**Goal**: Support missing-information handling separately from scope disputes, with pause-session integration.

**Independent Test**: Clarification can be opened without using arbitration; clarification response updates ticket flow correctly; blocking clarification opens a valid pause session.

### Database Structure for US4

- [X] T056 [US4] Create `[Tickets].[ClarificationRequest]` transaction table in `SmartFoundation.Database/Tickets/Tables/ClarificationRequest.sql`
- [X] T057 [US4] Add `ClarificationRequest` table file to `SmartFoundation.Database.sqlproj` Build ItemGroup

### Database Stored Procedures for US4

- [ ] T058 [US4] Create `[Tickets].[ClarificationSP]` with `OPEN_CLARIFICATION_REQUEST`, `RESPOND_TO_CLARIFICATION`, `CLOSE_CLARIFICATION_REQUEST` actions in `SmartFoundation.Database/Tickets/Stored Procedures/ClarificationSP.sql`
- [ ] T059 [US4] Implement `OPEN_CLARIFICATION_REQUEST` with ticket history and audit logging in `[Tickets].[ClarificationSP]`
- [ ] T060 [US4] Implement `RESPOND_TO_CLARIFICATION` with ticket flow update in `[Tickets].[ClarificationSP]`
- [ ] T061 [US4] Implement `CLOSE_CLARIFICATION_REQUEST` in `[Tickets].[ClarificationSP]`
- [ ] T062 [US4] Implement pause session creation when clarification blocks execution in `[Tickets].[ClarificationSP]`

### Tests for US4

- [ ] T063 [US4] Test clarification open without triggering arbitration in `SmartFoundation.Database/Tickets/Scripts/TestClarification.sql`
- [ ] T064 [US4] Test clarification response updates ticket flow in `SmartFoundation.Database/Tickets/Scripts/TestClarification.sql`
- [ ] T065 [US4] Test blocking clarification creates valid pause session in `SmartFoundation.Database/Tickets/Scripts/TestClarification.sql`

**Checkpoint**: Clarification flow works independently from arbitration — missing info handled correctly with pause integration

---

## Phase 7: User Story 5 — Arbitration Flow (Priority: P5)

**Goal**: Support wrong-scope disputes and controlled redirection through arbitration.

**Independent Test**: Disputes can be opened only through allowed supervisory flow; arbitration decisions correctly update target queue and history; arbitration load can be listed by organizational level.

### Database Structure for US5

- [X] T066 [US5] Create `[Tickets].[ArbitrationCase]` transaction table in `SmartFoundation.Database/Tickets/Tables/ArbitrationCase.sql`
- [X] T067 [US5] Add `ArbitrationCase` table file to `SmartFoundation.Database.sqlproj` Build ItemGroup

### Database Stored Procedures for US5

- [ ] T068 [US5] Create `[Tickets].[ArbitrationSP]` with `OPEN_ARBITRATION_CASE`, `DECIDE_REDIRECT`, `DECIDE_OVERRULE`, `CANCEL_ARBITRATION_CASE` actions in `SmartFoundation.Database/Tickets/Stored Procedures/ArbitrationSP.sql`
- [ ] T069 [US5] Implement `OPEN_ARBITRATION_CASE` with supervisory-chain validation in `[Tickets].[ArbitrationSP]`
- [ ] T070 [US5] Implement `DECIDE_REDIRECT` with target queue update and history in `[Tickets].[ArbitrationSP]`
- [ ] T071 [US5] Implement `DECIDE_OVERRULE` in `[Tickets].[ArbitrationSP]`
- [ ] T072 [US5] Implement `CANCEL_ARBITRATION_CASE` in `[Tickets].[ArbitrationSP]`
- [ ] T073 [US5] Implement arbitration-related ticket history entries and audit logging in `[Tickets].[ArbitrationSP]`

### Database Read Models for US5

- [ ] T074 [US5] Create `[Tickets].[ArbitrationDL]` procedure for open disputes, dispute history, routing correction candidates in `SmartFoundation.Database/Tickets/Stored Procedures/ArbitrationDL.sql`

### Tests for US5

- [ ] T075 [US5] Test arbitration case open through supervisory flow in `SmartFoundation.Database/Tickets/Scripts/TestArbitration.sql`
- [ ] T076 [US5] Test redirect decision updates target queue and history in `SmartFoundation.Database/Tickets/Scripts/TestArbitration.sql`
- [ ] T077 [US5] Test overrule and cancel decisions in `SmartFoundation.Database/Tickets/Scripts/TestArbitration.sql`
- [ ] T078 [US5] Test arbitration load listing by organizational level via `ArbitrationDL` in `SmartFoundation.Database/Tickets/Scripts/TestArbitration.sql`

**Checkpoint**: Arbitration flow complete — scope disputes handled with correct supervisory routing and decision tracking

---

## Phase 8: User Story 6 — Parent-Child Ticketing (Priority: P6)

**Goal**: Support dependent child work with parent-child ticket relationships.

**Independent Test**: Child tickets inherit the correct root ticket; parent-child tree loads correctly; child creation is blocked when approval requirements are not satisfied.

### Database Stored Procedures for US6

- [ ] T079 [US6] Implement `CREATE_CHILD_TICKET` action with supervisor approval requirement in `[Tickets].[TicketSP]`
- [ ] T080 [US6] Implement root and parent inheritance rules (`rootTicketID_FK`, `parentTicketID_FK`) in `[Tickets].[TicketSP]`
- [ ] T081 [US6] Implement one-parent-only validation for child tickets in `[Tickets].[TicketSP]`
- [ ] T082 [US6] Implement child creation ticket history entry in `[Tickets].[TicketSP]`

### Database Read Models for US6

- [ ] T083 [US6] Extend `[Tickets].[TicketDL]` with parent/child tree loading actions in `SmartFoundation.Database/Tickets/Stored Procedures/TicketDL.sql`

### Tests for US6

- [ ] T084 [US6] Test child ticket creation with correct root and parent inheritance in `SmartFoundation.Database/Tickets/Scripts/TestParentChild.sql`
- [ ] T085 [US6] Test parent-child tree loading via `TicketDL` in `SmartFoundation.Database/Tickets/Scripts/TestParentChild.sql`
- [ ] T086 [US6] Test child creation blocked without supervisor approval in `SmartFoundation.Database/Tickets/Scripts/TestParentChild.sql`

**Checkpoint**: Parent-child ticketing works — child tickets created with proper inheritance, tree queryable

---

## Phase 9: User Story 7 — Blocking and Pause Sessions (Priority: P7)

**Goal**: Support controlled pause windows and dependency-based blocking for parent tickets.

**Independent Test**: Pause sessions store start and end correctly; ticket pause reason is visible; parent tickets resume correctly after valid unblocking.

### Database Structure for US7

- [X] T087 [US7] Create `[Tickets].[TicketPauseSession]` transaction table in `SmartFoundation.Database/Tickets/Tables/TicketPauseSession.sql`
- [X] T088 [US7] Add `TicketPauseSession` table file to `SmartFoundation.Database.sqlproj` Build ItemGroup

### Database Stored Procedures for US7

- [ ] T089 [US7] Implement `PAUSE_TICKET` action with pause reason and related-entity linking in `[Tickets].[TicketSP]`
- [ ] T090 [US7] Implement `RESUME_TICKET` action with pause-end timestamp in `[Tickets].[TicketSP]`
- [ ] T091 [US7] Implement pause validation rules (valid reason, no double-pause) in `[Tickets].[TicketSP]`
- [ ] T092 [US7] Implement parent blocking due to open child tickets in `[Tickets].[TicketSP]`
- [ ] T093 [US7] Implement pause/resume history entries in `[Tickets].[TicketSP]`

### Tests for US7

- [ ] T094 [US7] Test pause session creation with start and end timestamps in `SmartFoundation.Database/Tickets/Scripts/TestPauseSessions.sql`
- [ ] T095 [US7] Test pause reason visibility on ticket details in `SmartFoundation.Database/Tickets/Scripts/TestPauseSessions.sql`
- [ ] T096 [US7] Test parent ticket resume after child ticket completion in `SmartFoundation.Database/Tickets/Scripts/TestPauseSessions.sql`
- [ ] T097 [US7] Test parent ticket final closure blocked while child tickets remain open in `SmartFoundation.Database/Tickets/Scripts/TestPauseSessions.sql`

**Checkpoint**: Blocking and pause sessions work — pause/resume controlled, parent blocking enforced

---

## Phase 10: User Story 8 — SLA Engine (Priority: P8)

**Goal**: Support SLA initialization, pause, resume, and breach tracking per ticket.

**Independent Test**: SLA clocks initialize correctly; valid blocking pauses stop SLA progress; resuming work continues calculation correctly; breach state is stored and visible.

### Database Structure for US8

- [X] T098 [P] [US8] Create `[Tickets].[TicketSLA]` transaction table in `SmartFoundation.Database/Tickets/Tables/TicketSLA.sql`
- [X] T099 [P] [US8] Create `[Tickets].[TicketSLAHistory]` history table in `SmartFoundation.Database/Tickets/Tables/TicketSLAHistory.sql`
- [X] T100 [US8] Add US8 table files to `SmartFoundation.Database.sqlproj` Build ItemGroup

### Database Stored Procedures for US8

- [ ] T101 [US8] Implement SLA initialization from service + priority lookup in `[Tickets].[TicketSP]` (or `[Tickets].[TicketSLASP]` if separated)
- [ ] T102 [US8] Implement SLA pause calculation tied to `TicketPauseSession` in SLA logic
- [ ] T103 [US8] Implement SLA resume and elapsed-time recalculation in SLA logic
- [ ] T104 [US8] Implement breach detection logic with breach flag update in SLA logic

### Database Views for US8

- [ ] T105 [US8] Create `[Tickets].[V_TicketCurrentSLA]` view in `SmartFoundation.Database/Tickets/Views/V_TicketCurrentSLA.sql`

### Tests for US8

- [ ] T106 [US8] Test SLA initialization from service + priority in `SmartFoundation.Database/Tickets/Scripts/TestSLA.sql`
- [ ] T107 [US8] Test SLA pause on arbitration/clarification/dependency in `SmartFoundation.Database/Tickets/Scripts/TestSLA.sql`
- [ ] T108 [US8] Test SLA resume after dependency removal in `SmartFoundation.Database/Tickets/Scripts/TestSLA.sql`
- [ ] T109 [US8] Test breach detection and flag storage in `SmartFoundation.Database/Tickets/Scripts/TestSLA.sql`
- [ ] T110 [US8] Test final closure SLA completion in `SmartFoundation.Database/Tickets/Scripts/TestSLA.sql`

**Checkpoint**: SLA engine complete — clocks initialize, pause, resume, and track breaches correctly

---

## Phase 11: User Story 9 — Quality Review and Final Closure (Priority: P9)

**Goal**: Support two-stage closure with quality verification before final closure.

**Independent Test**: Final closure is blocked before operational resolution; quality review decisions update the ticket correctly; returned tickets re-enter the appropriate working state.

### Database Structure for US9

- [X] T111 [US9] Create `[Tickets].[QualityReview]` transaction table in `SmartFoundation.Database/Tickets/Tables/QualityReview.sql`
- [X] T112 [US9] Add `QualityReview` table file to `SmartFoundation.Database.sqlproj` Build ItemGroup

### Database Stored Procedures for US9

- [ ] T113 [US9] Implement `RESOLVE_OPERATIONALLY` action in `[Tickets].[TicketSP]`
- [ ] T114 [US9] Implement `CLOSE_TICKET` action with quality review gate in `[Tickets].[TicketSP]`
- [ ] T115 [US9] Implement `REOPEN_TICKET` action in `[Tickets].[TicketSP]`
- [ ] T116 [US9] Create `[Tickets].[QualityReviewSP]` with `OPEN_QUALITY_REVIEW`, `APPROVE_FINAL_CLOSURE`, `RETURN_FOR_CORRECTION`, `REJECT_CLOSURE` actions in `SmartFoundation.Database/Tickets/Stored Procedures/QualityReviewSP.sql`
- [ ] T117 [US9] Implement `OPEN_QUALITY_REVIEW` with pre-resolution validation (BR-14) in `[Tickets].[QualityReviewSP]`
- [ ] T118 [US9] Implement `APPROVE_FINAL_CLOSURE` with final status update in `[Tickets].[QualityReviewSP]`
- [ ] T119 [US9] Implement `RETURN_FOR_CORRECTION` with status revert in `[Tickets].[QualityReviewSP]`
- [ ] T120 [US9] Implement `REJECT_CLOSURE` in `[Tickets].[QualityReviewSP]`

### Tests for US9

- [ ] T121 [US9] Test final closure blocked before operational resolution in `SmartFoundation.Database/Tickets/Scripts/TestQualityReview.sql`
- [ ] T122 [US9] Test quality review approval updates ticket to final closed in `SmartFoundation.Database/Tickets/Scripts/TestQualityReview.sql`
- [ ] T123 [US9] Test return-for-correction re-enters working state in `SmartFoundation.Database/Tickets/Scripts/TestQualityReview.sql`
- [ ] T124 [US9] Test quality rejection flow in `SmartFoundation.Database/Tickets/Scripts/TestQualityReview.sql`

**Checkpoint**: Two-stage closure complete — operational resolution separate from quality-verified final closure

---

## Phase 12: User Story 10 — Catalogue Learning and Routing Correction (Priority: P10)

**Goal**: Allow repeated real-world cases to improve the service catalogue over time.

**Independent Test**: Approved suggestions can create real services; routing corrections do not overwrite historical accountability; routing change history is queryable.

### Database Structure for US10

- [X] T125 [US10] Create `[Tickets].[CatalogRoutingChangeLog]` history table in `SmartFoundation.Database/Tickets/Tables/CatalogRoutingChangeLog.sql`
- [X] T126 [US10] Add `CatalogRoutingChangeLog` table file to `SmartFoundation.Database.sqlproj` Build ItemGroup

### Database Stored Procedures for US10

- [ ] T127 [US10] Implement service suggestion approval flow (creates real service from suggestion) in `[Tickets].[ServiceSP]` `APPROVE_SERVICE_SUGGESTION`
- [ ] T128 [US10] Implement service suggestion rejection flow in `[Tickets].[ServiceSP]` `REJECT_SERVICE_SUGGESTION`
- [ ] T129 [US10] Implement routing rule replacement with effective dating in `[Tickets].[ServiceSP]` `INSERT_ROUTING_RULE` / `CLOSE_ROUTING_RULE`
- [ ] T130 [US10] Implement approved routing correction logging to `CatalogRoutingChangeLog` in `[Tickets].[ServiceSP]`

### Tests for US10

- [ ] T131 [US10] Test approved suggestion creates real catalogue service in `SmartFoundation.Database/Tickets/Scripts/TestCatalogLearning.sql`
- [ ] T132 [US10] Test routing rule replacement preserves historical accountability in `SmartFoundation.Database/Tickets/Scripts/TestCatalogLearning.sql`
- [ ] T133 [US10] Test routing change history queryable via `CatalogRoutingChangeLog` in `SmartFoundation.Database/Tickets/Scripts/TestCatalogLearning.sql`

**Checkpoint**: Catalogue learning works — suggestions become services, routing corrections logged historically

---

## Phase 13: User Story 11 — Reporting and Dashboards (Priority: P11)

**Goal**: Provide read models for operational and leadership visibility.

**Independent Test**: Dashboard queries return correct scoped counts; overdue and breach reports match expected test data; leadership views can be filtered by organizational level.

### Database Views for US11

- [ ] T134 [P] [US11] Create `[Tickets].[V_TicketInboxByScope]` view in `SmartFoundation.Database/Tickets/Views/V_TicketInboxByScope.sql`
- [ ] T135 [P] [US11] Create `[Tickets].[V_TicketArbitrationInbox]` view in `SmartFoundation.Database/Tickets/Views/V_TicketArbitrationInbox.sql`
- [ ] T136 [P] [US11] Create `[Tickets].[V_TicketQualityInbox]` view in `SmartFoundation.Database/Tickets/Views/V_TicketQualityInbox.sql`

### Database Read Models for US11

- [ ] T137 [US11] Create `[Tickets].[DashboardDL]` procedure for status counts, SLA breaches, arbitration load, clarification load, service frequency, overdue lists in `SmartFoundation.Database/Tickets/Stored Procedures/DashboardDL.sql`

### Tests for US11

- [ ] T138 [US11] Test dashboard counts by status and organizational scope in `SmartFoundation.Database/Tickets/Scripts/TestDashboard.sql`
- [ ] T139 [US11] Test overdue and breach reports match test data in `SmartFoundation.Database/Tickets/Scripts/TestDashboard.sql`
- [ ] T140 [US11] Test service frequency reporting in `SmartFoundation.Database/Tickets/Scripts/TestDashboard.sql`
- [ ] T141 [US11] Test inbox visibility by scope in `SmartFoundation.Database/Tickets/Scripts/TestDashboard.sql`

**Checkpoint**: Reporting and dashboards operational — all read models return correct data

---

## Phase 14: Polish & Cross-Cutting Concerns

**Purpose**: Integration validation, final wiring, and cross-cutting quality checks.

- [X] T142 [P] Add all new views, stored procedures, and functions to `SmartFoundation.Database.sqlproj` Build ItemGroup
- [ ] T143 Run full solution build `dotnet build SmartFoundation.sln` and resolve any compilation errors
- [ ] T144 [P] Validate all gateway procedure routing: add `Tickets` page routing entries to `Masters_DataLoad.sql` and `Masters_CRUD.sql` if using gateway pattern
- [ ] T145 [P] Create comprehensive integration test covering Scenarios A–D from plan.md Section 12 in `SmartFoundation.Database/Tickets/Scripts/TestIntegration.sql`
- [ ] T146 [P] Validate `ProcedureMapper.cs` entries for any new entry procedures in `SmartFoundation.Application/Mapping/ProcedureMapper.cs`
- [ ] T147 Run `dotnet test SmartFoundation.Application.Tests/SmartFoundation.Application.Tests.csproj` to verify no regressions

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **US1 – Service Catalogue (Phase 3)**: Depends on Phase 2 only
- **US2 – Core Ticket (Phase 4)**: Depends on Phase 2 + Phase 3 (needs Service and lookups)
- **US3 – Assignment (Phase 5)**: Depends on Phase 4 (needs Ticket table and INSERT_TICKET)
- **US4 – Clarification (Phase 6)**: Depends on Phase 4 (needs Ticket); soft-depends on Phase 9 for pause sessions
- **US5 – Arbitration (Phase 7)**: Depends on Phase 4 (needs Ticket)
- **US6 – Parent-Child (Phase 8)**: Depends on Phase 4 (needs Ticket and INSERT_TICKET)
- **US7 – Pause Sessions (Phase 9)**: Depends on Phase 4 (needs Ticket); integrates with Phase 8 (child blocking)
- **US8 – SLA Engine (Phase 10)**: Depends on Phase 3 (needs ServiceSLAPolicy) + Phase 9 (needs TicketPauseSession for pause/resume)
- **US9 – Quality Review (Phase 11)**: Depends on Phase 4 (needs Ticket); completes two-stage closure
- **US10 – Catalogue Learning (Phase 12)**: Depends on Phase 3 (needs Service tables and ServiceSP)
- **US11 – Reporting (Phase 13)**: Depends on Phases 3–11 (needs all transactional tables and views)
- **Polish (Phase 14)**: Depends on all user stories being complete

### User Story Dependencies

```
Phase 1 (Setup)
  └── Phase 2 (Lookups)
        ├── Phase 3 (US1: Service Catalogue)
        │     ├── Phase 4 (US2: Core Ticket)
        │     │     ├── Phase 5 (US3: Assignment)
        │     │     ├── Phase 6 (US4: Clarification) ──┐
        │     │     ├── Phase 7 (US5: Arbitration)     │
        │     │     └── Phase 8 (US6: Parent-Child)    │
        │     │           └── Phase 9 (US7: Pause) ────┘
        │     │                 └── Phase 10 (US8: SLA)
        │     └── Phase 12 (US10: Catalogue Learning)
        └── (all paths converge)
              └── Phase 13 (US11: Reporting)
                    └── Phase 14 (Polish)
```

### Parallel Opportunities Within Phases

- **Phase 1**: All folder-creation tasks (T002–T005) can run in parallel
- **Phase 2**: All lookup table creation tasks (T006–T013) can run in parallel
- **Phase 3**: All table creation tasks (T017–T020) can run in parallel
- **Phase 7–9**: Clarification (Phase 6), Arbitration (Phase 7), and Parent-Child (Phase 8) can proceed in parallel after Phase 4 completes
- **Phase 10**: SLA table creation tasks (T098–T099) can run in parallel
- **Phase 13**: All view creation tasks (T134–T136) can run in parallel
- **Phase 14**: Integration test, ProcedureMapper, gateway routing can run in parallel

---

## Parallel Example: Phase 2 (Lookups)

```text
T006: Create TicketStatus lookup    in SmartFoundation.Database/Tickets/Tables/TicketStatus.sql
T007: Create TicketClass lookup     in SmartFoundation.Database/Tickets/Tables/TicketClass.sql
T008: Create Priority lookup        in SmartFoundation.Database/Tickets/Tables/Priority.sql
T009: Create RequesterType lookup   in SmartFoundation.Database/Tickets/Tables/RequesterType.sql
T010: Create PauseReason lookup     in SmartFoundation.Database/Tickets/Tables/PauseReason.sql
T011: Create ArbitrationReason lookup in SmartFoundation.Database/Tickets/Tables/ArbitrationReason.sql
T012: Create ClarificationReason lookup in SmartFoundation.Database/Tickets/Tables/ClarificationReason.sql
T013: Create QualityReviewResult lookup in SmartFoundation.Database/Tickets/Tables/QualityReviewResult.sql
```

## Parallel Example: Phases 6–8 (Clarification / Arbitration / Parent-Child)

```text
# After Phase 5 completes, these three specs can be developed in parallel:
Phase 6 (US4: Clarification) — T056–T065
Phase 7 (US5: Arbitration)   — T066–T078
Phase 8 (US6: Parent-Child)  — T079–T086
```

---

## Implementation Strategy

### MVP First (US1 + US2 + US3 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (lookups)
3. Complete Phase 3: US1 (Service Catalogue)
4. Complete Phase 4: US2 (Core Ticket Backbone)
5. Complete Phase 5: US3 (Assignment and Work Start)
6. **STOP and VALIDATE**: Test ticket creation, routing, assignment end-to-end
7. Deploy/demo if ready

### Incremental Delivery

1. Setup + Lookups → Foundation ready
2. Add US1 (Service Catalogue) → Test independently
3. Add US2 (Core Ticket) → Test independently
4. Add US3 (Assignment) → Test independently → **MVP Deploy**
5. Add US4 + US5 in parallel (Clarification + Arbitration) → Test
6. Add US6 + US7 in parallel (Parent-Child + Pause) → Test
7. Add US8 (SLA) → Test
8. Add US9 (Quality Review) → Test → **Full Lifecycle Deploy**
9. Add US10 (Catalogue Learning) → Test
10. Add US11 (Reporting) → Test → **Full Feature Deploy**
11. Polish & Integration → Final validation

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Database structure tasks are separated from stored procedure tasks per plan.md Section 11.3
- Stored procedure tasks are separated from view/DL tasks per plan.md Section 11.3
- UI tasks are NOT included in this task list per plan.md Section 4.1 scope ("Database design only") — UI tasks should be generated separately after database contracts are stable
- All write procedures must follow transaction control, THROW for business errors, JSON audit to `dbo.AuditLog`, and history insertion per plan.md Section 16.3
- Preserve existing Housing gateway pattern (Masters_DataLoad / Masters_CRUD routing) when wiring Tickets pages
- Commit after each task or logical group; validate each spec checkpoint before proceeding
