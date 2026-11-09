import { AgentError } from "../../agent-responses/domain/agent_error.ts";
import { type AppStoreCatalog, appStorePurchaseOf } from "../domain/app_store_transaction.ts";
import {
  productOf,
  type PurchaseClaim,
  type PurchaseVerifier,
  type VerifiedPurchase,
} from "../domain/purchase.ts";
import type { AppleSignedDataVerifier } from "./apple_signed_data_verifier.ts";
import { SignedDataError } from "./der_reader.ts";

export const appStoreName = "app_store";

export class AppStorePurchaseVerifier implements PurchaseVerifier {
  constructor(
    private readonly signedData: AppleSignedDataVerifier,
    private readonly catalog: AppStoreCatalog,
  ) {}

  async verify(claim: PurchaseClaim): Promise<VerifiedPurchase | null> {
    if (claim.store !== appStoreName || claim.evidence.length === 0) return null;
    const purchase = appStorePurchaseOf(await this.payloadOf(claim.evidence), this.catalog);
    if (purchase === null) return null;
    if (purchase.product !== productOf(claim.productId)) return null;
    return purchase;
  }

  private async payloadOf(jws: string): Promise<Record<string, unknown>> {
    try {
      return await this.signedData.payloadOf(jws);
    } catch (error) {
      if (error instanceof SignedDataError) throw new AgentError("invalid_signature");
      throw error;
    }
  }
}
