import { LANGUAGES, type Language, type Parsed } from "../catalog/catalog_types.ts";
import { JsonReader, type JsonObject } from "../catalog/json_reader.ts";
import type { AppTheme, LocalizedText } from "./screenshot_story.ts";
import { parseInterface, parseProgram, parseTrace } from "./thermostat_parts.ts";

export type TraceStep = { readonly line: number; readonly values: readonly (number | null)[]; readonly output: number | null; readonly condition: boolean };

export type TrailerProgram = { readonly lines: readonly string[]; readonly variables: readonly string[]; readonly outputs: readonly string[] };

export type InterfaceTail = {
  readonly plate: string;
  readonly device: string;
  readonly appTheme: AppTheme;
  readonly startSeconds: number;
  readonly seconds: number;
  readonly mediaStart: number;
};

export type ThermostatStory = {
  readonly id: string;
  readonly durationSeconds: number;
  readonly startSeconds: number;
  readonly stepSeconds: number;
  readonly thumbnailSeconds: number;
  readonly lockupSeconds: number;
  readonly title: LocalizedText;
  readonly program: Readonly<Record<Language, TrailerProgram>>;
  readonly trace: readonly TraceStep[];
  readonly interface: InterfaceTail;
};


const STORY_KEYS = ["id", "durationSeconds", "startSeconds", "stepSeconds", "thumbnailSeconds", "lockupSeconds", "title", "program", "trace", "interface"];
const SECONDS = { min: 0, max: 60 };

export function parseThermostatStory(document: unknown): Parsed<ThermostatStory> {
  const reader = new JsonReader();
  const root = reader.object(document, "$");
  reader.keys(root, "$", STORY_KEYS);
  const story: ThermostatStory = {
    id: reader.text(root["id"], "id"),
    durationSeconds: reader.number(root["durationSeconds"], "durationSeconds", SECONDS),
    startSeconds: reader.number(root["startSeconds"], "startSeconds", SECONDS),
    stepSeconds: reader.number(root["stepSeconds"], "stepSeconds", { min: 0.5, max: 5 }),
    thumbnailSeconds: reader.number(root["thumbnailSeconds"], "thumbnailSeconds", SECONDS),
    lockupSeconds: reader.number(root["lockupSeconds"], "lockupSeconds", SECONDS),
    title: parseLocalized(reader, root["title"], "title"),
    program: parseProgram(reader, reader.object(root["program"], "program")),
    trace: parseTrace(reader, root["trace"]),
    interface: parseInterface(reader, root["interface"]),
  };
  verifyTimeline(reader, story);
  verifyTrace(reader, story);
  return reader.errors.length === 0 ? { ok: true, value: story } : { ok: false, errors: reader.errors };
}

export function traceEndSeconds(story: ThermostatStory): number {
  return story.startSeconds + story.trace.length * story.stepSeconds;
}

function parseLocalized(reader: JsonReader, value: unknown, path: string): LocalizedText {
  const entry: JsonObject = reader.object(value, path);
  reader.keys(entry, path, LANGUAGES);
  const text = {} as Record<Language, string>;
  for (const language of LANGUAGES) {
    text[language] = reader.text(entry[language], `${path}.${language}`);
  }
  return text;
}

function verifyTimeline(reader: JsonReader, story: ThermostatStory): void {
  const end = traceEndSeconds(story);
  const tail = story.interface;
  const ordered = [story.startSeconds, end, tail.startSeconds, tail.startSeconds + tail.seconds, story.lockupSeconds, story.durationSeconds];
  if (ordered.some((seconds, index) => index > 0 && seconds < (ordered[index - 1] ?? 0))) {
    reader.fail("$", "the trace, the interface tail and the lockup must follow each other inside the trailer");
  }
  if (story.thumbnailSeconds < story.startSeconds || story.thumbnailSeconds >= end) {
    reader.fail("thumbnailSeconds", "the thumbnail must show the program running");
  }
}

function verifyTrace(reader: JsonReader, story: ThermostatStory): void {
  for (const language of LANGUAGES) {
    const program = story.program[language];
    story.trace.forEach((step, index) => {
      if (step.line >= program.lines.length || step.values.length !== program.variables.length) {
        reader.fail(`trace[${index}]`, `does not fit the ${language} program`);
      }
      if (step.output !== null && step.output >= program.outputs.length) {
        reader.fail(`trace[${index}].output`, `has no ${language} output ${step.output}`);
      }
    });
  }
}
