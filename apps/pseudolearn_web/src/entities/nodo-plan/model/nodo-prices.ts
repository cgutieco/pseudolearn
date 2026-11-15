import type { TranslationKey } from '@shared/i18n/translator';

export interface NodoPriceAmounts {
  readonly currency: string;
  readonly monthly: number;
  readonly topUp: number;
}

export interface NodoMarketPrice {
  readonly marketKey: TranslationKey;
  readonly appStore: NodoPriceAmounts;
  readonly windows: NodoPriceAmounts;
}

const WINDOWS: NodoPriceAmounts = { currency: 'USD', monthly: 3.49, topUp: 2.49 };
const PERU_APP_STORE: NodoPriceAmounts = { currency: 'PEN', monthly: 11.9, topUp: 7.9 };
const MEXICO_APP_STORE: NodoPriceAmounts = { currency: 'MXN', monthly: 65, topUp: 45 };

export const NODO_PRICES: readonly NodoMarketPrice[] = [
  { marketKey: 'nodo.prices.market.peru', appStore: PERU_APP_STORE, windows: WINDOWS },
  { marketKey: 'nodo.prices.market.mexico', appStore: MEXICO_APP_STORE, windows: WINDOWS },
  { marketKey: 'nodo.prices.market.rest', appStore: WINDOWS, windows: WINDOWS },
];

export function sharesOnePrice(price: NodoMarketPrice): boolean {
  return price.appStore === price.windows;
}
