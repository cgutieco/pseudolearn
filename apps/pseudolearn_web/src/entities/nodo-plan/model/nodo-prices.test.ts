import { describe, expect, it } from 'vitest';
import { NODO_PRICES, sharesOnePrice } from './nodo-prices';

describe('NODO_PRICES', () => {
  it('lists Peru, Mexico and the rest of the world in that order', () => {
    expect(NODO_PRICES.map((price) => price.marketKey)).toEqual([
      'nodo.prices.market.peru',
      'nodo.prices.market.mexico',
      'nodo.prices.market.rest',
    ]);
  });

  it('charges every market on Windows the same amount in US dollars', () => {
    const windowsPrices = new Set(NODO_PRICES.map((price) => price.windows));
    expect(windowsPrices.size).toBe(1);
    expect(NODO_PRICES[0]?.windows.currency).toBe('USD');
  });

  it('charges Peru and Mexico on the App Store in their own currency', () => {
    expect(NODO_PRICES[0]?.appStore.currency).toBe('PEN');
    expect(NODO_PRICES[1]?.appStore.currency).toBe('MXN');
  });

  it('keeps every amount positive', () => {
    for (const price of NODO_PRICES) {
      for (const amounts of [price.appStore, price.windows]) {
        expect(amounts.monthly).toBeGreaterThan(0);
        expect(amounts.topUp).toBeGreaterThan(0);
      }
    }
  });
});

describe('sharesOnePrice', () => {
  it('is false when the stores charge different amounts', () => {
    const peru = NODO_PRICES[0];
    expect(peru && sharesOnePrice(peru)).toBe(false);
  });

  it('is true when both stores charge the same amounts', () => {
    const rest = NODO_PRICES[2];
    expect(rest && sharesOnePrice(rest)).toBe(true);
  });
});
