import type { CreditsDependencies } from "./application/credits_service.ts";
import { createCreditsHandler, type CreditsSetup } from "./http/credits_handler.ts";
import { AllowlistedPurchaseVerifier } from "./infrastructure/allowlisted_purchase_verifier.ts";
import { AppleSignedDataVerifier } from "./infrastructure/apple_signed_data_verifier.ts";
import {
  appStoreName,
  AppStorePurchaseVerifier,
} from "./infrastructure/app_store_purchase_verifier.ts";
import { PaddleCheckoutGateway } from "./infrastructure/paddle_checkout_gateway.ts";
import { PostgresStoreLedger } from "./infrastructure/postgres_store_ledger.ts";
import {
  SimulatedPurchaseVerifier,
  simulatedStore,
} from "./infrastructure/simulated_purchase_verifier.ts";
import { readStoreEnvironment, type StoreEnvironment } from "./infrastructure/store_environment.ts";
import { StoreRoutedPurchaseVerifier } from "./infrastructure/store_routed_purchase_verifier.ts";
import type { PurchaseVerifier } from "./domain/purchase.ts";
import {
  type AgentEnvironment,
  readAgentEnvironment,
} from "../agent-responses/infrastructure/environment.ts";
import type { Fetcher } from "../agent-responses/infrastructure/fetcher.ts";
import { SupabaseUserVerifier } from "../agent-responses/infrastructure/supabase_user_verifier.ts";

const fetcher: Fetcher = (url, init) => fetch(url, init);
const readEnvironment = (name: string) => Deno.env.get(name);

function simulatedFor(environment: AgentEnvironment): PurchaseVerifier | null {
  const simulated = new SimulatedPurchaseVerifier();
  if (environment.purchases === "simulated") return simulated;
  if (environment.simulatedPurchaseUsers.size === 0) return null;
  return new AllowlistedPurchaseVerifier(simulated, environment.simulatedPurchaseUsers);
}

function purchasesFor(environment: AgentEnvironment, stores: StoreEnvironment): PurchaseVerifier {
  const simulated = simulatedFor(environment);
  const verifiers = new Map<string, PurchaseVerifier>();
  if (simulated !== null) verifiers.set(simulatedStore, simulated);
  if (stores.appStore !== null) {
    verifiers.set(
      appStoreName,
      new AppStorePurchaseVerifier(new AppleSignedDataVerifier(), stores.appStore),
    );
  }
  return new StoreRoutedPurchaseVerifier(verifiers);
}

function buildDependencies(environment: AgentEnvironment): CreditsDependencies {
  const endpoint = { ...environment, fetcher };
  const stores = readStoreEnvironment(readEnvironment);
  return {
    users: new SupabaseUserVerifier(endpoint),
    ledger: new PostgresStoreLedger(endpoint),
    purchases: purchasesFor(environment, stores),
    checkouts: stores.paddle === null ? null : new PaddleCheckoutGateway(stores.paddle, fetcher),
    clock: { now: () => new Date() },
  };
}

function setupFor(environment: AgentEnvironment | null): CreditsSetup {
  if (environment === null) return { kind: "unavailable", code: "misconfigured" };
  return { kind: "ready", dependencies: buildDependencies(environment) };
}

Deno.serve(createCreditsHandler(setupFor(readAgentEnvironment(readEnvironment))));
