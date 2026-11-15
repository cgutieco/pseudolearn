import { describe, expect, it } from "vitest";
import { htmlDocument, TIMELINE_LIBRARY, viewBoxSize } from "../../src/compose/composition.ts";

describe("htmlDocument", () => {
  it("loads the local timeline library and pins the viewport to the canvas", () => {
    const html = htmlDocument({ id: "piece", canvas: { width: 886, height: 1920 }, durationSeconds: 15, style: "", body: "", timeline: "" });
    expect(html).toContain(`<script src="${TIMELINE_LIBRARY}"></script>`);
    expect(html).toContain('<meta name="viewport" content="width=886, height=1920">');
    expect(html).toContain('data-duration="15"');
    expect(html).not.toContain("https://");
  });
});

describe("viewBoxSize", () => {
  it("reads width and height, including a negative origin", () => {
    expect(viewBoxSize('<svg viewBox="0 -5.975 749.866 122.150">')).toEqual({ width: 749.866, height: 122.15 });
  });

  it("returns zero for an SVG without a view box", () => {
    expect(viewBoxSize("<svg>")).toEqual({ width: 0, height: 0 });
  });
});
