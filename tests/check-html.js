const { chromium } = require('playwright');
const fs = require('fs');

async function checkHTML() {
    const browser = await chromium.launch({ headless: false });
    const context = await browser.newContext();
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
        await page.waitForTimeout(2000);

        // Get the HTML content
        const html = await page.content();
        fs.writeFileSync('C:/Users/63100004/Desktop/dev/SmartFoundationTickets/tests/ticket-details-html.html', html);

        console.log('HTML saved to ticket-details-html.html');

        // Check for our custom classes
        const hasTicketDetailsPage = await page.locator('.ticket-details-page').count();
        const hasTicketHeaderSection = await page.locator('.ticket-header-section').count();
        const hasTicketCard = await page.locator('.ticket-card').count();

        console.log(`ticket-details-page elements: ${hasTicketDetailsPage}`);
        console.log(`ticket-header-section elements: ${hasTicketHeaderSection}`);
        console.log(`ticket-card elements: ${hasTicketCard}`);

        // Get page title
        const title = await page.title();
        console.log(`Page title: ${title}`);

        await page.waitForTimeout(3000);

    } catch (error) {
        console.error('Error:', error.message);
    } finally {
        await browser.close();
    }
}

checkHTML();
