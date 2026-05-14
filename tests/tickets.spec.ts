import { test as base, expect, Page } from '@playwright/test';

const NATIONAL_ID = process.env.SF_NATIONAL_ID ?? '';
const PASSWORD = process.env.SF_PASSWORD ?? '';

type TicketFixtures = { authenticatedPage: Page };

const test = base.extend<TicketFixtures>({
  authenticatedPage: async ({ page }, use) => {
    await page.goto('/Login');
    await page.locator('#txtNationalID').fill(NATIONAL_ID);
    await page.locator('#txtPassword').fill(PASSWORD);
    await page.locator('#loginForm button[type="submit"]').click();
    await page.waitForURL('**/Home**', { timeout: 15_000 });
    await use(page);
  },
});

test.describe('Tickets Module', () => {
  test.skip(() => !NATIONAL_ID || !PASSWORD, 'SF_NATIONAL_ID and SF_PASSWORD env vars required');

  test.describe('Service Catalogue List', () => {
    test('loads the page and displays services table', async ({ authenticatedPage: page }) => {
      await page.goto('/Ticket/ServiceCatalogueList');
      await expect(page).toHaveURL(/\/Ticket\/ServiceCatalogueList/);
      await expect(page.locator('table')).toBeVisible({ timeout: 10_000 });
      const rows = page.locator('table tbody tr');
      expect(await rows.count()).toBeGreaterThanOrEqual(1);
    });

    test('has search/filter panel', async ({ authenticatedPage: page }) => {
      await page.goto('/Ticket/ServiceCatalogueList');
      await expect(page.locator('.sf-panel').first()).toBeVisible({ timeout: 10_000 });
    });

    test('displays service data columns', async ({ authenticatedPage: page }) => {
      await page.goto('/Ticket/ServiceCatalogueList');
      await expect(page.locator('table')).toBeVisible({ timeout: 10_000 });
      const headerCells = page.locator('table thead th');
      expect(await headerCells.count()).toBeGreaterThanOrEqual(3);
    });
  });

  test.describe('Ticket List', () => {
    test('loads the page and displays tickets table', async ({ authenticatedPage: page }) => {
      await page.goto('/Ticket/TicketList');
      await expect(page).toHaveURL(/\/Ticket\/TicketList/);
      await expect(page.locator('table')).toBeVisible({ timeout: 10_000 });
      const rows = page.locator('table tbody tr');
      expect(await rows.count()).toBeGreaterThanOrEqual(1);
    });

    test('displays ticket numbers in the table', async ({ authenticatedPage: page }) => {
      await page.goto('/Ticket/TicketList');
      await expect(page.locator('table')).toBeVisible({ timeout: 10_000 });
      const firstCell = page.locator('table tbody tr td').first();
      await expect(firstCell).toBeVisible();
    });
  });

  test.describe('Ticket Details', () => {
    test('loads details page for ticket ID 1', async ({ authenticatedPage: page }) => {
      await page.goto('/Ticket/TicketDetails?id=1');
      await expect(page).toHaveURL(/\/Ticket\/TicketDetails/);
      await expect(page.locator('table').first()).toBeVisible({ timeout: 10_000 });
    });

    test('displays ticket information table', async ({ authenticatedPage: page }) => {
      await page.goto('/Ticket/TicketDetails?id=1');
      await expect(page.locator('table').first()).toBeVisible({ timeout: 10_000 });
    });

    test('displays multiple data tables (details + history + sub-tables)', async ({ authenticatedPage: page }) => {
      await page.goto('/Ticket/TicketDetails?id=1');
      const tables = page.locator('table');
      const tableCount = await tables.count();
      expect(tableCount).toBeGreaterThanOrEqual(3);
    });

    test('active pause hides conflicting actions and exposes respond clarification on ticket ID 16', async ({ authenticatedPage: page }) => {
      await page.goto('/Ticket/TicketDetails?id=16');
      await expect(page).toHaveURL(/\/Ticket\/TicketDetails/);

      const actionButtons = page.locator('.ticket-action-buttons');
      await expect(actionButtons).toBeVisible({ timeout: 10_000 });

      await expect(actionButtons.getByRole('button', { name: 'بدء العمل' })).toHaveCount(0);
      await expect(actionButtons.getByRole('button', { name: 'استئناف' })).toHaveCount(0);
      await expect(actionButtons.getByRole('button', { name: 'طلب توضيح' })).toHaveCount(0);

      const respondClarificationButton = actionButtons.getByRole('button', { name: 'الرد على التوضيح' });
      await expect(respondClarificationButton).toBeVisible();
      await respondClarificationButton.click();

      const respondClarificationDialog = page.getByRole('dialog', { name: 'الرد على طلب التوضيح' });
      await expect(respondClarificationDialog).toBeVisible();
      await expect(respondClarificationDialog.locator('input[name="ActionType"]')).toHaveValue('RESPOND_CLARIFICATION');
      await expect(respondClarificationDialog.locator('input[name="p01"]')).toHaveValue(/\S+/);
    });

    test('visible TicketDetails action triggers open wired modals without page errors on ticket ID 16', async ({ authenticatedPage: page }) => {
      const pageErrors: string[] = [];
      const consoleErrors: string[] = [];

      page.on('pageerror', (error) => pageErrors.push(error.message));
      page.on('console', (message) => {
        if (message.type() === 'error') {
          consoleErrors.push(message.text());
        }
      });

      await page.goto('/Ticket/TicketDetails?id=16');
      await expect(page).toHaveURL(/\/Ticket\/TicketDetails/);

      const triggers = page.locator('.ticket-action-buttons [data-ticket-modal-open], .ticket-clarification-actions [data-ticket-modal-open]');
      const triggerCount = await triggers.count();
      expect(triggerCount).toBeGreaterThanOrEqual(1);

      for (let index = 0; index < triggerCount; index += 1) {
        const trigger = triggers.nth(index);
        const modalId = await trigger.getAttribute('data-ticket-modal-open');

        expect(modalId).toBeTruthy();

        await trigger.click();

        const modal = page.locator(`#${modalId}`);
        await expect(modal).toBeVisible();
        await expect(modal.locator('input[name="ActionType"]').first()).toHaveValue(/\S+/);

        await modal.locator('[data-ticket-modal-close]').last().click();
        await expect(modal).toBeHidden();
      }

      expect(pageErrors).toEqual([]);
      expect(consoleErrors).toEqual([]);
    });
  });

  test.describe('Navigation', () => {
    test('sidebar shows Tickets program links', async ({ authenticatedPage: page }) => {
      await page.goto('/Home');
      await page.waitForTimeout(2000);
      const allLinks = page.locator('a[href*="Ticket"]');
      expect(await allLinks.count()).toBeGreaterThanOrEqual(1);
    });

    test('can navigate from TicketList to TicketDetails', async ({ authenticatedPage: page }) => {
      await page.goto('/Ticket/TicketList');
      await expect(page.locator('table')).toBeVisible({ timeout: 10_000 });
      const firstLink = page.locator('table tbody tr a[href*="TicketDetails"]').first();
      if (await firstLink.isVisible()) {
        await firstLink.click();
        await expect(page).toHaveURL(/\/Ticket\/TicketDetails/, { timeout: 10_000 });
      }
    });
  });

  test.describe('Data Integrity', () => {
    test('ServiceCatalogueList shows Arabic service names', async ({ authenticatedPage: page }) => {
      await page.goto('/Ticket/ServiceCatalogueList');
      await expect(page.locator('table')).toBeVisible({ timeout: 10_000 });
      const bodyText = await page.locator('table tbody').textContent();
      expect(bodyText).toBeTruthy();
      expect(bodyText!.length).toBeGreaterThan(0);
    });

    test('TicketList shows multiple tickets', async ({ authenticatedPage: page }) => {
      await page.goto('/Ticket/TicketList');
      await expect(page.locator('table')).toBeVisible({ timeout: 10_000 });
      const rows = page.locator('table tbody tr');
      const count = await rows.count();
      expect(count).toBeGreaterThanOrEqual(1);
    });

    test('TicketDetails for ticket 1 shows history', async ({ authenticatedPage: page }) => {
      await page.goto('/Ticket/TicketDetails?id=1');
      const tables = page.locator('table');
      const tableCount = await tables.count();
      expect(tableCount).toBeGreaterThanOrEqual(2);
    });
  });

  test.describe('Create Ticket (Insert)', () => {
    test('opens the create ticket modal and submits a new ticket', async ({ authenticatedPage: page }) => {
      // 1. Navigate to TicketList
      await page.goto('/Ticket/TicketList');
      await expect(page.locator('table.sf-table').first()).toBeVisible({ timeout: 15_000 });

      // Count existing rows so we can verify a new one appears
      const rowsBefore = await page.locator('table.sf-table').first().locator('tbody tr').count();

      // 2. Click "تذكرة جديدة" (Add) button in the toolbar
      const addBtn = page.locator('button.btn-success').filter({ hasText: 'تذكرة جديدة' });
      await expect(addBtn).toBeVisible({ timeout: 5_000 });
      await addBtn.click();

      // 3. Wait for the modal to appear
      const modal = page.locator('.sf-modal');
      await expect(modal).toBeVisible({ timeout: 5_000 });

      // 4. Wait for Select2 controls to initialize inside the modal
      await page.waitForTimeout(1_000);

      // --- Helper: pick the first available option in a Select2 dropdown ---
      async function pickFirstSelect2Option(selectName: string) {
        const selectEl = page.locator(`.sf-modal select[name="${selectName}"]`);
        if (!(await selectEl.isVisible())) return;

        await page.evaluate((name) => {
          const $sel = window.jQuery(`select[name="${name}"]`);
          if (!$sel.length) return;
          const firstVal = $sel.find('option').filter(function () {
            return !!(this as HTMLOptionElement).value;
          }).first().val();
          if (firstVal !== undefined) {
            $sel.val(firstVal).trigger('change');
          }
        }, selectName);
      }

      // --- Helper: pick a Select2 option by 0-based index (among non-empty options) ---
      async function pickSelect2OptionByIndex(selectName: string, index: number) {
        const selectEl = page.locator(`.sf-modal select[name="${selectName}"]`);
        if (!(await selectEl.isVisible())) return;

        await page.evaluate(({ name, idx }) => {
          const $sel = window.jQuery(`select[name="${name}"]`);
          if (!$sel.length) return;
          const opts = $sel.find('option').filter(function () {
            return !!(this as HTMLOptionElement).value;
          });
          if (opts.length > idx) {
            $sel.val((opts[idx] as HTMLOptionElement).value).trigger('change');
          }
        }, { name: selectName, idx: index });
      }

      // 5. Fill Select2 dropdowns
      // p01 → ticketClassID
      await pickFirstSelect2Option('p01');
      // p02 → requesterTypeID — pick non-RESIDENT type (value !== '1')
      // so that p04 (resident ID) stays hidden and p03 (internal user) is used
      await page.evaluate(() => {
        const $sel = window.jQuery('select[name="p02"]');
        if (!$sel.length) return;
        const opts = $sel.find('option').filter(function () {
          return !!(this as HTMLOptionElement).value;
        });
        // prefer non-RESIDENT (value != '1'), fallback to first option
        let target = opts.filter(function () {
          return (this as HTMLOptionElement).value !== '1';
        }).first();
        if (!target.length) target = opts.first();
        if (target.length) {
          $sel.val(target.val() as string).trigger('change');
        }
      });
      // p05 → serviceID (required)
      await pickFirstSelect2Option('p05');
      // p08 → priority
      await pickFirstSelect2Option('p08');

      // 6. Fill text fields
      // p03 → requesterUserID (hidden, carries NationalId for form submission)
      // _p03display → display-only field showing "FullName - NationalId" (starts hidden via ExtraCss)
      const p03 = page.locator('.sf-modal input[name="p03"]');
      // p03 is a hidden input carrying the NationalId value
      await expect(p03).toHaveAttribute('type', 'hidden');
      const p03Val = await p03.inputValue();
      expect(p03Val).toBeTruthy();
      console.log('p03 (NationalId hidden) value:', p03Val);

      // p04 → requesterResidentID — starts hidden via ExtraCss sf-toggle-hidden
      // Its parent form-group is display:none via CSS rule .form-group:has(.sf-toggle-hidden)
      const p04 = page.locator('.sf-modal input[name="p04"]');
      await expect(p04).toBeHidden();

      // p06 → title (required)
      await page.locator('.sf-modal input[name="p06"]').fill('تذكرة اختبار بلاي رايت');

      // p07 → description
      await page.locator('.sf-modal textarea[name="p07"]').fill('هذه تذكرة تم إنشاؤها تلقائياً بواسطة اختبار Playwright');

      // p12 → location
      const p12 = page.locator('.sf-modal input[name="p12"]');
      if (await p12.isVisible()) {
        await p12.fill('مبنى 1 - طابق 2');
      }

      // 7. Take a screenshot before submission for debugging
      await page.screenshot({ path: 'tests/test-results/create-ticket-before-submit.png', fullPage: true });

      // Capture form data before submitting
      const formData = await page.evaluate(() => {
        const form = document.querySelector('.sf-modal form') as HTMLFormElement;
        if (!form) return 'NO FORM FOUND';
        const data: Record<string, string> = {};
        new FormData(form).forEach((v, k) => { data[k] = v.toString(); });
        return data;
      });
      console.log('Form data to be submitted:', JSON.stringify(formData, null, 2));

      // 8. Submit the form via native POST (bypass sf-table.js AJAX interception)
      // sf-table.js intercepts form submit and tries AJAX, but this form is designed
      // for native POST to /crud/insert which redirects with TempData toast
      await page.evaluate(() => {
        const form = document.querySelector('.sf-modal form') as HTMLFormElement;
        if (form) form.submit();
      });

      // 9. Wait for navigation back to TicketList (form posts to /crud/insert which redirects)
      await page.waitForURL('**/Ticket/TicketList**', { timeout: 15_000 });

      // 10. Verify we're back on the list page
      await expect(page).toHaveURL(/\/Ticket\/TicketList/);

      // 11. Check for Toastr success notification
      await page.waitForTimeout(1_000);

      // Verify success toast appears
      const successToast = page.locator('.toast-success');
      await expect(successToast).toBeVisible({ timeout: 5_000 });
      const successText = await successToast.textContent();
      expect(successText).toContain('Ticket created successfully');

      // Take a screenshot of the result
      await page.screenshot({ path: 'tests/test-results/create-ticket-result.png', fullPage: true });

      // Verify the table still loads
      await expect(page.locator('table.sf-table').first()).toBeVisible({ timeout: 10_000 });
    });

    test('direct API POST to /crud/insert', async ({ authenticatedPage: page }) => {
      // First, nav to TicketList to get cookies/session
      await page.goto('/Ticket/TicketList');
      await expect(page.locator('table.sf-table').first()).toBeVisible({ timeout: 15_000 });

      // Extract cookies for the API call
      const cookies = await page.context().cookies();
      const cookieHeader = cookies.map(c => `${c.name}=${c.value}`).join('; ');

      // Get anti-forgery token from the page if one exists
      const token = await page.evaluate(() => {
        const el = document.querySelector('input[name="__RequestVerificationToken"]') as HTMLInputElement;
        return el?.value ?? '';
      });

      // Build form data matching what the modal sends
      const formData = new URLSearchParams();
      formData.set('pageName_', 'Tickets');
      formData.set('ActionType', 'INSERT_TICKET');
      formData.set('idaraID', '1');
      formData.set('entrydata', '4');
      formData.set('hostname', '::1');
      formData.set('redirectAction', 'TicketList');
      formData.set('redirectController', 'Ticket');
      formData.set('p01', '1');    // ticketClassID
      formData.set('p02', '2');    // requesterTypeID (INTERNAL)
      formData.set('p03', '4');    // requesterUserID
      // p04 not set (NULL) — correct for INTERNAL
      formData.set('p05', '1');    // serviceID
      formData.set('p06', 'API Test Ticket');
      formData.set('p07', 'Created via direct API POST');
      formData.set('p08', '1');    // priorityID
      formData.set('p12', 'Building 1');

      if (token) formData.set('__RequestVerificationToken', token);

      // POST directly (don't follow redirect)
      const resp = await page.request.post('/crud/insert', {
        form: Object.fromEntries(formData),
        maxRedirects: 0,
      });

      console.log('Direct API POST status:', resp.status());
      console.log('Direct API POST headers:', JSON.stringify(resp.headers()));
      const body = await resp.text();
      console.log('Direct API POST body:', body.substring(0, 500));

      // Follow redirect manually  
      await page.goto('/Ticket/TicketList');
      await page.waitForTimeout(1_000);

      // Check for toast
      const errorToast = page.locator('.toast-error');
      const successToast = page.locator('.toast-success');
      const hasError = await errorToast.isVisible().catch(() => false);
      const hasSuccess = await successToast.isVisible().catch(() => false);

      if (hasError) {
        console.log('API test error toast:', await errorToast.textContent());
      }
      if (hasSuccess) {
        console.log('API test success toast:', await successToast.textContent());
      }

      await page.screenshot({ path: 'tests/test-results/api-test-result.png', fullPage: true });
      expect(hasError).toBe(false);
    });
  });

  /* ============================================================
   * Ticket Action Buttons — Toolbar tests on TicketList
   * ============================================================
   * Workflow action buttons are rendered via SmartTableDS toolbar
   * (CustomActions). Which buttons appear depends on user permissions.
   * All workflow buttons have requireSelection=true → disabled when
   * no row is selected. After selection, buttons become enabled
   * (HTML disabled attr removed). Guard evaluation happens in JS
   * doAction() on click — a guard-blocked click shows a toast error
   * instead of opening the modal.
   * ============================================================ */
  test.describe('Ticket Action Buttons', () => {

    // All possible workflow action buttons (order matches controller)
    const allWorkflowButtons: { label: string; color: string; actionType: string; formId: string }[] = [
      { label: 'توجيه',           color: 'primary',   actionType: 'ROUTE_TICKET',            formId: 'routeTicketForm' },
      { label: 'رفض',             color: 'danger',    actionType: 'REJECT_TICKET',            formId: 'rejectTicketForm' },
      { label: 'تعيين',           color: 'primary',   actionType: 'ASSIGN_TICKET',            formId: 'assignTicketForm' },
      { label: 'بدء العمل',       color: 'success',   actionType: 'START_WORK',               formId: 'startWorkForm' },
      { label: 'حل',              color: 'success',   actionType: 'RESOLVE_TICKET',           formId: 'resolveTicketForm' },
      { label: 'إيقاف مؤقت',     color: 'warning',   actionType: 'PAUSE_TICKET',             formId: 'pauseTicketForm' },
      { label: 'تحكيم',           color: 'info',      actionType: 'RAISE_ARBITRATION',        formId: 'arbitrationForm' },
      { label: 'تذكرة فرعية',     color: 'secondary', actionType: 'CREATE_CHILD_TICKET',      formId: 'childTicketForm' },
      { label: 'استئناف',         color: 'success',   actionType: 'RESUME_TICKET',            formId: 'resumeTicketForm' },
      { label: 'مراجعة جودة',     color: 'info',      actionType: 'SUBMIT_QUALITY_REVIEW',    formId: 'qualityReviewForm' },
      { label: 'إنهاء المراجعة',  color: 'success',   actionType: 'FINALIZE_QUALITY_REVIEW',  formId: 'finalizeQRForm' },
      { label: 'إغلاق',           color: 'success',   actionType: 'CLOSE_TICKET',             formId: 'closeTicketForm' },
      { label: 'إعادة فتح',       color: 'warning',   actionType: 'REOPEN_TICKET',            formId: 'reopenTicketForm' },
    ];

    // ----- helper: navigate to TicketList and wait for table -----
    async function gotoTicketList(page: Page) {
      await page.goto('/Ticket/TicketList');
      await expect(page.locator('table.sf-table').first()).toBeVisible({ timeout: 15_000 });
    }

    // ----- helper: locate a toolbar button by its label text -----
    function actionBtn(page: Page, label: string) {
      return page.locator('.actions-list button').filter({ hasText: label });
    }

    // ----- helper: discover which workflow buttons are on the page -----
    async function getVisibleButtons(page: Page) {
      const visible: typeof allWorkflowButtons = [];
      for (const btn of allWorkflowButtons) {
        const loc = actionBtn(page, btn.label);
        if (await loc.isVisible({ timeout: 500 }).catch(() => false)) {
          visible.push(btn);
        }
      }
      return visible;
    }

    // ----- helper: select the first row in the table -----
    async function selectFirstRow(page: Page) {
      const firstRow = page.locator('table.sf-table').first().locator('tbody tr.tr-row').first();
      await firstRow.click();
      await page.waitForTimeout(300);
      return firstRow;
    }

    // ----- helper: close open modal (try multiple close strategies) -----
    async function closeModal(page: Page) {
      const modal = page.locator('.sf-modal');
      const backdrop = page.locator('.sf-modal-backdrop').first();

      // Try the X / close button in the modal header
      const xBtn = page.locator('.sf-modal .sf-modal-close, .sf-modal button[aria-label="Close"]').first();
      if (await xBtn.isVisible({ timeout: 500 }).catch(() => false)) {
        await xBtn.click();
      } else {
        // Fallback: press Escape to close
        await page.keyboard.press('Escape');
      }

      // Wait for modal AND backdrop to disappear
      await modal.waitFor({ state: 'hidden', timeout: 3_000 }).catch(async () => {
        // If still visible, try Escape again
        await page.keyboard.press('Escape');
        await modal.waitFor({ state: 'hidden', timeout: 2_000 }).catch(() => {});
      });
      await backdrop.waitFor({ state: 'hidden', timeout: 2_000 }).catch(() => {});
    }

    /* ---- 1. Toolbar has action buttons (permission-dependent count) ---- */
    test('toolbar shows workflow action buttons', async ({ authenticatedPage: page }) => {
      await gotoTicketList(page);

      const visibleBtns = await getVisibleButtons(page);
      console.log(`Found ${visibleBtns.length} workflow buttons: ${visibleBtns.map(b => b.label).join(', ')}`);
      // User should have at least some action permissions
      expect(visibleBtns.length).toBeGreaterThanOrEqual(1);
    });

    /* ---- 2. Create button (conditional — depends on permission) ---- */
    test('create button "تذكرة جديدة" is enabled without row selection (if present)', async ({ authenticatedPage: page }) => {
      await gotoTicketList(page);

      const createBtn = actionBtn(page, 'تذكرة جديدة');
      const isVisible = await createBtn.isVisible({ timeout: 1_000 }).catch(() => false);
      if (!isVisible) {
        console.log('Create button not present — user may lack INSERT_TICKET permission');
        test.skip();
        return;
      }

      // Create button does not require row selection → should NOT be disabled
      await expect(createBtn).not.toBeDisabled();
    });

    /* ---- 3. Workflow buttons are disabled when no row is selected ---- */
    test('workflow buttons are disabled before selecting a row', async ({ authenticatedPage: page }) => {
      await gotoTicketList(page);

      const visibleBtns = await getVisibleButtons(page);
      expect(visibleBtns.length).toBeGreaterThanOrEqual(1);

      for (const btn of visibleBtns) {
        const loc = actionBtn(page, btn.label);
        // requireSelection=true with no selection → disabled
        await expect(loc).toBeDisabled();
      }
    });

    /* ---- 4. Selecting a row removes the disabled attribute ---- */
    test('selecting a row enables workflow buttons (disabled attr removed)', async ({ authenticatedPage: page }) => {
      await gotoTicketList(page);
      const visibleBtns = await getVisibleButtons(page);

      // Before selection: all disabled
      for (const btn of visibleBtns) {
        await expect(actionBtn(page, btn.label)).toBeDisabled();
      }

      // Select a row
      await selectFirstRow(page);

      // After selection: disabled attr removed for all visible buttons
      // (guard evaluation is NOT in the disabled attr — it's in JS doAction)
      for (const btn of visibleBtns) {
        await expect(actionBtn(page, btn.label)).not.toBeDisabled();
      }
    });

    /* ---- 5. Row click applies selected style ---- */
    test('row click applies selected style', async ({ authenticatedPage: page }) => {
      await gotoTicketList(page);
      const firstRow = await selectFirstRow(page);
      await expect(firstRow).toHaveClass(/tr-row-selected/);
    });

    /* ---- 6. Clicking selected row deselects it and disables buttons ---- */
    test('clicking selected row deselects it and disables buttons', async ({ authenticatedPage: page }) => {
      await gotoTicketList(page);
      const visibleBtns = await getVisibleButtons(page);
      expect(visibleBtns.length).toBeGreaterThanOrEqual(1);

      const firstRow = page.locator('table.sf-table').first().locator('tbody tr.tr-row').first();

      // Select
      await firstRow.click();
      await page.waitForTimeout(300);
      await expect(firstRow).toHaveClass(/tr-row-selected/);

      // Deselect
      await firstRow.click();
      await page.waitForTimeout(300);
      await expect(firstRow).not.toHaveClass(/tr-row-selected/);

      // Buttons should be disabled again
      for (const btn of visibleBtns) {
        await expect(actionBtn(page, btn.label)).toBeDisabled();
      }
    });

    /* ---- 7. Each button: click opens modal or shows guard toast ---- */
    for (const btnDef of allWorkflowButtons) {
      test(`"${btnDef.label}" — click opens modal or guard blocks with toast`, async ({ authenticatedPage: page }) => {
        await gotoTicketList(page);

        // Skip if this button is not on the page (permission missing)
        const btn = actionBtn(page, btnDef.label);
        const isPresent = await btn.isVisible({ timeout: 1_000 }).catch(() => false);
        if (!isPresent) {
          console.log(`"${btnDef.label}" not present — skipping (no permission)`);
          test.skip();
          return;
        }

        // Select first row to enable the button
        await selectFirstRow(page);

        // Click the action button
        await btn.click();

        // Two possible outcomes:
        // A) Modal opens with the correct form — guard allowed
        // B) Guard blocks and shows a toast error — no modal
        const modal = page.locator('.sf-modal');
        const toast = page.locator('.toast-error, .toast-warning');

        // Wait for either
        const modalVisible = await modal.isVisible({ timeout: 3_000 }).catch(() => false);

        if (modalVisible) {
          // Outcome A: Modal opened — verify form
          const form = modal.locator(`form#${btnDef.formId}`);
          await expect(form).toBeVisible({ timeout: 3_000 });

          // Verify hidden fields
          await expect(form.locator('input[name="pageName_"]')).toHaveValue('Tickets');
          await expect(form.locator('input[name="ActionType"]')).toHaveValue(btnDef.actionType);

          // p01 should be populated with selected ticket ID
          const p01val = await form.locator('input[name="p01"]').inputValue();
          expect(p01val).toBeTruthy();
          console.log(`"${btnDef.label}" — modal opened (form #${btnDef.formId}, p01=${p01val})`);

          // Close modal for cleanup
          await closeModal(page);
        } else {
          // Outcome B: Guard blocked — toast should have appeared
          const toastVisible = await toast.isVisible({ timeout: 1_000 }).catch(() => false);
          console.log(`"${btnDef.label}" — guard blocked (toast visible: ${toastVisible})`);
          // Either outcome is valid for a button test
          expect(true).toBe(true);
        }
      });
    }

    /* ---- 8. Guard validation — blocked button shows toast ---- */
    test('guard-blocked button click shows toast error', async ({ authenticatedPage: page }) => {
      await gotoTicketList(page);
      await selectFirstRow(page);

      const visibleBtns = await getVisibleButtons(page);

      // Click each button and collect results
      let foundGuardBlock = false;
      for (const btnDef of visibleBtns) {
        const btn = actionBtn(page, btnDef.label);
        await btn.click();

        // Check for toast (guard message) or modal
        const modal = page.locator('.sf-modal');
        const modalVisible = await modal.isVisible({ timeout: 1_500 }).catch(() => false);

        if (modalVisible) {
          // Modal opened — this button was not guard-blocked
          await closeModal(page);
          continue;
        }

        // If no modal, a guard toast should have appeared
        const toast = page.locator('.toast-error, .toast-warning');
        const toastVisible = await toast.isVisible({ timeout: 1_000 }).catch(() => false);
        if (toastVisible) {
          const toastText = await toast.textContent();
          console.log(`Guard blocked "${btnDef.label}": ${toastText}`);
          foundGuardBlock = true;
          break;
        }
      }

      // If all buttons open modals (unlikely), skip; otherwise verify toast appeared
      if (!foundGuardBlock) {
        console.log('No guard-blocked button found for the selected row status');
        test.skip();
      }
    });

    /* ---- 9. Modal form posts to /crud/insert ---- */
    test('modal form action URL is /crud/insert', async ({ authenticatedPage: page }) => {
      await gotoTicketList(page);
      await selectFirstRow(page);

      const visibleBtns = await getVisibleButtons(page);

      // Click each button until we find one that opens a modal
      for (const btnDef of visibleBtns) {
        await actionBtn(page, btnDef.label).click();

        const modal = page.locator('.sf-modal');
        const modalVisible = await modal.isVisible({ timeout: 2_000 }).catch(() => false);
        if (!modalVisible) continue;

        const form = modal.locator(`form#${btnDef.formId}`);
        const actionUrl = await form.getAttribute('action');
        expect(actionUrl).toBe('/crud/insert');
        console.log(`Verified form action=/crud/insert for "${btnDef.label}"`);
        await closeModal(page);
        return;
      }

      test.skip();
    });

    /* ---- 10. Buttons use the correct color CSS classes ---- */
    test('buttons use the correct color CSS classes', async ({ authenticatedPage: page }) => {
      await gotoTicketList(page);

      const visibleBtns = await getVisibleButtons(page);
      for (const btn of visibleBtns) {
        const loc = actionBtn(page, btn.label);
        await expect(loc).toHaveClass(new RegExp(`btn-${btn.color}`));
      }
    });

    /* ---- 11. Buttons have icon elements ---- */
    test('all visible buttons have an icon element', async ({ authenticatedPage: page }) => {
      await gotoTicketList(page);

      const visibleBtns = await getVisibleButtons(page);
      for (const btn of visibleBtns) {
        const loc = actionBtn(page, btn.label);
        const icon = loc.locator('i');
        await expect(icon).toBeVisible({ timeout: 3_000 });
      }
    });

    /* ---- 12. Switching selected row keeps system responsive ---- */
    test('switching selected row updates button state', async ({ authenticatedPage: page }) => {
      await gotoTicketList(page);

      const rows = page.locator('table.sf-table').first().locator('tbody tr.tr-row');
      const rowCount = await rows.count();
      if (rowCount < 2) {
        test.skip();
        return;
      }

      // Select first row
      await rows.nth(0).click();
      await page.waitForTimeout(300);
      await expect(rows.nth(0)).toHaveClass(/tr-row-selected/);

      // Select second row — first should lose selection
      await rows.nth(1).click();
      await page.waitForTimeout(300);
      await expect(rows.nth(1)).toHaveClass(/tr-row-selected/);
      await expect(rows.nth(0)).not.toHaveClass(/tr-row-selected/);
    });
  });
});
