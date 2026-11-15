export const milliPerCredit = 1_000;
export const planCredits = 300;
export const trialCredits = 40;
export const trialDays = 7;
export const planDays = 30;
export const topUpCredits = 150;
export const requestCapCredits = 15;
export const maxOutputTokens = 4_000;
export const callsPerMinute = 60;

const tokensPerCredit = 10_000;
const uncachedInputWeight = 1.25;
const cachedInputWeight = 0.1;
const outputWeight = 5;

export interface TokenUsage {
  readonly inputTokens: number;
  readonly cachedInputTokens: number;
  readonly outputTokens: number;
}

export function milliCreditsFor(usage: TokenUsage): number {
  const input = nonNegative(usage.inputTokens);
  const cached = Math.min(nonNegative(usage.cachedInputTokens), input);
  const output = nonNegative(usage.outputTokens);
  const weighted = uncachedInputWeight * (input - cached) + cachedInputWeight * cached +
    outputWeight * output;
  return Math.ceil((weighted / tokensPerCredit) * milliPerCredit);
}

export function usageFromResponses(body: unknown): TokenUsage | null {
  if (!isRecord(body) || !isRecord(body.usage)) return null;
  const usage = body.usage;
  const details = isRecord(usage.input_tokens_details) ? usage.input_tokens_details : {};
  if (typeof usage.input_tokens !== "number" || typeof usage.output_tokens !== "number") {
    return null;
  }
  const cached = typeof details.cached_tokens === "number" ? details.cached_tokens : 0;
  return {
    inputTokens: usage.input_tokens,
    cachedInputTokens: cached,
    outputTokens: usage.output_tokens,
  };
}

export function displayCredits(milli: number): number {
  return Math.max(0, Math.floor(milli / milliPerCredit));
}

export function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function nonNegative(value: number): number {
  return Number.isFinite(value) && value > 0 ? value : 0;
}
