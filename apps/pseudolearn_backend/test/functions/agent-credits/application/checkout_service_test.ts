import { assertEquals, assertRejects } from "@std/assert";
import { AgentError } from "../../../../supabase/functions/agent-responses/domain/agent_error.ts";
import { emptyBalance } from "../../../../supabase/functions/agent-responses/domain/balance.ts";
import type { CreditsDependencies } from "../../../../supabase/functions/agent-credits/application/credits_service.ts";
import {
  openCustomerPortal,
  startCheckout,
} from "../../../../supabase/functions/agent-credits/application/checkout_service.ts";
import type {
  CheckoutGateway,
  CheckoutPrice,
} from "../../../../supabase/functions/agent-credits/domain/checkout.ts";
import { FakeLedger, FakeUsers } from "../../../support/agent_fakes.ts";

class FakeCheckouts implements CheckoutGateway {
  readonly opened: [string, CheckoutPrice][] = [];
  readonly portals: string[] = [];

  open(userId: string, price: CheckoutPrice): Promise<string> {
    this.opened.push([userId, price]);
    return Promise.resolve(`https://pay.test/${price}`);
  }

  portal(customerId: string): Promise<string> {
    this.portals.push(customerId);
    return Promise.resolve("https://portal.test");
  }
}

function setup(checkouts: CheckoutGateway | null = new FakeCheckouts()) {
  const ledger = new FakeLedger();
  const dependencies: CreditsDependencies = {
    users: new FakeUsers(),
    ledger,
    purchases: null,
    checkouts,
    clock: { now: () => new Date("2026-11-09T12:00:00Z") },
  };
  return { ledger, dependencies, checkouts };
}

Deno.test("a top-up checkout opens while the plan is active", async () => {
  const { dependencies, checkouts } = setup();
  assertEquals(
    await startCheckout("t", "pseudolearn.nodo.topup150", dependencies),
    "https://pay.test/top_up",
  );
  assertEquals((checkouts as FakeCheckouts).opened, [["user-1", "top_up"]]);
});

Deno.test("a first plan checkout carries the trial", async () => {
  const { ledger, dependencies } = setup();
  ledger.currentBalance = emptyBalance;
  assertEquals(
    await startCheckout("t", "pseudolearn.nodo.monthly", dependencies),
    "https://pay.test/monthly_trial",
  );
});

Deno.test("checkouts refuse unknown products, a second plan and a missing gateway", async () => {
  const { dependencies } = setup();
  const unknown = await assertRejects(() => startCheckout("t", "x", dependencies), AgentError);
  assertEquals(unknown.code, "invalid_request");
  const twice = await assertRejects(
    () => startCheckout("t", "pseudolearn.nodo.monthly", dependencies),
    AgentError,
  );
  assertEquals(twice.code, "already_subscribed");
  const disabled = await assertRejects(
    () => startCheckout("t", "pseudolearn.nodo.monthly", setup(null).dependencies),
    AgentError,
  );
  assertEquals(disabled.code, "purchases_disabled");
});

Deno.test("the portal opens for a known Paddle customer only", async () => {
  const { ledger, dependencies, checkouts } = setup();
  const missing = await assertRejects(() => openCustomerPortal("t", dependencies), AgentError);
  assertEquals(missing.code, "not_found");
  ledger.customers.set("paddle:user-1", "ctm_1");
  assertEquals(await openCustomerPortal("t", dependencies), "https://portal.test");
  assertEquals((checkouts as FakeCheckouts).portals, ["ctm_1"]);
});
