import { describe, expect, it } from "vitest";
import type { VideoProbe } from "../../src/audit/video_audit.ts";
import { inspectImage } from "../../src/pipeline/inspect_image.ts";
import { slot } from "../support/catalog.ts";
import { fakeToolbox } from "../support/fake_toolbox.ts";
import { pngBytes } from "../support/png.ts";

const anyProbe = {} as VideoProbe;

describe("inspectImage", () => {
  it("reads the file through the store and audits it against the slot", async () => {
    const toolbox = fakeToolbox({}, anyProbe);
    toolbox.written.set("thumbnail.png", pngBytes({ width: 1920, height: 1080, colorType: 2 }));
    expect(await inspectImage(toolbox.files, slot("microsoft.trailer-thumbnail"), "thumbnail.png")).toEqual([]);
  });

  it("reports a missing file as a format finding", async () => {
    const toolbox = fakeToolbox({}, anyProbe);
    const findings = await inspectImage(toolbox.files, slot("microsoft.trailer-thumbnail"), "missing.png");
    expect(findings.map((entry) => entry.rule)).toEqual(["MEDIA-FORMAT"]);
  });
});
