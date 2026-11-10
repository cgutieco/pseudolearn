import { describe, expect, it } from "vitest";
import { planJobs } from "../../src/pipeline/render_plan.ts";
import { realCatalog } from "../support/catalog.ts";

const catalog = realCatalog();

describe("planJobs", () => {
  it("plans every slot in every language when nothing is selected", () => {
    expect(planJobs({ catalog, slotIds: [], languages: ["es", "en"] }).jobs).toHaveLength(38);
  });

  it("maps each language to the store locales and a stable directory", () => {
    const { jobs } = planJobs({ catalog, slotIds: ["microsoft.trailer"], languages: ["en"] });
    expect(jobs).toHaveLength(1);
    expect(jobs[0]?.locales).toEqual(["en-US"]);
    expect(jobs[0]?.directory).toBe("microsoft-store/microsoft.trailer/en");
  });

  it("reports unknown slots instead of ignoring them", () => {
    const plan = planJobs({ catalog, slotIds: ["google.play.phone"], languages: ["es"] });
    expect(plan.jobs).toEqual([]);
    expect(plan.unknownSlots).toEqual(["google.play.phone"]);
  });

  it("plans nothing for no languages", () => {
    expect(planJobs({ catalog, slotIds: [], languages: [] }).jobs).toEqual([]);
  });
});
