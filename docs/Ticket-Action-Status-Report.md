# Ticket Action & Status Report

## Execution Summary

- I executed Playwright E2E testing against multiple local app instances during debugging and validation, including
  the existing dev app on ports `5059` and `5088`, then isolated validation builds on ports `5090` and `5091`.
- I created and ran a dedicated ticket workflow suite in `tests/ticket-lifecycle.spec.ts` to exercise the Ticket
  system as a real user instead of relying on static inspection.
- I attempted a full lifecycle flow covering create ticket, update priority, route, assign, start work, pause, and
  resume.
- I attempted negative and edge-case coverage around rapid-click create, empty required create fields, invalid
  `START_WORK` transitions, and invalid `RESUME_TICKET` transitions.
- After confirming the current credential does not have `INSERT_TICKET`, I realigned the final validated scenarios to
  the workflows this user can actually execute.
- The final validated Playwright scenarios were:
  - hide create action when the user lacks `INSERT_TICKET`
  - update ticket priority and restore the seeded value on `TKT-2026-0008`
  - block invalid `PAUSE_TICKET` on `TKT-2026-0010` and show guard feedback without opening a modal
- Final focused Playwright validation result: `3 passed` on the patched isolated build.
- After live database tracing, I reproduced `UPDATE_PRIORITY` on `TKT-2026-0010` through `dbo.Masters_CRUD`, fixed the
  deployed SQL drift, and revalidated the same ticket with a change-and-restore cycle without creating a new
  `dbo.ErrorLog` entry.

- Bugs, failures, and race-condition-class issues uncovered during execution:
  - The create modal dropdowns loaded only `-1 / لاتوجد خيارات` because the dev database was missing effective
    ticket DDL routing and the app had no fallback for ticket create/action DDLs.
  - The create form kept resident field `p04` effectively required even when requester type was internal because the
    hidden-state, required-state, and wrapper visibility logic were out of sync.
  - The create form posted `NationalId` into `p03` instead of `usersId`, which broke the internal requester mapping
    expected by the ticket write path.
  - The TicketList UI exposed the create button from generic `INSERT` permission logic while the backend correctly
    enforced `INSERT_TICKET`, producing a permission-denied create attempt.
  - Invalid row-action guards initially appeared broken because the warning rendered through a custom table toast path
    rather than standard `.toast-error` or `.toast-warning` selectors.
  - A row-specific defect on `TKT-2026-0010` was traced to live SQL drift rather than UI instability. The generic
    toastr error `4326` mapped to `dbo.ErrorLog` and resolved to `String or binary data would be truncated.` because
    the deployed `UPDATE_PRIORITY` branch appended `entryData` and `hostName` back into `Tickets.Ticket`.
  - Environment instability was also uncovered during execution: Chromium rejected port `5061` as unsafe, a
    production-style run pointed at `DATACORE` and broke login, and stale `SmartFoundation.Mvc` processes locked build
    outputs.

## Fixes Implemented

- `SmartFoundation.Mvc/Controllers/Tickets/TicketController.TicketList.cs`:
  - Fixed the permission contract so `canCreateTicket` is granted only when `permissionTypeName_E == "INSERT_TICKET"`.
    This removed the false-positive create button for users who cannot actually create tickets.
  - Fixed requester-type switching in the create form so internal requester mode and resident requester mode now:
    - show and hide the correct wrappers with `style.display`
    - add and remove the `required` attribute on `p04` correctly
    - clear `p04` when it is hidden
    - leave `p04` non-required by default
  - Fixed the internal requester payload so `p03` carries `usersId` instead of `NationalId`.
  - Moved TicketList DDL consumption to the shared fallback-aware DDL loader for ticket status, service, pause reason,
    arbitration reason, quality result, priority, class, requester type, resident, building, reason, and template.

- `SmartFoundation.Mvc/Controllers/Tickets/TicketController.Base.cs`:
  - Added `GetTicketDdlOptionsAsync(...)` and the supporting fallback logic for ticket DDL sources.
  - Added fallback SQL/query resolution and direct data-loading helpers for missing ticket DDL routes.
  - Centralized connection-string usage so ticket fallback reads and resident lookups use the same access path.

