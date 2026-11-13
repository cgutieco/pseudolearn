import type { TranslationKey } from '@shared/i18n/translator';

export interface NodoMarketPrice {
  readonly marketKey: TranslationKey;
  readonly currency: string;
  readonly monthly: number;
  readonly topUp: number;
}

export const NODO_PRICES: readonly NodoMarketPrice[] = [
  { marketKey: 'nodo.prices.market.peru', currency: 'PEN', monthly: 12.9, topUp: 7.9 },
  { marketKey: 'nodo.prices.market.mexico', currency: 'MXN', monthly: 69, topUp: 45 },
  { marketKey: 'nodo.prices.market.rest', currency: 'USD', monthly: 4.99, topUp: 2.99 },
];
