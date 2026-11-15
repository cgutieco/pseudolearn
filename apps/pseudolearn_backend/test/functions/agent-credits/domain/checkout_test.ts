import { assertEquals, assertThrows } from "@std/assert";
import { AgentError } from "../../../../supabase/functions/agent-responses/domain/agent_error.ts";
import { emptyBalance } from "../../../../supabase/functions/agent-responses/domain/balance.ts";
import { checkoutPriceFor } from "../../../../supabase/functions/agent-credits/domain/checkout.ts";

const active = { ...emptyBalance, periodActive: true };

function refusal(run: () => unknown): string {
  return assertThrows(run, AgentError).code;
}

Deno.test("a top-up needs an active period", () => {
  assertEquals(checkoutPriceFor("top_up", active), "top_up");
  assertEquals(refusal(() => checkoutPriceFor("top_up", emptyBalance)), "subscription_required");
});

Deno.test("the first plan carries the trial and later plans do not", () => {
  assertEquals(checkoutPriceFor("monthly", emptyBalance), "monthly_trial");
  assertEquals(checkoutPriceFor("monthly", { ...emptyBalance, trialUsed: true }), "monthly");
});

Deno.test("a second plan is refused while one is active", () => {
  assertEquals(refusal(() => checkoutPriceFor("monthly", active)), "already_subscribed");
});

Deno.test("the own trial product is not sold through checkout", () => {
  assertEquals(refusal(() => checkoutPriceFor("trial", emptyBalance)), "invalid_request");
});
