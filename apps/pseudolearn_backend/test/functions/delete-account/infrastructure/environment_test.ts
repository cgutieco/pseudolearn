import { assertEquals } from "@std/assert";
import { readFunctionEnvironment } from "../../../../supabase/functions/delete-account/infrastructure/environment.ts";

const complete: Record<string, string> = {
  SUPABASE_URL: "https://project.supabase.co/",
  SUPABASE_SECRET_KEYS: JSON.stringify({ default: "sb_secret_default", other: "sb_secret_other" }),
  APPLE_TEAM_ID: "TEAM",
  APPLE_KEY_ID: "KEY",
  APPLE_CLIENT_ID: "com.pseudolearn.app",
  APPLE_PRIVATE_KEY: "PEM",
};

function reader(values: Record<string, string>) {
  return (name: string) => values[name];
}

Deno.test("reads Supabase and Apple configuration, trimming the URL", () => {
  assertEquals(readFunctionEnvironment(reader(complete)), {
    supabaseUrl: "https://project.supabase.co",
    secretKey: "sb_secret_default",
    apple: { teamId: "TEAM", keyId: "KEY", clientId: "com.pseudolearn.app", privateKeyPem: "PEM" },
  });
});

Deno.test("Apple configuration is null when any Apple secret is missing or blank", () => {
  for (const name of ["APPLE_TEAM_ID", "APPLE_KEY_ID", "APPLE_CLIENT_ID", "APPLE_PRIVATE_KEY"]) {
    const environment = readFunctionEnvironment(reader({ ...complete, [name]: " " }));
    assertEquals(environment?.apple, null);
  }
});

Deno.test("environment is null without URL or a usable default secret key", () => {
  const broken = [
    { ...complete, SUPABASE_URL: "" },
    { ...complete, SUPABASE_SECRET_KEYS: "not json" },
    { ...complete, SUPABASE_SECRET_KEYS: JSON.stringify({ other: "sb_secret" }) },
    { ...complete, SUPABASE_SECRET_KEYS: JSON.stringify(["sb_secret"]) },
  ];
  for (const values of broken) {
    assertEquals(readFunctionEnvironment(reader(values)), null);
  }
  const { SUPABASE_SECRET_KEYS: _omitted, ...withoutKeys } = complete;
  assertEquals(readFunctionEnvironment(reader(withoutKeys)), null);
});
