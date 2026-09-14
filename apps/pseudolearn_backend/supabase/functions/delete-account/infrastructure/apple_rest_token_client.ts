import type { AppleCodeExchange, AppleTokenClient, RevocableToken } from "../domain/ports.ts";
import { appleAudience } from "./apple_client_secret";
import type { Fetcher } from "./fetcher.ts";
import { remoteRequestTimeoutMilliseconds } from "./fetcher";
import { decodeJwtPayload, isRecord } from "./jwt_payload";

export const appleTokenUrl = `${appleAudience}/auth/token`;
export const appleRevokeUrl = `${appleAudience}/auth/revoke`;

export interface AppleRestTokenClientOptions {
  readonly clientId: string;
  readonly fetcher: Fetcher;
  readonly clientSecret: () => Promise<string>;
}

const failedExchange: AppleCodeExchange = { kind: "failed" };

export class AppleRestTokenClient implements AppleTokenClient {
  constructor(private readonly options: AppleRestTokenClientOptions) {}

  async exchange(authorizationCode: string): Promise<AppleCodeExchange> {
    const response = await this.post(appleTokenUrl, {
      code: authorizationCode,
      grant_type: "authorization_code",
    });
    if (response === null || !response.ok) return failedExchange;
    return exchangeFrom(await readJson(response), this.options.clientId);
  }

  async revoke(token: RevocableToken): Promise<boolean> {
    const response = await this.post(appleRevokeUrl, {
      token: token.value,
      token_type_hint: token.hint,
    });
    return response !== null && response.status === 200;
  }

  private async post(url: string, fields: Record<string, string>): Promise<Response | null> {
    try {
      const body = new URLSearchParams({
        ...fields,
        client_id: this.options.clientId,
        client_secret: await this.options.clientSecret(),
      });
      return await this.options.fetcher(url, {
        method: "POST",
        headers: { "content-type": "application/x-www-form-urlencoded" },
        body,
        signal: AbortSignal.timeout(remoteRequestTimeoutMilliseconds),
      });
    } catch {
      return null;
    }
  }
}

function exchangeFrom(body: unknown, clientId: string): AppleCodeExchange {
  if (!isRecord(body) || typeof body.id_token !== "string") return failedExchange;
  const claims = decodeJwtPayload(body.id_token);
  if (claims === null || typeof claims.sub !== "string" || claims.aud !== clientId) {
    return failedExchange;
  }
  const token = revocableTokenFrom(body);
  return token === null ? failedExchange : { kind: "exchanged", subject: claims.sub, token };
}

function revocableTokenFrom(body: Record<string, unknown>): RevocableToken | null {
  if (typeof body.refresh_token === "string" && body.refresh_token.length > 0) {
    return { value: body.refresh_token, hint: "refresh_token" };
  }
  if (typeof body.access_token === "string" && body.access_token.length > 0) {
    return { value: body.access_token, hint: "access_token" };
  }
  return null;
}

async function readJson(response: Response): Promise<unknown> {
  try {
    return await response.json();
  } catch {
    return null;
  }
}
