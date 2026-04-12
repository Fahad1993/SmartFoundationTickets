<!--
  Sync Impact Report
  ==================
  Version change: NONE → 1.0.0 (initial ratification)
  Modified principles: N/A (first edition)
  Added sections:
    - Preamble
    - Principle 1: Housing-First Implementation
    - Principle 2: Layer Boundary Discipline
    - Principle 3: Contract Preservation
    - Principle 4: Gateway Procedure Architecture
    - Principle 5: Server-Side UI Composition
    - Principle 6: Permission-Gated Actions
    - Principle 7: Trust Active Code Over Documentation
    - Principle 8: Prescriptive Build And Test Verification
    - Governance
    - Appendix A: Canonical Reference Chain
    - Appendix B: Anti-Pattern Registry
  Removed sections: N/A
  Templates requiring updates:
    - .specify/templates/plan-template.md     ✅ created
    - .specify/templates/spec-template.md     ✅ created
    - .specify/templates/tasks-template.md    ✅ created
    - .specify/templates/commands/plan.md     ✅ created
    - .specify/templates/commands/specify.md  ✅ created
    - .specify/templates/constitution.md      ✅ created
  Follow-up TODOs: None
-->

# SmartFoundation Project Constitution

## Preamble

This constitution codifies the non-negotiable engineering principles that
govern all work on the SmartFoundation ASP.NET Core 8 MVC solution. Every
agent, developer, and reviewer MUST verify changes against these principles
before merging. When AGENTS.md, copilot-instructions.md, or any other
guidance file conflicts with this constitution, this document takes
precedence unless the conflict is escalated and resolved through the
governance amendment process.

## Core Principles

### I. Housing-First Implementation

When adding or modifying a feature that resembles a Housing-style page,
agents MUST follow the `WaitingListByResident` implementation pattern
before inventing new approaches.

**Rules:**

- Copy the Housing controller structure: session context via
  `HousingController.Base`, positional SP argument arrays,
  `MastersServies.GetDataLoadDataSetAsync(...)`, and
  `SplitDataSet(...)`.
- Preserve the table-0-is-permissions, later-tables-are-data convention.
- Build `FormConfig`, `SmartTableDsModel`, toolbar actions, and
  `SmartPageViewModel` server-side.
- Keep views thin; render through `SmartRenderer`.

**Rationale:** The Housing module is the most battle-tested pattern in the
codebase. Older experiments exist but do not represent current team
standards. Diverging without explicit architectural approval introduces
inconsistency and regression risk.

**Canonical reference:**
`SmartFoundation.Mvc/Controllers/Housing/WaitingList/HousingController.WaitingListByResident.cs`

### II. Layer Boundary Discipline

Code MUST respect the dependency direction
`Presentation → Application → DataEngine → Database`.
No layer MAY bypass the layer below it.

**Rules:**

- Controllers in `SmartFoundation.Mvc` MUST call Application-layer
  services only. Direct `ISmartComponentService` or
  `SmartComponentService` calls from controllers are prohibited.
- Application-layer services (`SmartFoundation.Application`) MUST use
  `ProcedureMapper` for entry-procedure resolution and MUST NOT
  hard-code stored procedure names.
- The DataEngine layer (`SmartFoundation.DataEngine`) MUST contain zero
  business logic; it is a Dapper execution surface only.
- `SmartFoundation.UI` ViewComponents MUST accept configuration objects
  and MUST NOT contain business logic.
- Controllers MUST validate input; services MUST trust caller-validated
  input and focus on orchestration.

**Rationale:** Layer violations couple unrelated concerns, making changes
ripple unpredictably and preventing independent testing. The Housing flow
demonstrates this separation cleanly.

**Exceptions:** `MastersServies` is an existing gateway service used by
active Housing flows. It MUST NOT be auto-refactored away unless the task
explicitly requires it. New narrow JSON-style services SHOULD inherit
from `BaseService` and follow the `ProcedureMapper` pattern.

### III. Contract Preservation

Database-facing parameter names, CRUD field mappings, and gateway
routing keys are frozen contracts. Agents MUST NOT rename, reformat, or
alias them without an explicit task to change the entire contract.

