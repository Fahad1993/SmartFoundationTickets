const { chromium } = require('playwright');
const path = require('path');

async function takeScreenshot() {
    const browser = await chromium.launch({ headless: false });
    const context = await browser.newContext({
        viewport: { width: 1920, height: 1080 }
    });
    const page = await context.newPage();

    try {
        console.log('Navigating to login page...');
        await page.goto('http://localhost:5000/Login/Index', { waitUntil: 'networkidle' });

        console.log('Logging in...');
        await page.fill('#txtNationalID', '1064184763');
        await page.fill('#txtPassword', 'Aa123456');
        await page.click('#btnLogin');

        // Wait for navigation after login
        await page.waitForLoadState('networkidle', { timeout: 15000 });

        console.log('Logged in successfully');

        // Try direct navigation to TicketDetails with a known ticket ID
        // Let's try different ticket IDs
        const ticketIds = [1, 2, 3, 4, 5, 10];
        let found = false;

        for (const id of ticketIds) {
            console.log(`Trying ticket ID ${id}...`);
            try {
                await page.goto(`http://localhost:5000/Ticket/TicketDetails?id=${id}`, { waitUntil: 'networkidle', timeout: 10000 });

                // Check if we're on a ticket details page
                const pageTitle = await page.title();
                const url = page.url();

                // Check for ticket details elements
                const hasTicketHeader = await page.locator('.ticket-header-section').count() > 0;
                const hasTicketInfo = await page.locator('.ticket-details-page').count() > 0;

                console.log(`  - Title: ${pageTitle}`);
                console.log(`  - URL: ${url}`);
                console.log(`  - Has ticket header: ${hasTicketHeader}`);
                console.log(`  - Has ticket details page: ${hasTicketInfo}`);

                if (hasTicketHeader || hasTicketInfo) {
                    console.log(`Found valid ticket details page with ID ${id}!`);
                    found = true;
                    break;
                }
            } catch (e) {
                console.log(`  - Error with ticket ${id}: ${e.message}`);
            }
        }

        if (!found) {
            console.log('Trying ticket list page to find available tickets...');
            await page.goto('http://localhost:5000/Ticket/TicketList', { waitUntil: 'networkidle' });

            // Get the first ticket link
            const ticketLink = await page.locator('a[href*="/Ticket/TicketDetails"]').first();
            const linkCount = await ticketLink.count();

            console.log(`Found ${linkCount} ticket links`);

            if (linkCount > 0) {
                const href = await ticketLink.getAttribute('href');
                console.log(`Clicking link: ${href}`);
                await ticketLink.click();
                await page.waitForLoadState('networkidle', { timeout: 10000 });
            } else {
                console.log('No ticket links found, taking screenshot of current page...');
            }
        }

        // Wait for page to be fully loaded
        await page.waitForTimeout(2000);

        // Take screenshot
        const screenshotPath = path.join(__dirname, 'screenshot-current.png');
        await page.screenshot({ path: screenshotPath, fullPage: true });
        console.log('Screenshot saved to:', screenshotPath);

        console.log('Current URL:', page.url());

        // Keep browser open for a moment
        await page.waitForTimeout(3000);

    } catch (error) {
        console.error('Error:', error.message);
        console.error(error.stack);
    } finally {
        await browser.close();
    }
}

takeScreenshot();
