import { readAgentEnvironment } from "../agent-responses/infrastructure/environment.ts";
import type { Fetcher } from "../agent-responses/infrastructure/fetcher.ts";
import { AppleSignedDataVerifier } from "../agent-credits/infrastructure/apple_signed_data_verifier.ts";
import { PostgresStoreLedger } from "../agent-credits/infrastructure/postgres_store_ledger.ts";
import {
  readStoreEnvironment,
  type StoreEnvironment,
} from "../agent-credits/infrastructure/store_environment.ts";
import type { StoreEventsDependencies } from "./application/store_events_service.ts";
import { createStoreEventsHandler, type StoreRoute } from "./http/store_events_handler.ts";
import { AppStoreNotificationReader } from "./infrastructure/app_store_notification_reader.ts";
import { PaddleWebhookReader } from "./infrastructure/paddle_webhook_reader.ts";

const fetcher: Fetcher = (url, init) => fetch(url, init);
const readEnvironment = (name: string) => Deno.env.get(name);

function routesFor(stores: StoreEnvironment): Map<string, StoreRoute> {
  const routes = new Map<string, StoreRoute>();
  if (stores.appStore !== null) {
    routes.set("app-store", {
      reader: new AppStoreNotificationReader(new AppleSignedDataVerifier(), stores.appStore),
      signatureHeader: null,
    });
  }
  if (stores.paddle !== null) {
    const prices = stores.paddle.prices;
    routes.set("paddle", {
      reader: new PaddleWebhookReader(stores.paddle.webhookSecret, {
        monthly: new Set([prices.monthly, prices.monthly_trial]),
        topUp: prices.top_up,
      }),
      signatureHeader: "paddle-signature",
    });
  }
  return routes;
}

function dependenciesFor(): StoreEventsDependencies | null {
  const environment = readAgentEnvironment(readEnvironment);
  if (environment === null) return null;
  return {
    ledger: new PostgresStoreLedger({ ...environment, fetcher }),
    clock: { now: () => new Date() },
  };
}

const handler = createStoreEventsHandler(
  { routes: routesFor(readStoreEnvironment(readEnvironment)), dependencies: dependenciesFor() },
  (entry) => console.log(JSON.stringify(entry)),
);

Deno.serve(handler);
