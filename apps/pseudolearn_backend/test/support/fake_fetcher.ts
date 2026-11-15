import type { Fetcher } from "../../supabase/functions/delete-account/infrastructure/fetcher.ts";

export interface RecordedFetch {
  readonly url: string;
  readonly method: string;
  readonly headers: Headers;
  readonly body: string;
}

export type FetchResponder = (request: RecordedFetch) => Response | Promise<Response>;

export class FakeFetcher {
  readonly requests: RecordedFetch[] = [];

  constructor(public responder: FetchResponder) {}

  readonly fetch: Fetcher = async (url, init) => {
    const recorded = {
      url,
      method: init.method ?? "GET",
      headers: new Headers(init.headers),
      body: init.body === undefined || init.body === null ? "" : String(init.body),
    };
    this.requests.push(recorded);
    return await this.responder(recorded);
  };
}

export function unsignedJwt(claims: Record<string, unknown>): string {
  const encode = (value: unknown) =>
    btoa(JSON.stringify(value)).replaceAll("+", "-").replaceAll("/", "_").replaceAll("=", "");
  return `${encode({ alg: "RS256" })}.${encode(claims)}.signature`;
}
