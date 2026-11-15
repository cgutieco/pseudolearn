import { AgentError } from "./agent_error.ts";
import { isRecord, maxOutputTokens } from "./credits.ts";

const allowedEfforts: ReadonlySet<string> = new Set(["minimal", "low", "medium"]);
const maxTools = 64;
const maxInputItems = 400;

export interface ModelPolicy {
  readonly model: string;
}

export function sanitizeResponsesBody(
  raw: unknown,
  policy: ModelPolicy,
): Record<string, unknown> {
  if (!isRecord(raw)) throw new AgentError("invalid_request", "body");
  const { instructions, input, tools, reasoning, max_output_tokens: requested } = raw;
  if (typeof instructions !== "string") throw new AgentError("invalid_request", "instructions");
  if (!Array.isArray(input) || input.length === 0 || input.length > maxInputItems) {
    throw new AgentError("invalid_request", "input");
  }
  const functions = Array.isArray(tools) ? tools : [];
  const onlyFunctions = functions.every((tool) => isRecord(tool) && tool.type === "function");
  if (functions.length > maxTools || !onlyFunctions) {
    throw new AgentError("invalid_request", "tools");
  }
  const effort = isRecord(reasoning) && typeof reasoning.effort === "string"
    ? reasoning.effort
    : "low";
  const output = typeof requested === "number" && requested > 0 ? requested : maxOutputTokens;
  return {
    model: policy.model,
    instructions,
    input,
    tools: functions,
    tool_choice: "auto",
    parallel_tool_calls: raw.parallel_tool_calls !== false,
    store: false,
    reasoning: { effort: allowedEfforts.has(effort) ? effort : "low" },
    max_output_tokens: Math.min(Math.floor(output), maxOutputTokens),
  };
}
