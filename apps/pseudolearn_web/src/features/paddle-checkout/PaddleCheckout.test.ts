import { experimental_AstroContainer as AstroContainer } from 'astro/container';
import { beforeAll, describe, expect, it } from 'vitest';
import PaddleCheckout from './PaddleCheckout.astro';

let container: AstroContainer;

beforeAll(async () => {
  container = await AstroContainer.create();
});

describe('PaddleCheckout', () => {
  it('renders the token, the environment and only the loading message at first', async () => {
    const html = await container.renderToString(PaddleCheckout, {
      props: { locale: 'es', token: 'live_abc', environment: 'production' },
    });
    expect(html).toContain('data-paddle-token="live_abc"');
    expect(html).toContain('data-paddle-environment="production"');
    expect(html).toContain('Abriendo el pago seguro');
    expect(html.match(/data-checkout-message="[a-z]+"/g)).toHaveLength(5);
    expect(html).toMatch(/data-checkout-message="completed"[^>]*hidden/);
  });

  it('offers the way back to the app hidden until the payment ends', async () => {
    const html = await container.renderToString(PaddleCheckout, {
      props: { locale: 'en', token: '', environment: 'sandbox' },
    });
    expect(html).toContain('href="pseudolearn://agent/purchase"');
    expect(html).toMatch(/data-checkout-return[^>]*hidden/);
    expect(html).toContain('Back to PseudoLearn');
  });
});
