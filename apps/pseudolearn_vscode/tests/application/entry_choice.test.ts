import { describe, expect, it } from "vitest";
import { entryProblemMessage, listProjectEntries } from "../../src/application/entry_choice";

const settings = { executable: "pseudo", language: "es" } as never;

function runner(stdout: string) {
  return { run: async () => ({ stdout, stderr: "", code: 0 }) } as never;
}

describe("Project entry choice", () => {
  it("lists module paths reported by the checker", async () => {
    const modules = [{ path: "app/main" }, { path: "geo/vectores" }, { path: 3 }];
    expect(await listProjectEntries(runner(JSON.stringify({ modules })), { directory: "/p", settings }))
      .toEqual(["app/main", "geo/vectores"]);
  });

  it("returns nothing for a folder that is not a project root or for unreadable output", async () => {
    const manifestOnly = JSON.stringify({ manifest_errors: [{ code: "invalidPath" }] });
    expect(await listProjectEntries(runner(manifestOnly), { directory: "/p", settings })).toEqual([]);
    expect(await listProjectEntries(runner("not json"), { directory: "/p", settings })).toEqual([]);
  });

  it("explains each problem in the interface language", () => {
    expect(entryProblemMessage("noModules", "es-ES")).toContain("raíz del proyecto");
    expect(entryProblemMessage("noModules", "en")).toContain("project root");
    expect(entryProblemMessage("noEntry", "fr")).toContain("Select Project Entry");
  });
});
