import { describe, expect, it } from 'vitest';
import { initialStatusOf, paddleEnvironmentOf, STATUS_KEYS, statusAfterEvent } from './checkout-status';

describe('initialStatusOf', () => {
  it('waits for the checkout when the link carries a Paddle transaction', () => {
    expect(initialStatusOf('?_ptxn=txn_01h8abc')).toBe('loading');
  });

  it('reports a missing payment without a transaction or with a malformed one', () => {
    expect(initialStatusOf('')).toBe('missing');
    expect(initialStatusOf('?_ptxn=')).toBe('missing');
    expect(initialStatusOf('?_ptxn=<script>')).toBe('missing');
    expect(initialStatusOf('?other=txn_1')).toBe('missing');
  });
});

describe('statusAfterEvent', () => {
  it('follows the checkout events Paddle reports', () => {
    expect(statusAfterEvent('loading', 'checkout.completed')).toBe('completed');
    expect(statusAfterEvent('loading', 'checkout.closed')).toBe('closed');
    expect(statusAfterEvent('loading', 'checkout.error')).toBe('unavailable');
  });

  it('keeps the status on unrelated events and once the payment is complete', () => {
    expect(statusAfterEvent('loading', 'checkout.loaded')).toBe('loading');
    expect(statusAfterEvent('completed', 'checkout.closed')).toBe('completed');
  });
});

describe('paddleEnvironmentOf', () => {
  it('only uses the sandbox when asked explicitly', () => {
    expect(paddleEnvironmentOf('sandbox')).toBe('sandbox');
    expect(paddleEnvironmentOf('')).toBe('production');
    expect(paddleEnvironmentOf('staging')).toBe('production');
  });
});

describe('STATUS_KEYS', () => {
  it('gives every status its own message', () => {
    expect(new Set(Object.values(STATUS_KEYS)).size).toBe(Object.keys(STATUS_KEYS).length);
  });
});
