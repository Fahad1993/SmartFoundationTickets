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
    await page.waitForURL('**/Home**', { timeout: 20_000 });
    await use(page);
  },
});

test.describe('Ticket Lifecycle Stress', () => {
  test.skip(() => !NATIONAL_ID || !PASSWORD, 'SF_NATIONAL_ID and SF_PASSWORD env vars required');

  async function gotoTicketList(page: Page) {
    await page.goto('/Ticket/TicketList');
    await expect(page.locator('table.sf-table').first()).toBeVisible({ timeout: 20_000 });
  }

  async function waitForTableReady(page: Page) {
    await expect(page.locator('table.sf-table').first()).toBeVisible({ timeout: 20_000 });
    await page.waitForLoadState('networkidle');
  }

  async function closeModal(page: Page) {
    const modal = page.locator('.sf-modal, [role="dialog"]').first();
    if (!(await modal.isVisible().catch(() => false))) {
      return;
    }

    const closeButton = modal.locator('.sf-modal-close, [data-modal-close], .sf-modal-cancel, .sf-modal-btn-cancel, button:has-text("إلغاء"), button:has-text("✕")').first();
    if (await closeButton.isVisible().catch(() => false)) {
      await closeButton.click();
    } else {
      await page.keyboard.press('Escape');
    }

    await modal.waitFor({ state: 'hidden', timeout: 5_000 }).catch(async () => {
      await page.keyboard.press('Escape');
      await modal.waitFor({ state: 'hidden', timeout: 5_000 }).catch(() => {});
    });
  }

  function getToastLocator(page: Page, toastType: 'success' | 'error' | 'warning') {
    const selectors = [`.sf-toast[data-toast-type="${toastType}"]`];

    if (toastType === 'success') {
      selectors.push('.toast-success');
    } else {
      selectors.push('.toast-error', '.toast-warning');
    }

    return page.locator(selectors.join(', ')).last();
  }

  async function setSelectValue(page: Page, name: string, optionText: string) {
    const result = await page.evaluate(({ fieldName, fieldValue }) => {
      const $ = (window as any).jQuery;
      const field = document.querySelector(`.sf-modal form [name="${fieldName}"]`);
      if (!(field instanceof HTMLSelectElement)) {
        return { ok: false, reason: 'field-missing' };
      }

      const option = Array.from(field.options).find(candidate => {
        return !!candidate.value && !candidate.disabled && candidate.text.trim() === fieldValue;
      });

      if (!option) {
        return { ok: false, reason: 'option-missing' };
      }

      field.value = option.value;
      if (typeof $ === 'function') {
        $(field).trigger('change');
      } else {
        field.dispatchEvent(new Event('change', { bubbles: true }));
      }

      return { ok: true, value: option.value, text: option.text.trim() };
    }, { fieldName: name, fieldValue: optionText });

    expect(result.ok, `${name}: ${result.ok ? 'ok' : result.reason}`).toBe(true);
    await page.waitForTimeout(250);
    return result as { ok: true; value: string; text: string };
  }

  async function setSelectToDifferentValue(page: Page, name: string, excludedText: string) {
    const result = await page.evaluate(({ fieldName, currentText }) => {
      const $ = (window as any).jQuery;
      const field = document.querySelector(`.sf-modal form [name="${fieldName}"]`);
      if (!(field instanceof HTMLSelectElement)) {
        return { ok: false, reason: 'field-missing' };
      }

      const option = Array.from(field.options).find(candidate => {
        const text = candidate.text.trim();
        return !!candidate.value && !candidate.disabled && text && text !== currentText && text !== 'الرجاء الاختيار';
      });

      if (!option) {
        return { ok: false, reason: 'option-missing' };
      }

      field.value = option.value;
      if (typeof $ === 'function') {
        $(field).trigger('change');
      } else {
        field.dispatchEvent(new Event('change', { bubbles: true }));
      }

      return { ok: true, value: option.value, text: option.text.trim() };
    }, { fieldName: name, currentText: excludedText });

    expect(result.ok, `${name}: ${result.ok ? 'ok' : result.reason}`).toBe(true);
    await page.waitForTimeout(250);
    return result as { ok: true; value: string; text: string };
  }

  async function setTextField(page: Page, name: string, value: string) {
    const field = page.locator(`.sf-modal form [name="${name}"]`).first();
    await expect(field).toBeVisible({ timeout: 10_000 });
    await field.fill(value);
  }

  async function findRowByTicketNo(page: Page, ticketNo: string) {
    const row = page.locator('table.sf-table tbody tr').filter({ hasText: ticketNo }).first();
    await expect(row).toBeVisible({ timeout: 15_000 });
    return row;
  }

  async function getRowPriority(row: any) {
    return (await row.locator('td').nth(4).innerText()).trim();
  }

  async function clickRowAction(page: Page, ticketNo: string, actionLabel: string) {
    const row = await findRowByTicketNo(page, ticketNo);
    await row.locator('button.sf-row-menu__btn').click();
    const actionButton = page.locator('.sf-row-menu__panel:visible .sf-row-menu__item').filter({ hasText: actionLabel }).first();
    await expect(actionButton).toBeVisible({ timeout: 5_000 });
    await actionButton.click();
  }

  async function openRowActionModal(page: Page, ticketNo: string, actionLabel: string) {
    await clickRowAction(page, ticketNo, actionLabel);
    await expect(page.locator('.sf-modal form').first()).toBeVisible({ timeout: 10_000 });
  }

  async function submitModal(page: Page, submitText: string) {
    const submitButton = page.locator('.sf-modal button').filter({ hasText: submitText }).first();
    await expect(submitButton).toBeVisible({ timeout: 10_000 });
    await submitButton.click();
    await page.waitForLoadState('networkidle');
  }

  async function expectGuardToast(page: Page) {
    const toast = getToastLocator(page, 'error');
    await expect(toast).toBeVisible({ timeout: 10_000 });
    return (await toast.innerText()).trim();
  }

  async function updateTicketPriority(page: Page, ticketNo: string, targetPriorityText: string, notes: string) {
    await openRowActionModal(page, ticketNo, 'تعديل الأولوية');
    await setSelectValue(page, 'p02', targetPriorityText);
    await setTextField(page, 'p03', notes);
    await submitModal(page, 'تنفيذ');
    await waitForTableReady(page);
  }

  test('hides create action when the user lacks INSERT_TICKET', async ({ authenticatedPage: page }) => {
    await gotoTicketList(page);
    await expect(page.locator('button').filter({ hasText: 'تذكرة جديدة' })).toHaveCount(0);
  });

  test('updates ticket priority and restores the seeded value (TKT-2026-0008)', async ({ authenticatedPage: page }) => {
    const ticketNo = 'TKT-2026-0008';

    await gotoTicketList(page);
    const row = await findRowByTicketNo(page, ticketNo);
    const originalPriority = await getRowPriority(row);

    await openRowActionModal(page, ticketNo, 'تعديل الأولوية');
    const updatedPriority = await setSelectToDifferentValue(page, 'p02', originalPriority);
    await setTextField(page, 'p03', 'Playwright priority validation');
    await submitModal(page, 'تنفيذ');
    await waitForTableReady(page);

    await expect.poll(async () => await getRowPriority(await findRowByTicketNo(page, ticketNo)), { timeout: 15_000 }).toBe(updatedPriority.text);

    await openRowActionModal(page, ticketNo, 'تعديل الأولوية');
    await setSelectValue(page, 'p02', originalPriority);
    await setTextField(page, 'p03', 'Restore seeded priority');
    await submitModal(page, 'تنفيذ');
    await waitForTableReady(page);

    await expect.poll(async () => await getRowPriority(await findRowByTicketNo(page, ticketNo)), { timeout: 15_000 }).toBe(originalPriority);
  });

  test('UPDATE_PRIORITY escalation and lowering on TKT-2026-0010 (previously unreliable)', async ({ authenticatedPage: page }) => {
    const ticketNo = 'TKT-2026-0010';

    await gotoTicketList(page);
    const row = await findRowByTicketNo(page, ticketNo);
    const originalPriority = await getRowPriority(row);

    await updateTicketPriority(page, ticketNo, 'حرج', 'Playwright: escalate to critical');
    await expect.poll(async () => await getRowPriority(await findRowByTicketNo(page, ticketNo)), { timeout: 15_000 }).toBe('حرج');

    await updateTicketPriority(page, ticketNo, 'منخفض', 'Playwright: lower to low');
    await expect.poll(async () => await getRowPriority(await findRowByTicketNo(page, ticketNo)), { timeout: 15_000 }).toBe('منخفض');

    await updateTicketPriority(page, ticketNo, originalPriority, 'Playwright: restore original');
    await expect.poll(async () => await getRowPriority(await findRowByTicketNo(page, ticketNo)), { timeout: 15_000 }).toBe(originalPriority);
  });

  test('repeated UPDATE_PRIORITY does not produce generic error 4096', async ({ authenticatedPage: page }) => {
    const ticketNo = 'TKT-2026-0008';
    const priorities = ['حرج', 'مرتفع', 'متوسط', 'منخفض', 'مرتفع', 'حرج'];

    await gotoTicketList(page);
    const row = await findRowByTicketNo(page, ticketNo);
    const originalPriority = await getRowPriority(row);

    for (const priority of priorities) {
      await updateTicketPriority(page, ticketNo, priority, `Stress test: set to ${priority}`);
      await expect.poll(async () => await getRowPriority(await findRowByTicketNo(page, ticketNo)), { timeout: 15_000 }).toBe(priority);
    }

    await updateTicketPriority(page, ticketNo, originalPriority, 'Stress test: restore original');
    await expect.poll(async () => await getRowPriority(await findRowByTicketNo(page, ticketNo)), { timeout: 15_000 }).toBe(originalPriority);
  });

  test('shows guard feedback for an invalid pause transition', async ({ authenticatedPage: page }) => {
    await gotoTicketList(page);
    await clickRowAction(page, 'TKT-2026-0010', 'إيقاف مؤقت');

    const toastText = await expectGuardToast(page);
    expect(toastText).toContain('متاح فقط للتذاكر قيد العمل');
    await expect(page.locator('.sf-modal form').first()).toBeHidden();
  });

  test('UPDATE_PRIORITY guard blocks on CLOSED/REJECTED tickets', async ({ authenticatedPage: page }) => {
    await gotoTicketList(page);

    const closedRow = page.locator('table.sf-table tbody tr').filter({ hasText: 'CLOSED' }).first();
    const hasClosedRow = await closedRow.isVisible({ timeout: 3_000 }).catch(() => false);

    if (!hasClosedRow) {
      const rejectedRow = page.locator('table.sf-table tbody tr').filter({ hasText: 'REJECTED' }).first();
      const hasRejectedRow = await rejectedRow.isVisible({ timeout: 3_000 }).catch(() => false);
      if (!hasRejectedRow) {
        test.skip();
        return;
      }
    }

    const targetRow = hasClosedRow
      ? closedRow
      : page.locator('table.sf-table tbody tr').filter({ hasText: 'REJECTED' }).first();

    const ticketNoText = await targetRow.locator('td').nth(1).innerText();
    const ticketNo = ticketNoText.trim();

    await clickRowAction(page, ticketNo, 'تعديل الأولوية');
    const toastText = await expectGuardToast(page);
    expect(toastText).toContain('غير متاح');
    await expect(page.locator('.sf-modal form').first()).toBeHidden();
  });
});