- `SmartFoundation.Mvc/wwwroot/js/sf-table.js`:
  - Upgraded the custom table toast renderer to emit semantic, testable DOM hooks:
    - `.sf-toast`
    - `data-toast-type`
    - `data-testid="sf-toast"`
    - `role="alert"` or `role="status"`
    - `aria-live` and `aria-atomic`
  - Replaced raw toast message HTML interpolation with safe `textContent`-based rendering for the message body.

- `tests/ticket-lifecycle.spec.ts`:
  - Added a focused Playwright suite for TicketList workflow validation.
  - Reworked the suite to match the actual RBAC of the current user instead of assuming create permission.
  - Added stable selectors for the row-end action menu and the new semantic table toast hooks.
  - Stabilized the valid mutation scenario by using a seeded ticket row that reliably supports priority update and
    restoration.

- `SmartFoundation.Database/Tickets/Scripts/Deploy_UpdatePriority_Action.sql`:
  - Fixed the `UPDATE_PRIORITY` deployment branch so it no longer appends `entryData` or `hostName` into
    `Tickets.Ticket`.
  - Added a repair pass so already-deployed `Tickets.TicketSP` definitions with the old append logic are rewritten to
    the safe overwrite behavior on script execution.
  - Applied the corrected script to `appstest / DATACORETi` and verified `TicketSpHasUpdatePriority = 1`,
    `MastersCrudHasUpdatePriority = 1`, and `PermissionTypeExists = 1` after deployment.

- Live database validation (`appstest / DATACORETi`):
  - Confirmed `TKT-2026-0010` had saturated `Tickets.Ticket.entryData` (`nvarchar(20)`), which made the old append
    path fail deterministically.
  - Executed `dbo.Masters_CRUD` for `UPDATE_PRIORITY` on ticket `16` (`TKT-2026-0010`) to change priority and restore
    it in the same validation cycle.
  - Verified both calls returned success, the ticket restored to priority `1`, and `dbo.ErrorLog` remained unchanged.

## Pending Improvements & Gaps

- The system still leaks low-value error toasts when database faults occur. In this case the user-facing message only
  exposed code `4326`, and the real cause still required manual lookup in `dbo.ErrorLog`.
- Ticket RBAC is still architecturally fragile. The UI and backend were previously checking different permission names,
  which means the authorization contract is too implicit and too easy to break again.
- The Ticket module still relies heavily on controller-embedded JavaScript strings such as `OnChangeJs` and
  `OnBeforeOpenJs`. That makes behavior brittle, hard to lint, hard to unit test, and easy to regress.
- The generic `p01` to `p50` CRUD contract remains opaque and weakly typed. It slows debugging and makes feature work
  more error-prone than it should be.
- The feedback architecture is still inconsistent. Guard failures can come from the custom `sf-table` toast path while
  successful mutations may still come from Toastr. The product currently has two user-feedback systems instead of one.
- The controller-side DDL fallback fixes the dev experience, but it also hides a deeper environment/data-contract
  problem: the ticket DDL gateway routing is still not reliable in the current dev database.
- Full end-to-end lifecycle coverage is still incomplete for this credential because the user account does not own the
  entire ticket workflow. Create, route, assign, start, pause, resume, arbitration, quality review, and child-ticket
  flows still need role-appropriate validation.
- The row-action menu structure is automation-hostile and likely accessibility-hostile as well. Repeated hidden menu
  text and mixed rendering paths make both testing and assistive tooling harder than necessary.
- Local execution is still operationally fragile due to stale process locking and configuration drift between
  Development and production-style runs.

## Next Actionable Steps

1. **Task 1:** Unify ticket authorization rules so the UI and backend both read the same action-permission contract for
   every ticket command, not just create.
2. **Task 2:** Consolidate user feedback into one semantic toast system so success, warning, and error states all use a
   single predictable surface.
3. **Task 3:** Replace controller-side ticket DDL fallbacks with a proper fix in the database or application gateway so
   the dev environment and runtime contract match again.
4. **Task 4:** Audit other ticket write actions and deploy scripts for similar live-database drift so source snapshots,
  deploy scripts, and runtime procedures cannot diverge silently again.
5. **Task 5:** Expand Playwright coverage with role-appropriate accounts to complete create, route, assign, start,
   pause, resume, arbitration, quality review, and child-ticket validation.

Please confirm if you want me to immediately start executing **Task 1**.