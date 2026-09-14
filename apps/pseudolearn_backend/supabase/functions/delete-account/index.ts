import type { DeleteAccountDependencies } from "./application/delete_account.ts";
import type { DeletionOutcome } from "./domain/deletion_outcome.ts";
import { createDeleteAccountHandler } from "./http/delete_account_handler";
import { createAppleClientSecret } from "./infrastructure/apple_client_secret";
import { AppleRestTokenClient } from "./infrastructure/apple_rest_token_client";
import {
  type AppleConfiguration,
  type FunctionEnvironment,
  readFunctionEnvironment,
} from "./infrastructure/environment";
import type { Fetcher } from "./infrastructure/fetcher.ts";
import { SupabaseUserDeleter } from "./infrastructure/supabase_user_deleter";
import { SupabaseUserVerifier } from "./infrastructure/supabase_user_verifier";

const fetcher: Fetcher = (url, init) => fetch(url, init);

function buildAppleTokenClient(apple: AppleConfiguration): AppleRestTokenClient {
  return new AppleRestTokenClient({
    clientId: apple.clientId,
    fetcher,
    clientSecret: () => createAppleClientSecret(apple, Math.floor(Date.now() / 1000)),
  });
}

function buildDependencies(environment: FunctionEnvironment): DeleteAccountDependencies {
  const endpoint = { ...environment, fetcher };
  return {
    userVerifier: new SupabaseUserVerifier(endpoint),
    appleTokenClient: environment.apple && buildAppleTokenClient(environment.apple),
    userDeleter: new SupabaseUserDeleter(endpoint),
  };
}

function recordOutcome(outcome: DeletionOutcome): void {
  const code = outcome.kind === "deleted" ? "deleted" : outcome.code;
  console.log(JSON.stringify({ event: "delete_account", outcome: code }));
}

const environment = readFunctionEnvironment((name) => Deno.env.get(name));

Deno.serve(
  createDeleteAccountHandler(environment && buildDependencies(environment), recordOutcome),
);
