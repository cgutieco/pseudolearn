import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { browserCommandContributions, desktopOnlyCommands, menusForCommands } from "../../scripts/lib/web-manifest.mjs";

const manifest = JSON.parse(readFileSync(new URL("../../package.json", import.meta.url), "utf8"));

describe("browserCommandContributions", () => {
  it("keeps the commands the browser activation registers", () => {
    const names = browserCommandContributions(manifest.contributes.commands).map((entry) => entry.command);
    expect(names).toContain("pseudolearn.runFile");
    expect(names).toContain("pseudolearn.stopRun");
    expect(names).toContain("pseudolearn.debugFile");
    expect(names).toContain("pseudolearn.debugProject");
  });

  it("drops every desktop-only command", () => {
    const names = browserCommandContributions(manifest.contributes.commands).map((entry) => entry.command);
    for (const command of desktopOnlyCommands) expect(names).not.toContain(command);
  });

  it("returns an empty list for no commands", () => {
    expect(browserCommandContributions([])).toEqual([]);
  });
});

describe("menusForCommands", () => {
  const commands = [{ command: "pseudolearn.runFile" }];

  it("keeps menu items whose command is contributed", () => {
    const menus = { "editor/title/run": [{ command: "pseudolearn.runFile", group: "navigation@1" }] };
    expect(menusForCommands(menus, commands)).toEqual(menus);
  });

  it("removes menu items whose command is not contributed and keeps the location", () => {
    const menus = { "editor/title/run": [{ command: "pseudolearn.debugFile" }], "editor/context": [] };
    expect(menusForCommands(menus, commands)).toEqual({ "editor/title/run": [], "editor/context": [] });
  });

  it("treats missing menus as empty", () => {
    expect(menusForCommands(undefined, commands)).toEqual({});
  });

  it("leaves no browser menu pointing at a desktop-only command", () => {
    const browserCommands = browserCommandContributions(manifest.contributes.commands);
    const items = Object.values(menusForCommands(manifest.contributes.menus, browserCommands)).flat();
    for (const item of items) expect(desktopOnlyCommands).not.toContain(item.command);
  });
});
