import { AgentError } from "../domain/agent_error.ts";
import type { Balance } from "../domain/balance.ts";
import { milliCreditsFor, usageFromResponses } from "../domain/credits.ts";
import type {
  Clock,
  LedgerCall,
  LedgerGateway,
  ModelGateway,
  UserVerifier,
} from "../domain/ports.ts";
import { type ModelPolicy, sanitizeResponsesBody } from "../domain/request_policy.ts";

export interface AgentDependencies {
  readonly users: UserVerifier;
  readonly ledger: LedgerGateway;
  readonly model: ModelGateway;
  readonly policy: ModelPolicy;
  readonly clock: Clock;
}

export interface AgentCommand {
  readonly accessToken: string;
  readonly requestId: string;
  readonly turnId: string;
  readonly body: unknown;
}

export interface AgentReply {
  readonly body: string;
  readonly balance: Balance;
}

export async function authenticatedUser(users: UserVerifier, token: string): Promise<string> {
  const userId = await users.verify(token);
  if (userId === null) throw new AgentError("unauthenticated");
  return userId;
}

export async function respondWithModel(
  command: AgentCommand,
  dependencies: AgentDependencies,
): Promise<AgentReply> {
  const userId = await authenticatedUser(dependencies.users, command.accessToken);
  const body = sanitizeResponsesBody(command.body, dependencies.policy);
  const call: LedgerCall = { ...command, userId, now: dependencies.clock.now() };
  const authorization = await dependencies.ledger.authorize(call);
  if (authorization.kind === "refused") throw new AgentError(authorization.code);
  const reply = await dependencies.model.respond(body);
  if (reply.status === 429) {
    throw new AgentError("upstream_rate_limited", reply.retryAfter ?? undefined);
  }
  if (reply.status < 200 || reply.status >= 300) {
    throw new AgentError("upstream_error", String(reply.status), reply.status >= 500);
  }
  const usage = usageFromResponses(reply.json);
  if (usage === null) throw new AgentError("upstream_error", "usage", true);
  const balance = await dependencies.ledger.debit(call, milliCreditsFor(usage));
  return { body: reply.body, balance };
}
