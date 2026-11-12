import { describe, expect, it } from "vitest";
import { visibleTextOf } from "../../src/audit/visible_text.ts";

describe("visibleTextOf", () => {
  it("returns nothing for markup made only of images, shapes, styles and scripts", () => {
    expect(visibleTextOf(`<head><title>t</title></head><style>.a{}</style><div><img src="p.png"><svg><path d="M0 0"/></svg></div><script>render(0)</script>`)).toBe("");
    expect(visibleTextOf("")).toBe("");
    expect(visibleTextOf("<p>&nbsp;</p>")).toBe("");
  });

  it("finds text in elements and in SVG", () => {
    expect(visibleTextOf("<div><span>Hola</span> <b>mundo</b></div>")).toBe("Hola mundo");
    expect(visibleTextOf(`<svg><text x="0">si</text></svg>`)).toBe("si");
    expect(visibleTextOf("<p>a &amp; b</p>")).toBe("a & b");
  });
});
