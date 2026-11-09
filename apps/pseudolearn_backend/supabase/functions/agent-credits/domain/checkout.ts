import { AgentError } from "../../agent-responses/domain/agent_error.ts";
import type { Balance } from "../../agent-responses/domain/balance.ts";
import type { Product } from "./purchase.ts";

export type CheckoutPrice = "monthly" | "monthly_trial" | "top_up";

export interface CheckoutGateway {
  open(userId: string, price: CheckoutPrice): Promise<string>;
  portal(customerId: string): Promise<string>;
}

export function checkoutPriceFor(product: Product, balance: Balance): CheckoutPrice {
  if (product === "top_up") {
    if (!balance.periodActive) throw new AgentError("subscription_required");
    return "top_up";
  }
  if (product !== "monthly") throw new AgentError("invalid_request", "product");
  if (balance.periodActive) throw new AgentError("already_subscribed");
  return balance.trialUsed ? "monthly" : "monthly_trial";
}
