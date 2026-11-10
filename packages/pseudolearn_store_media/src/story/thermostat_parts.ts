import { LANGUAGES, type Language } from "../catalog/catalog_types.ts";
import type { JsonObject, JsonReader } from "../catalog/json_reader.ts";
import { APP_THEMES } from "./screenshot_story.ts";
import type { InterfaceTail, TraceStep, TrailerProgram } from "./thermostat_story.ts";

const PROGRAM_KEYS = ["lines", "variables", "outputs"];
const STEP_KEYS = ["line", "values", "output", "condition"];
const TAIL_KEYS = ["plate", "appTheme", "startSeconds", "seconds", "mediaStart"];

export function parseProgram(reader: JsonReader, entry: JsonObject): Record<Language, TrailerProgram> {
  reader.keys(entry, "program", LANGUAGES);
  const programs = {} as Record<Language, TrailerProgram>;
  for (const language of LANGUAGES) {
    const path = `program.${language}`;
    const program = reader.object(entry[language], path);
    reader.keys(program, path, PROGRAM_KEYS);
    const texts = (key: string) => reader.array(program[key], `${path}.${key}`).map((value, index) => reader.text(value, `${path}.${key}[${index}]`));
    programs[language] = { lines: texts("lines"), variables: texts("variables"), outputs: texts("outputs") };
  }
  const [first, second] = LANGUAGES.map((language) => programs[language]);
  if (first && second && (first.lines.length !== second.lines.length || first.outputs.length !== second.outputs.length || first.variables.length !== second.variables.length)) {
    reader.fail("program", "every language must translate the same lines, variables and outputs");
  }
  return programs;
}

export function parseTrace(reader: JsonReader, value: unknown): readonly TraceStep[] {
  const steps = reader.array(value, "trace").map((item, index) => {
    const path = `trace[${index}]`;
    const step = reader.object(item, path);
    reader.keys(step, path, STEP_KEYS);
    return {
      line: reader.number(step["line"], `${path}.line`, { min: 0, max: 200 }),
      values: reader.array(step["values"], `${path}.values`).map((entry, at) => (entry === null ? null : reader.number(entry, `${path}.values[${at}]`, { min: -1e6, max: 1e6 }))),
      output: step["output"] === null ? null : reader.number(step["output"], `${path}.output`, { min: 0, max: 100 }),
      condition: step["condition"] === true,
    };
  });
  if (steps.length === 0) {
    reader.fail("trace", "the trailer needs at least one step");
  }
  return steps;
}

export function parseInterface(reader: JsonReader, value: unknown): InterfaceTail {
  const entry = reader.object(value, "interface");
  reader.keys(entry, "interface", TAIL_KEYS);
  return {
    plate: reader.text(entry["plate"], "interface.plate"),
    appTheme: reader.member(entry["appTheme"], "interface.appTheme", APP_THEMES),
    startSeconds: reader.number(entry["startSeconds"], "interface.startSeconds", { min: 0, max: 60 }),
    seconds: reader.number(entry["seconds"], "interface.seconds", { min: 2, max: 20 }),
    mediaStart: reader.number(entry["mediaStart"], "interface.mediaStart", { min: 0, max: 60 }),
  };
}
