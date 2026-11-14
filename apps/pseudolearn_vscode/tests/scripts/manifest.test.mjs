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

describe("Extension manifest menu contributions", () => {
  const commands = new Map(manifest.contributes.commands.map((entry) => [entry.command, entry]));
  const items = Object.entries(manifest.contributes.menus).flatMap(([location, entries]) =>
    entries.map((entry) => ({ location, ...entry })));

  it("only places declared commands in menus", () => {
    expect(items.length).toBeGreaterThan(0);
    for (const item of items) expect(commands.has(item.command)).toBe(true);
  });

  it("gives every command shown as a toolbar button a theme-aware codicon", () => {
    const buttons = items.filter((item) => item.location === "editor/title/run" || item.group?.startsWith("navigation"));
    for (const button of buttons) expect(commands.get(button.command).icon).toMatch(/^\$\([a-z-]+\)$/);
  });

  it("offers stop only while a run is active and run actions only while none is", () => {
    const stop = items.filter((item) => item.command === "pseudolearn.stopRun");
    expect(stop.map((item) => item.when)).toEqual(["pseudolearn.running"]);
    const runs = items.filter((item) => item.location === "editor/title/run");
    for (const run of runs) expect(run.when).toContain("!pseudolearn.running");
  });

  it("scopes every PseudoLearn action except stop to PseudoLearn editors", () => {
    const scoped = items.filter((item) => item.command !== "pseudolearn.stopRun");
    for (const item of scoped) expect(item.when).toMatch(/(resource|editor)LangId == pseudolearn/);
  });
});

describe("Extension manifest editor API floor", () => {
  const versionParts = (version) => version.replace(/^\^/, "").split(".").map(Number);
  const exceeds = (candidate, floor) => {
    const [left, right] = [versionParts(candidate), versionParts(floor)];
    const difference = left.map((part, index) => part - right[index]).find((value) => value !== 0);
    return (difference ?? 0) > 0;
  };

  it("compiles against editor types no newer than the minimum editor it promises", () => {
    expect(exceeds(manifest.devDependencies["@types/vscode"], manifest.engines.vscode)).toBe(false);
  });

  it("detects types newer than the promised minimum editor", () => {
    expect(exceeds("1.146.0", "^1.144.0")).toBe(true);
    expect(exceeds("1.144.1", "^1.144.0")).toBe(true);
    expect(exceeds("1.144.0", "^1.144.0")).toBe(false);
    expect(exceeds("1.99.0", "^1.144.0")).toBe(false);
  });
});
