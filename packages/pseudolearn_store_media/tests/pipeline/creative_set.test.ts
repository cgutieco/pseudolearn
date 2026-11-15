import { describe, expect, it } from "vitest";
import { produceCreativeSet } from "../../src/pipeline/creative_set.ts";
import { planJobs } from "../../src/pipeline/render_plan.ts";
import { realCatalog } from "../support/catalog.ts";
import { fakeToolbox } from "../support/fake_toolbox.ts";
import { shippedLensStory } from "../support/lens.ts";
import { goodProbe } from "../support/probe.ts";

const catalog = realCatalog();
const story = shippedLensStory();

describe("produceCreativeSet", () => {
  it("refuses slots that are not creative assets", async () => {
    const jobs = planJobs({ catalog, slotIds: ["apple.mac.screenshot", "apple.header.video"], languages: ["es"] }).jobs;
    const outcome = await produceCreativeSet({ toolbox: fakeToolbox({}, goodProbe({ width: 1, height: 1 })), catalog, jobs, story,
      fontPaths: { sans: "a.ttf", mono: "b.ttf" }, outputRoot: "out" });
    expect(outcome).toEqual({ ok: false, error: "creative assets need header, search or universal slots; not one: apple.mac.screenshot" });
  });

  it("reports missing fonts as a value", async () => {
    const jobs = planJobs({ catalog, slotIds: ["apple.header.video"], languages: ["es"] }).jobs;
    const outcome = await produceCreativeSet({ toolbox: fakeToolbox({}, goodProbe({ width: 1, height: 1 })), catalog, jobs, story,
      fontPaths: { sans: "a.ttf", mono: "b.ttf" }, outputRoot: "out" });
    expect(outcome).toEqual({ ok: false, error: "missing font a.ttf; missing font b.ttf" });
  });
});
