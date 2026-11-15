import type { Slot } from "../catalog/catalog_types.ts";
import { sampleEveryFrame } from "../layout/frame_sampling.ts";
import type { ThermostatLayout } from "../layout/thermostat_layout.ts";
import type { TrailerProgram, ThermostatStory } from "../story/thermostat_story.ts";
import { traceEndSeconds } from "../story/thermostat_story.ts";
import { BRAND_LOCKUP_HORIZONTAL_INVERSE_SVG } from "./brand.generated.ts";
import { htmlDocument, settingClockTimeline, type Composition } from "./composition.ts";
import { escapeHtml } from "./html_text.ts";
import { THERMOSTAT_PALETTE as P } from "./thermostat_palette.ts";
import { thermostatScript } from "./thermostat_script.ts";
import { thermostatStyle } from "./thermostat_style.ts";

export const INTERFACE_FILE = "interface.mp4";

export type ThermostatRequest = {
  readonly id: string;
  readonly slot: Slot;
  readonly story: ThermostatStory;
  readonly program: TrailerProgram;
  readonly layout: ThermostatLayout;
  readonly limit: number;
};

export function buildThermostatTrailer(request: ThermostatRequest): Composition {
  const { slot, story, program, layout, id } = request;
  const canvas = { width: slot.width, height: slot.height };
  const closing = program.outputs[story.trace.at(-1)?.output ?? -1] ?? "";
  const tail = story.interface;
  const script = thermostatScript({
    trace: story.trace.map((step) => ({ line: step.line, values: step.values, condition: step.condition, output: step.output === null ? null : program.outputs[step.output] ?? null })),
    closing, start: story.startSeconds, step: story.stepSeconds, lineHeight: layout.code.lineHeight, codeY: layout.code.y, limit: request.limit,
    tail: { start: tail.startSeconds, end: tail.startSeconds + tail.seconds }, lockup: story.lockupSeconds,
    colors: { code: P.code, current: P.current, number: P.number, reached: P.reached, bar: P.bar, conditionBar: P.conditionBar },
  });
  const html = htmlDocument({ id, canvas, durationSeconds: story.durationSeconds, style: thermostatStyle(layout, canvas), body: body(request, closing, script),
    timeline: settingClockTimeline(story.durationSeconds) });
  const texts = [...program.lines, ...program.variables, ...program.outputs];
  return { id, canvas, durationSeconds: story.durationSeconds, html, texts, layout: frames(request, canvas) };
}

function body(request: ThermostatRequest, closing: string, script: string): string {
  const { program, layout, story } = request;
  const tail = story.interface;
  const lines = program.lines.map((text, index) => `<div class="line" style="top:${layout.code.y + index * layout.code.lineHeight}px">${escapeHtml(text)}</div>`).join("");
  const variables = program.variables.map((name, index) => `<div class="label" style="top:${index === 0 ? 232 * layout.unit : 640 * layout.unit}px">${escapeHtml(name)}</div>
<div class="value ${index === 0 ? "big" : "small"}">–</div>`).join("");
  const lockup = BRAND_LOCKUP_HORIZONTAL_INVERSE_SVG.replace("<svg", `<svg id="lockup"`);
  return `<div id="bar"></div>${lines}${variables}<div id="out"></div><div id="closing">${escapeHtml(closing)}</div>
<div id="tail"><video id="interface" class="clip plate" src="${INTERFACE_FILE}" muted data-start="${tail.startSeconds}" data-duration="${tail.seconds}" data-media-start="${tail.mediaStart}"></video></div>
${lockup}<script>${script}</script>`;
}

function frames(request: ThermostatRequest, canvas: { width: number; height: number }) {
  const { story, layout } = request;
  const tail = story.interface;
  const programEnd = traceEndSeconds(story) + 3.8;
  return sampleEveryFrame({ durationSeconds: story.durationSeconds, fps: request.slot.video?.fps ?? 30 }, (time) => {
    if (time >= tail.startSeconds && time < tail.startSeconds + tail.seconds) {
      return [{ name: "interface", rect: { x: 0, y: 0, ...canvas }, essential: false, content: "app-interface" as const }];
    }
    return time < programEnd ? [{ name: "program", rect: layout.program, essential: true, content: "artwork" as const }] : [];
  });
}

