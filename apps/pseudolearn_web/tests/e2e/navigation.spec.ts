import { expect, test } from '@playwright/test';

const ROUTES = [
  '/',
  '/language',
  '/learn',
  '/nodo',
  '/download',
  '/en/language',
  '/en/learn',
  '/en/nodo',
  '/en/download',
  '/contact',
  '/versions',
  '/privacy',
  '/terms',
  '/en',
  '/en/contact',
  '/en/versions',
  '/en/privacy',
  '/en/terms',
];

test.describe('routing', () => {
  for (const route of ROUTES) {
    test(`serves ${route} with a single first level heading`, async ({ page }) => {
      const response = await page.goto(route);
      expect(response?.status()).toBe(200);
      await expect(page.locator('h1')).toHaveCount(1);
    });
  }

  test('keeps the primary navigation on pages, never on anchors', async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 900 });
    await page.goto('/learn');
    const hrefs = await page
      .locator('.site-header__nav a')
      .evaluateAll((links) => links.map((link) => link.getAttribute('href')));
    expect(hrefs).toEqual(['/language', '/learn', '/nodo', '/spec']);
    await expect(page.locator('.site-header__nav a[aria-current="page"]')).toHaveText('Aprender');
  });

  test('jumps to a section from the in-page index', async ({ page }) => {
    await page.goto('/nodo');
    await page.locator('.page-sections a[href="#plans"]').click();
    await expect(page).toHaveURL(/#plans$/);
    await expect(page.locator('#plans')).toBeInViewport();
  });

  test('redirects the legacy spanish paths', async ({ page }) => {
    await page.goto('/contacto');
    await expect(page).toHaveURL(/\/contact$/);
    await page.goto('/versiones');
    await expect(page).toHaveURL(/\/versions$/);
    await page.goto('/privacidad');
    await expect(page).toHaveURL(/\/privacy$/);
    await page.goto('/terminos');
    await expect(page).toHaveURL(/\/terms$/);
    await page.goto('/legal');
    await expect(page).toHaveURL(/\/terms$/);
  });

  test('declares reciprocal hreflang alternates', async ({ page }) => {
    await page.goto('/contact');
    await expect(page.locator('link[rel="alternate"][hreflang="es"]')).toHaveAttribute(
      'href',
      'https://pseudolearn.app/contact',
    );
    await expect(page.locator('link[rel="alternate"][hreflang="en"]')).toHaveAttribute(
      'href',
      'https://pseudolearn.app/en/contact',
    );
    await expect(page.locator('link[rel="alternate"][hreflang="x-default"]')).toHaveCount(1);
  });

  test('points canonical at the right domain', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('link[rel="canonical"]')).toHaveAttribute('href', 'https://pseudolearn.app/');
  });

  test('exposes a skip link that reaches the main landmark', async ({ page }) => {
    await page.goto('/');
    await page.keyboard.press('Tab');
    const skipLink = page.locator('.pl-skip-link');
    await expect(skipLink).toBeFocused();
    await skipLink.press('Enter');
    await expect(page).toHaveURL(/#main-content$/);
  });

  test('serves a sitemap listing both languages', async ({ page }) => {
    const response = await page.goto('/sitemap.xml');
    const body = (await response?.text()) ?? '';
    expect(body).toContain('https://pseudolearn.app/contact');
    expect(body).toContain('https://pseudolearn.app/en/contact');
  });

  test('answers a missing page with the localized not found view', async ({ page }) => {
    const response = await page.goto('/no-existe');
    expect(response?.status()).toBe(404);
  });
});
