import { readFileSync } from "node:fs";
import { parseThermostatStory, type ThermostatStory } from "../../src/story/thermostat_story.ts";

export function thermostatDocument(): Record<string, unknown> {
  return JSON.parse(readFileSync(new URL("../../stories/microsoft-store-trailer.json", import.meta.url), "utf8")) as Record<string, unknown>;
}

export function shippedThermostat(): ThermostatStory {
  const parsed = parseThermostatStory(thermostatDocument());
  if (!parsed.ok) {
    throw new Error(parsed.errors.map((error) => `${error.path}: ${error.message}`).join("\n"));
  }
  return parsed.value;
}

export function guidedDemoTrace(): readonly { line: number; values: readonly (number | null)[]; output: number | null; condition: boolean }[] {
  const steps: { line: number; values: (number | null)[]; output: number | null; condition: boolean }[] = [];
  let temperature = 30;
  let readings: number | null = null;
  const record = (line: number, extra: { output?: number; condition?: boolean } = {}) =>
    steps.push({ line, values: [temperature, readings], output: extra.output ?? null, condition: extra.condition ?? false });
  record(1);
  readings = 0;
  record(2);
  while (temperature > 24) {
    record(3, { condition: true });
    temperature -= 3;
    record(4);
    readings += 1;
    record(5);
    record(6, { output: readings - 1 });
  }
  record(3, { condition: true });
  record(8, { output: readings });
  return steps;
}
