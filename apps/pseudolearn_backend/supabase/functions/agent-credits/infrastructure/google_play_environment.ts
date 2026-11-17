import type { GooglePlayCatalog } from "../domain/google_play_purchase.ts";
import { type GoogleServiceAccount, googleServiceAccountOf } from "./google_service_account.ts";

export interface GooglePlayPushSettings {
  readonly audience: string;
  readonly serviceAccountEmail: string;
}

export interface GooglePlaySettings {
  readonly catalog: GooglePlayCatalog;
  readonly serviceAccount: GoogleServiceAccount;
  readonly push: GooglePlayPushSettings | null;
}

export function readGooglePlayEnvironment(
  read: (name: string) => string | undefined,
): GooglePlaySettings | null {
  const packageName = nonEmpty(read("GOOGLE_PLAY_PACKAGE_NAME"));
  const serviceAccount = googleServiceAccountOf(read("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON") ?? "");
  if (packageName === null || serviceAccount === null) return null;
  const audience = nonEmpty(read("GOOGLE_PLAY_PUSH_AUDIENCE"));
  const serviceAccountEmail = nonEmpty(read("GOOGLE_PLAY_PUSH_SERVICE_ACCOUNT"));
  return {
    catalog: {
      packageName,
      acceptsTestPurchases: read("GOOGLE_PLAY_ACCEPT_TEST_PURCHASES")?.trim() === "true",
    },
    serviceAccount,
    push: audience === null || serviceAccountEmail === null
      ? null
      : { audience, serviceAccountEmail },
  };
}

function nonEmpty(value: string | undefined): string | null {
  return value !== undefined && value.trim().length > 0 ? value.trim() : null;
}
