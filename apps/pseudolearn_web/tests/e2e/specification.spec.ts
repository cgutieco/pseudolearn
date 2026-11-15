import { expect, test } from '@playwright/test';

test.describe('illustrated specification', () => {
  test('links every section from the contents and walks to the next one', async ({ page }) => {
    await page.goto('/spec');
    await expect(page.locator('h1')).toHaveCount(1);
    await page.locator('a[href="/spec/control/si"]').first().click();
    await expect(page).toHaveURL(/\/spec\/control\/si$/);
    await expect(page.locator('h1')).toContainText('Si');
    await page.locator('.pager__link--next').click();
    await expect(page).toHaveURL(/\/spec\/control\/segun$/);
  });

  test('announces the Markdown version of each page to agents', async ({ page }) => {
    await page.goto('/en/spec/control/si');
    await expect(page.locator('link[rel="alternate"][type="text/markdown"]')).toHaveAttribute(
      'href',
      '/en/spec/control/si.md',
    );
    await expect(page.locator('link[rel="alternate"][hreflang="es"]')).toHaveAttribute(
      'href',
      'https://pseudolearn.app/spec/control/si',
    );
  });

  test('serves the Markdown versions as text without markup', async ({ request }) => {
    const section = await request.get('/spec/control/si.md');
    expect(section.ok()).toBe(true);
    expect(section.headers()['content-type']).toContain('text/markdown');
    const text = await section.text();
    expect(text.startsWith('# 6.1 ')).toBe(true);
    expect(text).not.toContain('<svg');
    const contents = await request.get('/en/spec/index.md');
    expect(await contents.text()).toContain('(https://pseudolearn.app/en/spec/control/si.md)');
  });

  test('lists the specification in llms.txt and the sitemap', async ({ request }) => {
    const llms = await (await request.get('/llms.txt')).text();
    expect(llms).toContain('(/spec/index.md)');
    expect(llms).toContain('(/en/spec/index.md)');
    const sitemap = await (await request.get('/sitemap.xml')).text();
    expect(sitemap).toContain('<loc>https://pseudolearn.app/spec/control/si</loc>');
    expect(sitemap).toContain('<loc>https://pseudolearn.app/en/spec/control/si</loc>');
  });

  test('answers an unknown section with the not found page', async ({ page }) => {
    const response = await page.goto('/spec/no/existe');
    expect(response?.status()).toBe(404);
  });
});
