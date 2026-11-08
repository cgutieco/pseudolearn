import { isRecord } from "./credits.ts";

export interface Balance {
  readonly periodActive: boolean;
  readonly trial: boolean;
  readonly trialUsed: boolean;
  readonly allowanceMilli: number;
  readonly periodRemainingMilli: number;
  readonly topUpMilli: number;
  readonly renewsAt: string | null;
}

export const emptyBalance: Balance = {
  periodActive: false,
  trial: false,
  trialUsed: false,
  allowanceMilli: 0,
  periodRemainingMilli: 0,
  topUpMilli: 0,
  renewsAt: null,
};

export function remainingMilli(balance: Balance): number {
  return balance.periodRemainingMilli + balance.topUpMilli;
}

export function balanceFrom(raw: unknown): Balance | null {
  if (!isRecord(raw)) return null;
  const numbers = [raw.allowance_milli, raw.period_remaining_milli, raw.top_up_milli];
  if (!numbers.every((value) => typeof value === "number")) return null;
  return {
    periodActive: raw.period_active === true,
    trial: raw.trial === true,
    trialUsed: raw.trial_used === true,
    allowanceMilli: raw.allowance_milli as number,
    periodRemainingMilli: raw.period_remaining_milli as number,
    topUpMilli: raw.top_up_milli as number,
    renewsAt: typeof raw.renews_at === "string" ? raw.renews_at : null,
  };
}
