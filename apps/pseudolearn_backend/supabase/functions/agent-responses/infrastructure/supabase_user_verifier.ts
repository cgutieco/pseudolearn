import { isRecord } from "../domain/credits.ts";
import type { UserVerifier } from "../domain/ports.ts";
import { type Fetcher, supabaseTimeoutMilliseconds } from "./fetcher.ts";

export interface SupabaseEndpoint {
  readonly supabaseUrl: string;
  readonly secretKey: string;
  readonly fetcher: Fetcher;
}

export class SupabaseUserVerifier implements UserVerifier {
  constructor(private readonly endpoint: SupabaseEndpoint) {}

  async verify(accessToken: string): Promise<string | null> {
    const response = await this.endpoint.fetcher(`${this.endpoint.supabaseUrl}/auth/v1/user`, {
      method: "GET",
      headers: { apikey: this.endpoint.secretKey, authorization: `Bearer ${accessToken}` },
      signal: AbortSignal.timeout(supabaseTimeoutMilliseconds),
    });
    if (response.status !== 200) return null;
    const body: unknown = await response.json();
    return isRecord(body) && typeof body.id === "string" && body.id.length > 0 ? body.id : null;
  }
}
