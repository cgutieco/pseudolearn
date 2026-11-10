import { describe, expect, it } from "vitest";
import { auditAppUi, visibleUiAt, type AppUiRequest } from "../../src/audit/app_ui_audit.ts";

const continuous: AppUiRequest = {
  target: "overview",
  durationSeconds: 2,
  fps: 30,
  scenes: [{ startSeconds: 0, endSeconds: 1.2 }, { startSeconds: 0.6, endSeconds: 2 }],
  covers: [{ startSeconds: 0.2, endSeconds: 0.8, areaFraction: 0.3 }],
};

describe("auditAppUi", () => {
  it("accepts scenes that dissolve into each other with overlays covering under half the frame", () => {
    expect(auditAppUi(continuous)).toEqual([]);
    expect(visibleUiAt(continuous, 0.5)).toBeCloseTo(0.7);
  });

  it("rejects a gap between scenes as one run of frames without the app", () => {
    const findings = auditAppUi({ ...continuous, scenes: [{ startSeconds: 0, endSeconds: 1 }, { startSeconds: 1.5, endSeconds: 2 }] });
    expect(findings).toHaveLength(1);
    expect(findings[0]).toMatchObject({ rule: "MEDIA-APP-UI", target: "overview" });
    expect(findings[0]?.message).toContain("frames 30–44");
  });

  it("rejects a card that hides most of the interface, even over a scene", () => {
    const covered = { ...continuous, covers: [{ startSeconds: 1, endSeconds: 1.1, areaFraction: 0.75 }] };
    expect(auditAppUi(covered).map((entry) => entry.message)).toEqual([
      "frames 30–32 (1.00s) show less than 50% of the app's interface",
    ]);
  });

  it("treats a fade from black at the start as frames without the app", () => {
    expect(auditAppUi({ ...continuous, scenes: [{ startSeconds: 0.1, endSeconds: 2 }] })[0]?.message).toContain("frames 0–2");
  });

  it("reports every frame of a preview with no scenes and nothing for an empty preview", () => {
    expect(auditAppUi({ ...continuous, scenes: [] })).toHaveLength(1);
    expect(auditAppUi({ ...continuous, durationSeconds: 0, scenes: [] })).toEqual([]);
  });
});