**Frozen identifiers:**

- `pageName_`, `ActionType`, `idaraID`, `entrydata`, `hostname`
- `parameter_01` through `parameter_50`
- Form-field aliases `p01` through `p50`
- Hidden fields: `redirectAction`, `redirectController`
- CRUD endpoints: `/crud/insert`, `/crud/update`, `/crud/delete`
- Result columns: `IsSuccessful`, `Message_`, `permissionTypeName_E`
- Error-number ranges: `50001`–`50999` for business errors,
  `50002` for unexpected/programmatic failures

**Rules:**

- Preserve exact casing and spelling in application code.
- Do NOT add `@` prefixes to parameter names in C#; the DataEngine adds
  them internally.
- Do NOT replace identifiers with cleaner aliases unless the task
  explicitly changes the whole DB contract.

**Rationale:** Hundreds of stored procedures, gateway routes, and form
posts depend on these exact names. A single rename breaks the read path,
write path, or both with no compiler warning.

### IV. Gateway Procedure Architecture

`ProcedureMapper` MUST map entry/gateway procedures only. Downstream
feature procedures MUST NOT be individually mapped when a gateway
procedure already routes to them.

**Rules:**

- Map `dbo.Masters_DataLoad` and `dbo.Masters_CRUD` (or equivalent
  gateway procedures) in `ProcedureMapper`.
- Do NOT add every downstream `[Housing].[SomethingDL]` or
  `[Housing].[SomethingSP]` to `ProcedureMapper`.
- Gateway procedures route by `@pageName_` (and `@ActionType` for
  writes). Downstream procedures hold business validations and logic.
- Preserve this two-tier separation; do NOT flatten it.

**Rationale:** Centralizing routing in gateway procedures is an
intentional architectural decision that keeps the application layer thin
and makes adding new pages a database-side concern rather than a code
deployment.

### V. Server-Side UI Composition

All UI state — form fields, table columns, toolbar actions, permission
gating — MUST be assembled in the controller and expressed through
configuration objects passed to `SmartRenderer`.

**Rules:**

- Build `FormConfig`, `FieldConfig`, `SmartTableDsModel`, and
  `SmartPageViewModel` in the controller action.
- Views MUST be thin: invoke `SmartRenderer` and nothing else
  substantial.
- Permission-derived UI toggles (show/hide insert, update, delete
  buttons) MUST be resolved server-side from the first result table.

**Rationale:** Thick views hide logic in Razor templates that are
difficult to test and audit. Server-side composition keeps rendering
deterministic and auditable.

### VI. Permission-Gated Actions

Every Housing-style page MUST derive user permissions from the first
returned DataTable (typically via `permissionTypeName_E`) and MUST use
those permissions to gate insert, update, delete, and other
state-changing actions both in the UI and in downstream write procedures.

**Rules:**

- Read `permissionTypeName_E` from DataSet table 0.
- Map each permission to a boolean flag controlling UI elements and
  controller-level action availability.
- Gateway write procedures (`Masters_CRUD`) MUST check permissions
  before calling downstream write procedures.
- Do NOT remove or weaken server-side permission checks in favor of
  client-only gating.

**Rationale:** Permissions are a security boundary. Removing
server-side checks creates privilege-escalation vectors that cannot be
caught in code review alone.

### VII. Trust Active Code Over Documentation

When documentation (including this constitution, AGENTS.md, README.md,
copilot-instructions.md, or any file in `docs/`) conflicts with the
behavior of active, running code, the active code is the source of
truth.

**Rules:**

- `SmartFoundation.Mvc/Program.cs` is the real entrypoint. Root
  `Program.cs` is stale and MUST NOT be treated as runtime code.
- `SmartFoundation.Database` is a snapshot/reference only. It is NOT
  guaranteed current and MUST NOT be used as authoritative proof of
  live database behavior.
- When database behavior is unclear, verify against:
  `ProcedureMapper.cs`, `MastersServies.cs`,
  `SmartComponentService.cs`, and active MVC callers.
