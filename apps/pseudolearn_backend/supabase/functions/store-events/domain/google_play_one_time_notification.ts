import {
  type GooglePlayCatalog,
  googlePlayOneTimeOf,
} from "../../agent-credits/domain/google_play_purchase.ts";
import { googlePlayRevocationOf } from "./google_play_revocation.ts";
import { ignored, type StoreEvent } from "./store_event.ts";

export interface GooglePlayOneTimeNotice {
  readonly kind: "one_time";
  readonly token: string;
  readonly productId: string;
  readonly cancelled: boolean;
}

type Fields = Record<string, unknown>;

const oneTimeProductPurchased = 1;
const oneTimeProductCanceled = 2;
const cancelledPurchaseState = 1;

export function oneTimeNoticeOf(
  notification: Fields,
): GooglePlayOneTimeNotice | { readonly kind: "ignored"; readonly reason: string } {
  const token = textOf(notification.purchaseToken);
  const productId = textOf(notification.sku);
  if (token === null || productId === null) {
    return { kind: "ignored", reason: "one_time_incomplete" };
  }
  const type = notification.notificationType;
  if (type !== oneTimeProductPurchased && type !== oneTimeProductCanceled) {
    return { kind: "ignored", reason: "one_time_unknown_type" };
  }
  return { kind: "one_time", token, productId, cancelled: type === oneTimeProductCanceled };
}

export function googlePlayOneTimeEventOf(
  notice: GooglePlayOneTimeNotice,
  purchase: Fields | null,
  catalog: GooglePlayCatalog,
): StoreEvent {
  if (purchase === null) return ignored("unknown_purchase");
  if (notice.cancelled) return cancellationOf(notice.token, purchase);
  const verified = googlePlayOneTimeOf(notice.token, notice.productId, purchase, catalog);
  if (verified === null) return ignored("one_time_not_granted");
  return { kind: "purchase", purchase: verified, userHint: verified.accountToken };
}

function cancellationOf(token: string, purchase: Fields): StoreEvent {
  if (purchase.purchaseState !== cancelledPurchaseState) return ignored("one_time_not_cancelled");
  return googlePlayRevocationOf(token, false);
}

function textOf(value: unknown): string | null {
  return typeof value === "string" && value.length > 0 ? value : null;
}
