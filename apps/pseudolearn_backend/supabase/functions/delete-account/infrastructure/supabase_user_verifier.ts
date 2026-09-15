import type { AccountUser } from "../domain/account_user.ts";
import type { UserVerifier } from "../domain/ports.ts";
import type { Fetcher } from "./fetcher.ts";
import { remoteRequestTimeoutMilliseconds } from "./fetcher.ts";
import { isRecord } from "./jwt_payload.ts";

export interface SupabaseAuthEndpoint {
  readonly supabaseUrl: string;
  readonly secretKey: string;
  readonly fetcher: Fetcher;
}

export class SupabaseUserVerifier implements UserVerifier {
  constructor(private readonly endpoint: SupabaseAuthEndpoint) {}

  async verify(accessToken: string): Promise<AccountUser | null> {
    const response = await this.endpoint.fetcher(`${this.endpoint.supabaseUrl}/auth/v1/user`, {
      method: "GET",
      headers: { apikey: this.endpoint.secretKey, authorization: `Bearer ${accessToken}` },
      signal: AbortSignal.timeout(remoteRequestTimeoutMilliseconds),
    });
    if (response.status !== 200) return null;
    return accountUserFrom(await response.json());
  }
}

export function accountUserFrom(body: unknown): AccountUser | null {
  if (!isRecord(body) || typeof body.id !== "string" || body.id.length === 0) return null;
  return { id: body.id, appleSubject: appleSubjectFrom(body.identities) };
}

function appleSubjectFrom(identities: unknown): string | null {
  if (!Array.isArray(identities)) return null;
  for (const identity of identities) {
    if (!isRecord(identity) || identity.provider !== "apple") continue;
    const data = isRecord(identity.identity_data) ? identity.identity_data : {};
    const subject = typeof data.sub === "string" ? data.sub : identity.provider_id ?? identity.id;
    if (typeof subject === "string" && subject.length > 0) return subject;
  }
  return null;
}
