import { AgentError } from "../../agent-responses/domain/agent_error.ts";
import { isRecord } from "../../agent-responses/domain/credits.ts";
import type { Fetcher } from "../../agent-responses/infrastructure/fetcher.ts";
import type { GooglePlayPurchases } from "../domain/google_play_purchase.ts";
import type { GoogleAccessTokens } from "./google_service_account.ts";

export const androidPublisherBase =
  "https://androidpublisher.googleapis.com/androidpublisher/v3/applications";

const unknownPurchaseStatuses: ReadonlySet<number> = new Set([400, 404, 410]);

export class GooglePlayPublisher implements GooglePlayPurchases {
  constructor(
    private readonly packageName: string,
    private readonly tokens: GoogleAccessTokens,
    private readonly fetcher: Fetcher,
  ) {}

  subscription(purchaseToken: string): Promise<Record<string, unknown> | null> {
    return this.read(`purchases/subscriptionsv2/tokens/${encodeURIComponent(purchaseToken)}`);
  }

  oneTimeProduct(
    productId: string,
    purchaseToken: string,
  ): Promise<Record<string, unknown> | null> {
    return this.read(
      `purchases/products/${encodeURIComponent(productId)}/tokens/${
        encodeURIComponent(purchaseToken)
      }`,
    );
  }

  private async read(path: string): Promise<Record<string, unknown> | null> {
    const url = `${androidPublisherBase}/${encodeURIComponent(this.packageName)}/${path}`;
    const response = await this.fetcher(url, {
      method: "GET",
      headers: { authorization: `Bearer ${await this.tokens.token()}` },
    });
    if (unknownPurchaseStatuses.has(response.status)) return null;
    if (!response.ok) throw new AgentError("upstream_error", "google_play");
    const body: unknown = await response.json();
    return isRecord(body) ? body : null;
  }
}
