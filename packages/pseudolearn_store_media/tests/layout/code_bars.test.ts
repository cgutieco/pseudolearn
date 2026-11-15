import { describe, expect, it } from "vitest";
import { codeBars, roleOf } from "../../src/layout/code_bars.ts";

const rhythm = { rowGap: 150, barHeight: 22, tokenGap: 26, statementGap: 130 };
const measure = (text: string) => text.length * 20;

describe("codeBars", () => {
  it("covers the canvas in rows of bars whose widths come from the tokens", () => {
    const bars = codeBars({ canvas: { width: 800, height: 300 }, lines: ["Definir x <- 30;", "Escribir \"hola mundo\";"], measure, rhythm });
    const rows = new Set(bars.map((bar) => bar.y));
    expect(rows.size).toBe(3);
    expect(bars.every((bar) => bar.height === 22)).toBe(true);
    expect(Math.max(...bars.map((bar) => bar.x))).toBeLessThan(800);
    const widths = new Set(["Definir", "x", "<-", "30;", "Escribir", "\"hola mundo\"", ";"].map(measure));
    expect(bars.every((bar) => widths.has(bar.width))).toBe(true);
  });

  it("returns no bars for an empty program or an empty canvas", () => {
    expect(codeBars({ canvas: { width: 800, height: 300 }, lines: [], measure, rhythm })).toEqual([]);
    expect(codeBars({ canvas: { width: 0, height: 300 }, lines: ["a"], measure, rhythm })).toEqual([]);
  });
});

describe("roleOf", () => {
  it("classifies leading words, numbers, strings, operators and names", () => {
    expect(roleOf("Definir", true)).toBe("keyword");
    expect(roleOf("30;", false)).toBe("number");
    expect(roleOf("\"hola\"", true)).toBe("text");
    expect(roleOf("<-", false)).toBe("symbol");
    expect(roleOf("x", false)).toBe("name");
    expect(roleOf("", false)).toBe("name");
  });
});
