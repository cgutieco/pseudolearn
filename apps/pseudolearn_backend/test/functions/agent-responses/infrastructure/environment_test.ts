import { assertEquals } from "@std/assert";
import { readAgentEnvironment } from "../../../../supabase/functions/agent-responses/infrastructure/environment.ts";

const base: Record<string, string> = {
  SUPABASE_URL: "https://project.supabase.co/",
  SUPABASE_SECRET_KEYS: JSON.stringify({ default: "secret" }),
};

Deno.test("defaults: no key, the default model and purchases disabled", () => {
  const environment = readAgentEnvironment((name) => base[name]);
  assertEquals(environment?.openAiKey, null);
  assertEquals(environment?.model, "gpt-6-luna");
  assertEquals(environment?.purchases, "disabled");
  assertEquals(environment?.supabaseUrl, "https://project.supabase.co");
  assertEquals(environment?.simulatedPurchaseUsers.size, 0);
});

Deno.test("the simulated purchase allowlist is a trimmed comma separated list", () => {
  const read = (users: string) =>
    readAgentEnvironment((name) => ({ ...base, AGENT_SIMULATED_PURCHASE_USERS: users })[name])
      ?.simulatedPurchaseUsers;
  assertEquals([...read(" a , b,,c ") ?? []], ["a", "b", "c"]);
  assertEquals(read(" , ")?.size, 0);
  assertEquals(read("")?.size, 0);
});

Deno.test("only the exact value simulated enables simulated purchases", () => {
  const read = (purchases: string) =>
    readAgentEnvironment((name) => ({ ...base, AGENT_PURCHASES: purchases })[name])?.purchases;
  assertEquals(read("simulated"), "simulated");
  assertEquals(read("SIMULATED"), "disabled");
  assertEquals(read("true"), "disabled");
});

Deno.test("a missing project secret means no environment", () => {
  assertEquals(
    readAgentEnvironment((name) => ({ SUPABASE_URL: "x" } as Record<string, string>)[name]),
    null,
  );
  assertEquals(
    readAgentEnvironment((name) => ({ ...base, SUPABASE_SECRET_KEYS: "{" })[name]),
    null,
  );
});