- Migration-era documentation in `docs/` MUST be treated as historical
  context, not as active specification.

**Rationale:** Documentation drifts. Code runs. Trusting stale docs
over running code produces changes that compile but break production.

### VIII. Prescriptive Build And Test Verification

Every change MUST pass build and test gates before being considered
complete.

**Mandatory checks:**

- `dotnet build SmartFoundation.Mvc/SmartFoundation.Mvc.csproj` MUST
  succeed with zero errors.
- `dotnet build SmartFoundation.Application/SmartFoundation.Application.csproj`
  MUST succeed with zero errors.
- `dotnet test SmartFoundation.Application.Tests/SmartFoundation.Application.Tests.csproj`
  MUST pass all existing tests.
- If a task modifies CSS or Tailwind sources,
  `npm --prefix SmartFoundation.Mvc run tw:build` MUST succeed.

**Rules:**

- Do NOT skip build or test steps due to time pressure or "small"
  changes.
- If a test is genuinely broken by an intentional contract change,
  update the test and document the reason in the commit message.
- Full solution build (`SmartFoundation.sln`) includes
  `SmartFoundation.Database.sqlproj` which may require SQL project
  tooling; focused builds of Mvc and Application projects are
  sufficient for most application-layer work.

**Rationale:** Broken builds and failing tests are the fastest path to
regression. Verifying at the narrowest relevant project scope catches
issues before merge.

## Anti-Pattern Registry

The following patterns are prohibited unless the task explicitly requires
them:

| Anti-Pattern | Why |
|---|---|
| Using root `Program.cs` as runtime source | Stale; real entry is `SmartFoundation.Mvc/Program.cs` |
| Auto-refactoring Housing pages away from `MastersServies` + `DataSet` | Active team pattern; not a legacy smell |
| Renaming `pageName_`, `ActionType`, `idaraID`, `entrydata`, `hostname`, `p01`..`p50`, `parameter_01`..`parameter_50` | Frozen DB contract |
| Mapping every downstream business SP into `ProcedureMapper` | Gateway procedures already route |
| Treating `SmartFoundation.Database` as authoritative | Snapshot/reference only |
| Removing `CrudController` plumbing | Many pages depend on the generic CRUD contract |
| Pushing business logic into Razor views | Server-side composition via `SmartRenderer` is mandatory |
| Skipping build/test verification before merge | Principle VIII is non-negotiable |
| Adding `@` to parameter names in C# code | DataEngine adds `@` internally |

## Canonical Reference Chain

When uncertain about implementation style, follow this chain in order:

1. `SmartFoundation.Mvc/Controllers/Housing/WaitingList/HousingController.WaitingListByResident.cs`
2. `SmartFoundation.Mvc/Controllers/Housing/HousingController.Base.cs`
3. `SmartFoundation.Mvc/Controllers/CrudController.cs`
4. `SmartFoundation.Application/Services/MastersServies.cs`
5. Gateway and downstream procedures for the relevant page

## Governance

### Amendment Procedure

1. Propose a change as a pull request against this file.
2. Include rationale and impact analysis in the PR description.
3. Require at least one reviewer other than the proposer.
4. Merge only after all open questions are resolved.

### Versioning Policy

- **MAJOR:** Principle removal, redefinition, or backward-incompatible
  governance change.
- **MINOR:** New principle added or existing principle materially
  expanded.
- **PATCH:** Clarifications, wording fixes, non-semantic refinements.

### Compliance Review

- Code reviews MUST cite any constitution principle violation as a
  blocking comment.
- Automated lint/typecheck/build gates are mandatory; they enforce
  Principle VIII mechanically.
- Quarterly, the team SHOULD audit whether any principle has drifted
  from actual practice and propose amendments if needed.

### Conflict Resolution

- If this constitution conflicts with AGENTS.md or
  copilot-instructions.md, this constitution prevails.
- If active running code conflicts with this constitution, the code
  prevails (Principle VII), but a follow-up amendment SHOULD be proposed
  to align the constitution with reality.

**Version**: 1.0.0 | **Ratified**: 2026-04-12 | **Last Amended**: 2026-04-12
