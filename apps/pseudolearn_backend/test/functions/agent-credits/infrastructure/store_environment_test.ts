import { assertEquals } from "@std/assert";
import { readStoreEnvironment } from "../../../../supabase/functions/agent-credits/infrastructure/store_environment.ts";

const paddle = {
  PADDLE_API_KEY: "key",
  PADDLE_WEBHOOK_SECRET: "secret",
  PADDLE_PRICE_MONTHLY: "pri_m",
  PADDLE_PRICE_MONTHLY_TRIAL: "pri_mt",
  PADDLE_PRICE_TOP_UP: "pri_t",
};

function read(values: Record<string, string>) {
  return readStoreEnvironment((name) => values[name]);
}

Deno.test("nothing configured means no store", () => {
  assertEquals(read({}), { appStore: null, paddle: null });
});

Deno.test("the App Store defaults to production and accepts a list", () => {
  assertEquals(
    read({ APPLE_BUNDLE_ID: "com.pseudolearn.app" }).appStore?.environments,
    new Set(["Production"]),
  );
  const listed = read({ APPLE_BUNDLE_ID: "b", APP_STORE_ENVIRONMENTS: " Production, Sandbox ,," });
  assertEquals(listed.appStore?.environments, new Set(["Production", "Sandbox"]));
});

Deno.test("Paddle needs every value and picks its API by environment", () => {
  assertEquals(read(paddle).paddle?.apiBase, "https://api.paddle.com");
  assertEquals(
    read({ ...paddle, PADDLE_ENVIRONMENT: "sandbox" }).paddle?.apiBase,
    "https://sandbox-api.paddle.com",
  );
  assertEquals(read(paddle).paddle?.prices, {
    monthly: "pri_m",
    monthly_trial: "pri_mt",
    top_up: "pri_t",
  });
  assertEquals(read({ ...paddle, PADDLE_PRICE_TOP_UP: " " }).paddle, null);
  assertEquals(read({ ...paddle, PADDLE_ENVIRONMENT: "staging" }).paddle, null);
});
