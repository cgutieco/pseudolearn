import { describe, expect, it } from 'vitest';
import { formatPrice } from './format-price';

const normalizeSpaces = (text: string): string => text.replace(/\s/g, ' ');

describe('formatPrice', () => {
  it('keeps two decimals for a fractional amount', () => {
    expect(normalizeSpaces(formatPrice('en', 'USD', 4.99))).toBe('USD 4.99');
  });

  it('drops decimals for a whole amount', () => {
    expect(normalizeSpaces(formatPrice('en', 'MXN', 69))).toBe('MXN 69');
  });

  it('uses the decimal comma of the Spanish locale', () => {
    expect(normalizeSpaces(formatPrice('es', 'PEN', 12.9))).toBe('12,90 PEN');
  });

  it('formats a zero amount without decimals', () => {
    expect(normalizeSpaces(formatPrice('en', 'USD', 0))).toBe('USD 0');
  });

  it('throws on a currency code Intl does not accept', () => {
    expect(() => formatPrice('en', 'not-a-currency', 1)).toThrow(RangeError);
  });
});
