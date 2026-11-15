import { describe, expect, it } from "vitest";
import { isAccepted, manifestOf } from "../../src/pipeline/manifest.ts";
import { planJobs } from "../../src/pipeline/render_plan.ts";
import { realCatalog } from "../support/catalog.ts";

const [job] = planJobs({ catalog: realCatalog(), slotIds: ["apple.header.video"], languages: ["en"] }).jobs;

describe("manifestOf", () => {
  it("records slot, language and locales from the job", () => {
    const manifest = manifestOf({ piece: "header", job: job!, file: "header.mp4", sha256: "a", checkedFrames: 300, findings: [] });
    expect(manifest).toMatchObject({ slot: "apple.header.video", language: "en", locales: ["en-US"], checkedFrames: 300 });
  });
});

describe("isAccepted", () => {
  it("accepts only a rendered file without findings", () => {
    const base = { piece: "header", job: job!, sha256: null, checkedFrames: 0 };
    expect(isAccepted(manifestOf({ ...base, file: "header.mp4", findings: [] }))).toBe(true);
    expect(isAccepted(manifestOf({ ...base, file: null, findings: [] }))).toBe(false);
    expect(isAccepted(manifestOf({ ...base, file: "header.mp4", findings: [{ rule: "MEDIA-LOOP", target: "x", message: "y" }] }))).toBe(false);
  });
});
