import { assertEquals } from "@std/assert";
import {
  displayCredits,
  milliCreditsFor,
  usageFromResponses,
} from "../../../../supabase/functions/agent-responses/domain/credits.ts";

Deno.test("the credit formula weights uncached input, cached input and output", () => {
  const milli = milliCreditsFor({
    inputTokens: 10_000,
    cachedInputTokens: 2_000,
    outputTokens: 400,
  });
  assertEquals(milli, Math.ceil(((1.25 * 8_000 + 0.1 * 2_000 + 5 * 400) / 10_000) * 1_000));
});

Deno.test("cached tokens never exceed input and negative counts are ignored", () => {
  assertEquals(milliCreditsFor({ inputTokens: 100, cachedInputTokens: 500, outputTokens: -3 }), 1);
  assertEquals(milliCreditsFor({ inputTokens: 0, cachedInputTokens: 0, outputTokens: 0 }), 0);
});

Deno.test("usage is read from the Responses body and missing usage is null", () => {
  assertEquals(
    usageFromResponses({ usage: { input_tokens: 3, output_tokens: 4 } }),
    { inputTokens: 3, cachedInputTokens: 0, outputTokens: 4 },
  );
  assertEquals(usageFromResponses({}), null);
  assertEquals(usageFromResponses({ usage: { input_tokens: "3" } }), null);
});

Deno.test("displayed credits round down and never go negative", () => {
  assertEquals(displayCredits(1_999), 1);
  assertEquals(displayCredits(-5), 0);
});
