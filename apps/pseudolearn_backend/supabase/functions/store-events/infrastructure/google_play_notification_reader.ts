import { AgentError } from "../../agent-responses/domain/agent_error.ts";
import { isRecord } from "../../agent-responses/domain/credits.ts";
import type {
  GooglePlayCatalog,
  GooglePlayPurchases,
} from "../../agent-credits/domain/google_play_purchase.ts";
import {
  googlePlayNoticeOf,
  googlePlayOneTimeEventOf,
  googlePlayRevocationOf,
  googlePlaySubscriptionEventOf,
} from "../domain/google_play_notification.ts";
import { ignored, type StoreEvent, type StoreEventReader } from "../domain/store_event.ts";

export interface PushAuthenticity {
  verify(authorization: string | null): Promise<void>;
}

export class GooglePlayNotificationReader implements StoreEventReader {
  constructor(
    private readonly authenticator: PushAuthenticity,
    private readonly publisher: GooglePlayPurchases,
    private readonly catalog: GooglePlayCatalog,
  ) {}

  async read(body: string, authorization: string | null): Promise<readonly StoreEvent[]> {
    await this.authenticator.verify(authorization);
    const notice = googlePlayNoticeOf(notificationOf(body), this.catalog.packageName);
    switch (notice.kind) {
      case "ignored":
        return [ignored(notice.reason)];
      case "subscription_revoked":
        return [googlePlayRevocationOf(notice.token, true)];
      case "voided":
        return [googlePlayRevocationOf(notice.token, notice.subscription)];
      case "subscription": {
        const subscription = await this.publisher.subscription(notice.token);
        return [googlePlaySubscriptionEventOf(notice.token, subscription, this.catalog)];
      }
      case "one_time": {
        const purchase = await this.publisher.oneTimeProduct(notice.productId, notice.token);
        return [googlePlayOneTimeEventOf(notice, purchase, this.catalog)];
      }
    }
  }
}

function notificationOf(body: string): unknown {
  try {
    const envelope: unknown = JSON.parse(body);
    const message = isRecord(envelope) && isRecord(envelope.message) ? envelope.message : {};
    if (typeof message.data !== "string") throw new AgentError("invalid_request", "message");
    const bytes = Uint8Array.from(atob(message.data), (character) => character.charCodeAt(0));
    return JSON.parse(new TextDecoder().decode(bytes));
  } catch (error) {
    if (error instanceof AgentError) throw error;
    throw new AgentError("invalid_request", "json");
  }
}
