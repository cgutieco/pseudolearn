import { AgentError } from "../../agent-responses/domain/agent_error.ts";
import { isRecord } from "../../agent-responses/domain/credits.ts";
import type { AppStoreCatalog } from "../../agent-credits/domain/app_store_transaction.ts";
import type { AppleSignedDataVerifier } from "../../agent-credits/infrastructure/apple_signed_data_verifier.ts";
import { SignedDataError } from "../../agent-credits/infrastructure/der_reader.ts";
import { appStoreEventOf } from "../domain/app_store_notification.ts";
import type { StoreEvent, StoreEventReader } from "../domain/store_event.ts";

export class AppStoreNotificationReader implements StoreEventReader {
  constructor(
    private readonly signedData: AppleSignedDataVerifier,
    private readonly catalog: AppStoreCatalog,
  ) {}

  async read(body: string): Promise<readonly StoreEvent[]> {
    const notification = await this.verified(signedPayloadOf(body));
    const data = isRecord(notification.data) ? notification.data : {};
    const signedTransaction = data.signedTransactionInfo;
    const transaction = typeof signedTransaction === "string"
      ? await this.verified(signedTransaction)
      : null;
    return [appStoreEventOf(transaction, this.catalog)];
  }

  private async verified(jws: string): Promise<Record<string, unknown>> {
    try {
      return await this.signedData.payloadOf(jws);
    } catch (error) {
      if (error instanceof SignedDataError) throw new AgentError("invalid_signature");
      throw error;
    }
  }
}

function signedPayloadOf(body: string): string {
  try {
    const parsed: unknown = JSON.parse(body);
    if (isRecord(parsed) && typeof parsed.signedPayload === "string") return parsed.signedPayload;
  } catch {
    throw new AgentError("invalid_request", "json");
  }
  throw new AgentError("invalid_request", "signedPayload");
}
