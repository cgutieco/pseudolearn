import { expect, test } from '@playwright/test';

const ROUTES = [
  { path: '/', name: 'home' },
  { path: '/contact', name: 'contact' },
  { path: '/versions', name: 'versions' },
];

const VIEWPORTS = [
  { width: 390, height: 844, name: 'mobile' },
  { width: 1440, height: 900, name: 'desktop' },
];

for (const route of ROUTES) {
  for (const viewport of VIEWPORTS) {
    test(`${route.name} renders within the ${viewport.name} viewport`, async ({ page }) => {
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await page.goto(route.path);
      await page.evaluate(() => document.fonts.ready);
      const main = page.locator('main');
      await expect(main).toBeVisible();
      const mainBounds = await main.boundingBox();
      expect(mainBounds?.width).toBeGreaterThan(0);
      expect(mainBounds?.height).toBeGreaterThan(0);
      const documentWidth = await page.evaluate(() => ({
        content: document.documentElement.scrollWidth,
        viewport: window.innerWidth,
      }));
      expect(documentWidth.content).toBeLessThanOrEqual(documentWidth.viewport);
    });
  }
}
