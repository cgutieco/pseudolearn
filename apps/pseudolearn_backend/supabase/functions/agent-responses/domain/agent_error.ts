export type AgentErrorCode =
  | "unauthenticated"
  | "subscription_required"
  | "credits_exhausted"
  | "request_cap"
  | "invalid_request"
  | "payload_too_large"
  | "method_not_allowed"
  | "not_found"
  | "rate_limited"
  | "upstream_error"
  | "upstream_rate_limited"
  | "model_unconfigured"
  | "purchases_disabled"
  | "trial_used"
  | "purchase_owned_elsewhere"
  | "already_subscribed"
  | "invalid_signature"
  | "misconfigured"
  | "unexpected_failure";

export const statusByCode: Readonly<Record<AgentErrorCode, number>> = {
  unauthenticated: 401,
  subscription_required: 402,
  credits_exhausted: 402,
  request_cap: 429,
  invalid_request: 422,
  payload_too_large: 413,
  method_not_allowed: 405,
  not_found: 404,
  rate_limited: 429,
  upstream_error: 502,
  upstream_rate_limited: 503,
  model_unconfigured: 503,
  purchases_disabled: 403,
  trial_used: 409,
  purchase_owned_elsewhere: 409,
  already_subscribed: 409,
  invalid_signature: 401,
  misconfigured: 500,
  unexpected_failure: 500,
};

const retryableCodes: ReadonlySet<AgentErrorCode> = new Set([
  "rate_limited",
  "upstream_rate_limited",
  "unexpected_failure",
]);

export class AgentError extends Error {
  readonly retryable: boolean;

  constructor(
    readonly code: AgentErrorCode,
    readonly detail?: string,
    retryable?: boolean,
  ) {
    super(code);
    this.retryable = retryable ?? retryableCodes.has(code);
  }

  get status(): number {
    return statusByCode[this.code];
  }
}
