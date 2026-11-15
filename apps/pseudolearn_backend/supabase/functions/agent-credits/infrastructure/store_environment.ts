import type { AppStoreCatalog } from "../domain/app_store_transaction.ts";
import type { CheckoutPrice } from "../domain/checkout.ts";

export interface PaddleSettings {
  readonly apiBase: string;
  readonly apiKey: string;
  readonly webhookSecret: string;
  readonly prices: Readonly<Record<CheckoutPrice, string>>;
}

export interface StoreEnvironment {
  readonly appStore: AppStoreCatalog | null;
  readonly paddle: PaddleSettings | null;
}

export type EnvironmentReader = (name: string) => string | undefined;

const paddleApiBases: Readonly<Record<string, string>> = {
  production: "https://api.paddle.com",
  sandbox: "https://sandbox-api.paddle.com",
};

export function readStoreEnvironment(read: EnvironmentReader): StoreEnvironment {
  return { appStore: appStoreOf(read), paddle: paddleOf(read) };
}

function appStoreOf(read: EnvironmentReader): AppStoreCatalog | null {
  const bundleId = nonEmpty(read("APPLE_BUNDLE_ID"));
  if (bundleId === null) return null;
  const listed = (read("APP_STORE_ENVIRONMENTS") ?? "Production").split(",");
  const environments = new Set(listed.map((entry) => entry.trim()).filter(Boolean));
  return { bundleId, environments };
}

function paddleOf(read: EnvironmentReader): PaddleSettings | null {
  const apiBase = paddleApiBases[read("PADDLE_ENVIRONMENT")?.trim() ?? "production"];
  const values = [
    "PADDLE_API_KEY",
    "PADDLE_WEBHOOK_SECRET",
    "PADDLE_PRICE_MONTHLY",
    "PADDLE_PRICE_MONTHLY_TRIAL",
    "PADDLE_PRICE_TOP_UP",
  ].map((name) => nonEmpty(read(name)));
  const [apiKey, webhookSecret, monthly, monthlyTrial, topUp] = values;
  if (apiBase === undefined || values.some((value) => value === null)) return null;
  return {
    apiBase,
    apiKey: apiKey as string,
    webhookSecret: webhookSecret as string,
    prices: {
      monthly: monthly as string,
      monthly_trial: monthlyTrial as string,
      top_up: topUp as string,
    },
  };
}

function nonEmpty(value: string | undefined): string | null {
  return value !== undefined && value.trim().length > 0 ? value.trim() : null;
}
