import { describe, expect, it } from "vitest";
import type { VideoProbe } from "../../src/audit/video_audit.ts";
import { isAccepted } from "../../src/pipeline/manifest.ts";
import { produceAppIcon } from "../../src/pipeline/produce_app_icon.ts";
import { planJobs } from "../../src/pipeline/render_plan.ts";
import { realCatalog } from "../support/catalog.ts";
import { fakeToolbox } from "../support/fake_toolbox.ts";
import { pngBytes } from "../support/png.ts";

const catalog = realCatalog();

function jobFor(id: string) {
  return planJobs({ catalog, slotIds: [id], languages: ["es"] }).jobs[0]!;
}

describe("produceAppIcon", () => {
  it("renders the store icon as one 32-bit RGBA still", async () => {
    const toolbox = fakeToolbox({ flattened: pngBytes({ width: 512, height: 512, colorType: 6 }) }, {} as VideoProbe);
    const outcome = await produceAppIcon({ toolbox, catalog, job: jobFor("google-play.app-icon"), outputRoot: "out" });
    expect(outcome.ok && outcome.value.file).toBe("out/google-play/google-play.app-icon/es/app-icon-512.png");
    expect(outcome.ok && isAccepted(outcome.value)).toBe(true);
  });
});

describe("produceAppIcon rejections", () => {
  it("rejects an icon that comes out without an alpha channel", async () => {
    const toolbox = fakeToolbox({ flattened: pngBytes({ width: 512, height: 512, colorType: 2 }) }, {} as VideoProbe);
    const outcome = await produceAppIcon({ toolbox, catalog, job: jobFor("google-play.app-icon"), outputRoot: "out" });
    expect(outcome.ok && outcome.value.findings.map((entry) => entry.rule)).toEqual(["MEDIA-FORMAT"]);
  });

  it("reports a renderer failure as a value", async () => {
    const toolbox = fakeToolbox({ frames: { ok: false, error: "renderer crashed" } }, {} as VideoProbe);
    expect(await produceAppIcon({ toolbox, catalog, job: jobFor("google-play.app-icon"), outputRoot: "out" }))
      .toEqual({ ok: false, error: "renderer crashed" });
  });

  it("refuses a slot that is not an app icon", async () => {
    const toolbox = fakeToolbox({}, {} as VideoProbe);
    expect(await produceAppIcon({ toolbox, catalog, job: jobFor("google-play.feature-graphic"), outputRoot: "out" }))
      .toEqual({ ok: false, error: "google-play.feature-graphic is not an app icon" });
  });
});
