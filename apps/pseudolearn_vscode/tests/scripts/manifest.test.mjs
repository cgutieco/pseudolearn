import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";

const manifest = JSON.parse(readFileSync(new URL("../../package.json", import.meta.url), "utf8"));

describe("Extension manifest debugging contributions", () => {
  it("enables breakpoints for the language the debugger serves", () => {
    const debuggerLanguages = manifest.contributes.debuggers.flatMap((entry) => entry.languages);
    const breakpointLanguages = manifest.contributes.breakpoints.map((entry) => entry.language);
    expect(debuggerLanguages).toContain("pseudolearn");
    for (const language of debuggerLanguages) expect(breakpointLanguages).toContain(language);
  });
});
