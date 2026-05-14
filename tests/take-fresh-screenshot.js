const { chromium } = require('playwright');
const path = require('path');

async function takeFreshScreenshot() {
    const browser = await chromium.launch({ headless: false });
    const context = await browser.newContext({
        viewport: { width: 1920, height: 1080 }
    });
    const page = await context.newPage();

    try {
        console.log('Navigating to login...');
        await page.goto('http://localhost:5000/Login/Index');
        await page.fill('#txtNationalID', '1064184763');
        await page.fill('#txtPassword', 'Aa123456');
        await page.click('#btnLogin');
        await page.waitForLoadState('networkidle', { timeout: 15000 });

        console.log('Navigating to ticket details...');
        await page.goto('http://localhost:5000/Ticket/TicketDetails?id=1', { waitUntil: 'networkidle' });

        // Wait for our custom elements to be visible
        await page.waitForSelector('.ticket-details-page', { timeout: 10000 });
        await page.waitForSelector('.ticket-header-section', { timeout: 10000 });

        // Scroll to top to make sure we capture the header
        await page.evaluate(() => window.scrollTo(0, 0));
        await page.waitForTimeout(1000);

        // Take screenshot of the whole page
        const screenshotPath = path.join(__dirname, 'screenshot-fresh.png');
        await page.screenshot({ path: screenshotPath, fullPage: true });
        console.log('Screenshot saved to:', screenshotPath);

        // Also take a viewport-only screenshot
        const viewportPath = path.join(__dirname, 'screenshot-viewport.png');
        await page.screenshot({ path: viewportPath, fullPage: false });
        console.log('Viewport screenshot saved to:', viewportPath);

        await page.waitForTimeout(3000);

    } catch (error) {
        console.error('Error:', error.message);
    } finally {
        await browser.close();
    }
}

takeFreshScreenshot();
