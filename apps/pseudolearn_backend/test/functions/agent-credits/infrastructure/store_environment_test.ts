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
  assertEquals(read({}), { appStore: null, googlePlay: null, paddle: null });
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

const googlePlay = {
  GOOGLE_PLAY_PACKAGE_NAME: " com.pseudolearn.app ",
  GOOGLE_PLAY_SERVICE_ACCOUNT_JSON: JSON.stringify({ client_email: "a@b", private_key: "pem" }),
};

Deno.test("Google Play needs its package and a service account, and refuses test purchases by default", () => {
  assertEquals(read(googlePlay).googlePlay, {
    catalog: { packageName: "com.pseudolearn.app", acceptsTestPurchases: false },
    serviceAccount: { clientEmail: "a@b", privateKeyPem: "pem" },
    push: null,
  });
  assertEquals(read({ ...googlePlay, GOOGLE_PLAY_PACKAGE_NAME: " " }).googlePlay, null);
  assertEquals(read({ ...googlePlay, GOOGLE_PLAY_SERVICE_ACCOUNT_JSON: "{" }).googlePlay, null);
});

Deno.test("Google Play accepts test purchases only when told exactly", () => {
  const accepted = read({ ...googlePlay, GOOGLE_PLAY_ACCEPT_TEST_PURCHASES: " true " });
  assertEquals(accepted.googlePlay?.catalog.acceptsTestPurchases, true);
  const other = read({ ...googlePlay, GOOGLE_PLAY_ACCEPT_TEST_PURCHASES: "yes" });
  assertEquals(other.googlePlay?.catalog.acceptsTestPurchases, false);
});

Deno.test("Google Play notifications need both the push audience and the push account", () => {
  const push = {
    ...googlePlay,
    GOOGLE_PLAY_PUSH_AUDIENCE: "https://x.supabase.co/functions/v1/store-events/google-play",
    GOOGLE_PLAY_PUSH_SERVICE_ACCOUNT: "rtdn@pseudolearn.iam.gserviceaccount.com",
  };
  assertEquals(read(push).googlePlay?.push, {
    audience: "https://x.supabase.co/functions/v1/store-events/google-play",
    serviceAccountEmail: "rtdn@pseudolearn.iam.gserviceaccount.com",
  });
  assertEquals(read({ ...push, GOOGLE_PLAY_PUSH_SERVICE_ACCOUNT: "" }).googlePlay?.push, null);
});
