import { authenticatedUser } from "../../agent-responses/application/agent_service.ts";
import { AgentError } from "../../agent-responses/domain/agent_error.ts";
import { checkoutPriceFor } from "../domain/checkout.ts";
import { productOf } from "../domain/purchase.ts";
import type { CreditsDependencies } from "./credits_service.ts";

export async function startCheckout(
  accessToken: string,
  productId: string,
  dependencies: CreditsDependencies,
): Promise<string> {
  const userId = await authenticatedUser(dependencies.users, accessToken);
  if (dependencies.checkouts === null) throw new AgentError("purchases_disabled");
  const product = productOf(productId);
  if (product === null) throw new AgentError("invalid_request", "product");
  const balance = await dependencies.ledger.balance(userId, dependencies.clock.now());
  return await dependencies.checkouts.open(userId, checkoutPriceFor(product, balance));
}

export async function openCustomerPortal(
  accessToken: string,
  dependencies: CreditsDependencies,
): Promise<string> {
  const userId = await authenticatedUser(dependencies.users, accessToken);
  if (dependencies.checkouts === null) throw new AgentError("purchases_disabled");
  const customerId = await dependencies.ledger.customer(userId, "paddle");
  if (customerId === null) throw new AgentError("not_found");
  return await dependencies.checkouts.portal(customerId);
}
