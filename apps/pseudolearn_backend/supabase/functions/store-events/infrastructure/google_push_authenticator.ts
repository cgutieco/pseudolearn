import { AgentError } from "../../agent-responses/domain/agent_error.ts";
import { isRecord } from "../../agent-responses/domain/credits.ts";
import type { Fetcher } from "../../agent-responses/infrastructure/fetcher.ts";
import type { GooglePlayPushSettings } from "../../agent-credits/infrastructure/google_play_environment.ts";
import {
  decodeBase64UrlBytes,
  decodeBase64UrlText,
} from "../../delete-account/infrastructure/base64url.ts";

import type { PushAuthenticity } from "./google_play_notification_reader.ts";

export const googleSigningKeysUrl = "https://www.googleapis.com/oauth2/v3/certs";

const googleIssuers: ReadonlySet<string> = new Set([
  "https://accounts.google.com",
  "accounts.google.com",
]);
const clockSkewSeconds = 300;
const millisecondsPerSecond = 1_000;
const signature = { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" };

type Claims = Record<string, unknown>;

export class GooglePushAuthenticator implements PushAuthenticity {
  private keys = new Map<string, CryptoKey>();

  constructor(
    private readonly settings: GooglePlayPushSettings,
    private readonly fetcher: Fetcher,
    private readonly now: () => number = Date.now,
  ) {}

  async verify(authorization: string | null): Promise<void> {
    const [header, payload, signed] = bearerOf(authorization).split(".");
    const parsedHeader = jsonOf(header);
    const claims = jsonOf(payload);
    const signatureBytes = decodeBase64UrlBytes(signed ?? "");
    if (parsedHeader?.alg !== "RS256" || typeof parsedHeader.kid !== "string") reject();
    if (claims === null || signatureBytes === null || !this.accepts(claims)) reject();
    const key = await this.keyFor(parsedHeader.kid as string);
    const valid = await crypto.subtle.verify(
      signature,
      key,
      signatureBytes as Uint8Array<ArrayBuffer>,
      new TextEncoder().encode(`${header}.${payload}`),
    );
    if (!valid) reject();
  }

  private accepts(claims: Claims): boolean {
    const nowSeconds = this.now() / millisecondsPerSecond;
    return googleIssuers.has(String(claims.iss)) &&
      claims.aud === this.settings.audience &&
      claims.email === this.settings.serviceAccountEmail &&
      claims.email_verified === true &&
      typeof claims.exp === "number" && claims.exp + clockSkewSeconds > nowSeconds &&
      typeof claims.iat === "number" && claims.iat - clockSkewSeconds < nowSeconds;
  }

  private async keyFor(kid: string): Promise<CryptoKey> {
    if (!this.keys.has(kid)) this.keys = await this.signingKeys();
    const key = this.keys.get(kid);
    return key ?? reject();
  }

  private async signingKeys(): Promise<Map<string, CryptoKey>> {
    const response = await this.fetcher(googleSigningKeysUrl, { method: "GET" });
    if (!response.ok) throw new AgentError("upstream_error", "google_keys");
    const body: unknown = await response.json();
    const listed = isRecord(body) && Array.isArray(body.keys) ? body.keys : [];
    const keys = new Map<string, CryptoKey>();
    for (const jwk of listed) {
      if (!isRecord(jwk) || typeof jwk.kid !== "string" || jwk.kty !== "RSA") continue;
      keys.set(jwk.kid, await crypto.subtle.importKey("jwk", jwk, signature, false, ["verify"]));
    }
    return keys;
  }
}

function bearerOf(authorization: string | null): string {
  const match = /^Bearer\s+(\S+)$/i.exec(authorization ?? "");
  return match?.[1] ?? reject();
}

function jsonOf(segment: string | undefined): Claims | null {
  const text = decodeBase64UrlText(segment ?? "");
  if (text === null) return null;
  try {
    const parsed: unknown = JSON.parse(text);
    return isRecord(parsed) ? parsed : null;
  } catch {
    return null;
  }
}

function reject(): never {
  throw new AgentError("invalid_signature");
}
