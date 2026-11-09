import { AgentError } from "../domain/agent_error.ts";
import { supabaseTimeoutMilliseconds } from "./fetcher.ts";
import type { SupabaseEndpoint } from "./supabase_user_verifier.ts";

export async function callRpc(
  endpoint: SupabaseEndpoint,
  name: string,
  body: Record<string, unknown>,
): Promise<unknown> {
  const response = await endpoint.fetcher(`${endpoint.supabaseUrl}/rest/v1/rpc/${name}`, {
    method: "POST",
    headers: {
      apikey: endpoint.secretKey,
      authorization: `Bearer ${endpoint.secretKey}`,
      "content-type": "application/json",
    },
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(supabaseTimeoutMilliseconds),
  });
  if (response.status < 200 || response.status >= 300) {
    throw new AgentError("unexpected_failure", `ledger ${response.status}`);
  }
  return await response.json();
}
