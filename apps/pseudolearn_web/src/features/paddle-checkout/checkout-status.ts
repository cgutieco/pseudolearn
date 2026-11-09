import type { TranslationKey } from '@shared/i18n/translator';

export type CheckoutStatus = 'loading' | 'missing' | 'unavailable' | 'closed' | 'completed';

export const TRANSACTION_PARAMETER = '_ptxn';

const STATUS_BY_EVENT: Readonly<Record<string, CheckoutStatus>> = {
  'checkout.completed': 'completed',
  'checkout.closed': 'closed',
  'checkout.error': 'unavailable',
};

export const STATUS_KEYS: Readonly<Record<CheckoutStatus, TranslationKey>> = {
  loading: 'checkout.loading',
  missing: 'checkout.missing',
  unavailable: 'checkout.unavailable',
  closed: 'checkout.closed',
  completed: 'checkout.completed',
};

export function initialStatusOf(search: string): CheckoutStatus {
  const transaction = new URLSearchParams(search).get(TRANSACTION_PARAMETER) ?? '';
  return /^txn_[a-z0-9]+$/i.test(transaction) ? 'loading' : 'missing';
}

export function statusAfterEvent(current: CheckoutStatus, eventName: string): CheckoutStatus {
  if (current === 'completed') return current;
  return STATUS_BY_EVENT[eventName] ?? current;
}

export function paddleEnvironmentOf(value: string): 'sandbox' | 'production' {
  return value === 'sandbox' ? 'sandbox' : 'production';
}
