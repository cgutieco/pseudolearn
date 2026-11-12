import { describe, expect, it } from "vitest";
import { textWidth } from "../../src/layout/glyph_advances.ts";
import { thermostatLayout } from "../../src/layout/thermostat_layout.ts";
import { brandFont } from "../support/lens.ts";
import { shippedThermostat } from "../support/thermostat.ts";

const mono = brandFont("IBMPlexMono-Medium.ttf").advances;
const sans = brandFont("IBMPlexSans-Bold.ttf").advances;
const measure = { mono: (text: string, size: number) => textWidth(mono, text, size), sans: (text: string, size: number) => textWidth(sans, text, size) };
const canvas = { width: 1920, height: 1080 };

describe("thermostatLayout", () => {
  it("fits every shipped line beside the values and the closing on the canvas, in both languages", () => {
    const story = shippedThermostat();
    for (const language of ["es", "en"] as const) {
      const program = story.program[language];
      expect(thermostatLayout({ canvas, lines: program.lines, closing: program.outputs.at(-1)!, measure }).overflow).toEqual([]);
    }
  });

  it("reports a line that would run into the values and a closing wider than the canvas", () => {
    const long = `    Escribir ${"\"muy largo\", ".repeat(8)};`;
    const closing = "Confort alcanzado ".repeat(6);
    expect(thermostatLayout({ canvas, lines: [long], closing, measure }).overflow).toEqual([long, closing]);
  });

  it("scales with the canvas width", () => {
    const half = thermostatLayout({ canvas: { width: 960, height: 540 }, lines: [], closing: "", measure });
    expect(half.unit).toBe(0.5);
    expect(half.code.fontSize).toBe(12.5);
  });
});
