import { assertEquals, assertThrows } from "@std/assert";
import { AgentError } from "../../../../supabase/functions/agent-responses/domain/agent_error.ts";
import { sanitizeResponsesBody } from "../../../../supabase/functions/agent-responses/domain/request_policy.ts";

const policy = { model: "gpt-6-luna" };
const input = [{ role: "user", content: "x" }];

Deno.test("the server fixes model, storage, tool choice and caps output", () => {
  const body = sanitizeResponsesBody(
    {
      instructions: "i",
      input,
      model: "gpt-expensive",
      store: true,
      max_output_tokens: 99_999,
      reasoning: { effort: "high" },
    },
    policy,
  );
  assertEquals(body.model, "gpt-6-luna");
  assertEquals(body.store, false);
  assertEquals(body.max_output_tokens, 4_000);
  assertEquals(body.reasoning, { effort: "low" });
  assertEquals(body.tool_choice, "auto");
});

Deno.test("tools with their own cost are rejected", () => {
  const error = assertThrows(
    () =>
      sanitizeResponsesBody({ instructions: "i", input, tools: [{ type: "web_search" }] }, policy),
    AgentError,
  );
  assertEquals(error.code, "invalid_request");
  assertEquals(error.detail, "tools");
});

Deno.test("missing instructions and empty input are rejected", () => {
  assertThrows(() => sanitizeResponsesBody({ input }, policy), AgentError);
  assertThrows(() => sanitizeResponsesBody({ instructions: "i", input: [] }, policy), AgentError);
  assertThrows(() => sanitizeResponsesBody("text", policy), AgentError);
});
