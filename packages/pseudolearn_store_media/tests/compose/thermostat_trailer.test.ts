import { describe, expect, it } from "vitest";
import { auditFrameCoverage, auditSafeArea } from "../../src/audit/safe_area_audit.ts";
import { auditContrast } from "../../src/audit/text_audit.ts";
import { thermostatContrastPairs } from "../../src/compose/thermostat_palette.ts";
import { buildThermostatTrailer, INTERFACE_FILE } from "../../src/compose/thermostat_trailer.ts";
import { thermostatLayout } from "../../src/layout/thermostat_layout.ts";
import { slot } from "../support/catalog.ts";
import { shippedThermostat } from "../support/thermostat.ts";

const trailer = slot("microsoft.trailer");
const story = shippedThermostat();
const program = story.program.es;
const layout = thermostatLayout({ canvas: { width: 1920, height: 1080 }, lines: program.lines, closing: program.outputs.at(-1)!,
  measure: { mono: (text, size) => text.length * size * 0.6, sans: (text, size) => text.length * size * 0.55 } });
const composition = buildThermostatTrailer({ id: "thermostat-es", slot: trailer, story, program, layout, limit: 24 });

describe("buildThermostatTrailer", () => {
  it("plays the real interface plate during the tail with its own timing", () => {
    expect(composition.html).toContain(`src="${INTERFACE_FILE}" muted data-start="21.4" data-duration="5" data-media-start="2.5"`);
    expect(composition.html).toContain(`id="lockup"`);
    expect(composition.html).toContain("Confort alcanzado tras 2 lecturas");
  });

  it("declares every frame, with the program in the safe area and the interface only in the tail", () => {
    expect(auditFrameCoverage(composition.id, { durationSeconds: 30, fps: 30 }, composition.layout)).toEqual([]);
    expect(auditSafeArea(composition.id, { slot: trailer, frames: composition.layout, profiles: [] })).toEqual([]);
    const at = (seconds: number) => composition.layout.find((frame) => Math.abs(frame.timeSeconds - seconds) < 1e-6)?.elements.map((element) => element.name);
    expect(at(5)).toEqual(["program"]);
    expect(at(23)).toEqual(["interface"]);
    expect(at(28)).toEqual([]);
  });

  it("lists every program text for the lexicon and keeps its colours readable", () => {
    expect(composition.texts).toEqual([...program.lines, ...program.variables, ...program.outputs]);
    expect(auditContrast(thermostatContrastPairs())).toEqual([]);
  });
});
