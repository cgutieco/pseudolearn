import { AgentError } from "../../agent-responses/domain/agent_error.ts";
import { isRecord } from "../../agent-responses/domain/credits.ts";
import {
  type Fetcher,
  supabaseTimeoutMilliseconds,
} from "../../agent-responses/infrastructure/fetcher.ts";
import type { CheckoutGateway, CheckoutPrice } from "../domain/checkout.ts";
import type { PaddleSettings } from "./store_environment.ts";

export class PaddleCheckoutGateway implements CheckoutGateway {
  constructor(
    private readonly settings: PaddleSettings,
    private readonly fetcher: Fetcher,
  ) {}

  async open(userId: string, price: CheckoutPrice): Promise<string> {
    const reply = await this.post("/transactions", {
      items: [{ price_id: this.settings.prices[price], quantity: 1 }],
      custom_data: { user_id: userId },
      collection_mode: "automatic",
    });
    const checkout = isRecord(reply) && isRecord(reply.checkout) ? reply.checkout : {};
    return urlOf(checkout.url);
  }

  async portal(customerId: string): Promise<string> {
    const reply = await this.post(
      `/customers/${encodeURIComponent(customerId)}/portal-sessions`,
      {},
    );
    const urls = isRecord(reply) && isRecord(reply.urls) ? reply.urls : {};
    const general = isRecord(urls.general) ? urls.general : {};
    return urlOf(general.overview);
  }

  private async post(path: string, body: Record<string, unknown>): Promise<unknown> {
    const response = await this.fetcher(`${this.settings.apiBase}${path}`, {
      method: "POST",
      headers: {
        authorization: `Bearer ${this.settings.apiKey}`,
        "content-type": "application/json",
      },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(supabaseTimeoutMilliseconds),
    });
    if (response.status < 200 || response.status >= 300) {
      throw new AgentError("upstream_error", `paddle ${response.status}`);
    }
    const reply: unknown = await response.json();
    return isRecord(reply) ? reply.data : null;
  }
}

function urlOf(value: unknown): string {
  if (typeof value !== "string" || !value.startsWith("https://")) {
    throw new AgentError("upstream_error", "paddle url");
  }
  return value;
}
