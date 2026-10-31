export const NETWORK_CAPABILITIES: Readonly<Record<string, boolean | string>>;
export function declareFetchHost(session: { call(operation: string, argumentsJson: string): string }): unknown;
export function performFetch(effect: unknown, options?: {
  allowedOrigins?: string[];
  fetchImplementation?: typeof fetch;
  signal?: AbortSignal;
}): Promise<{ outcome: string; value: unknown }>;
