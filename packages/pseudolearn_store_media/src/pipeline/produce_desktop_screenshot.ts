import type { Catalog } from "../catalog/catalog_types.ts";
import { auditLabels } from "../audit/label_audit.ts";
import { auditFocus, auditPlate } from "../audit/screenshot_audit.ts";
import { buildDesktopScreenshot, DESKTOP_PLATE_FILE } from "../compose/desktop_screenshot.ts";
import { EDITORIAL_PALETTES } from "../compose/editorial_palette.ts";
import { codeBars } from "../layout/code_bars.ts";
import { textWidth, type GlyphAdvances } from "../layout/glyph_advances.ts";
import { projectRegion, windowRect } from "../layout/window_layout.ts";
import type { DesktopShot } from "../story/desktop_story.ts";
import type { Manifest } from "./manifest.ts";
import { readPlate, type RecordedPlate } from "./plate_source.ts";
import type { Outcome, Toolbox } from "./ports.ts";
import { produceStill } from "./produce_still.ts";
import type { Job } from "./render_plan.ts";

export const CODE_BAR_RHYTHM = { rowGap: 150, barHeight: 22, tokenGap: 26, statementGap: 130 };
export const CODE_BAR_FONT_SIZE = 44;

export type DesktopScreenshotJob = {
  readonly toolbox: Toolbox;
  readonly catalog: Catalog;
  readonly job: Job;
  readonly shot: DesktopShot;
  readonly position: number;
  readonly texture: { readonly lines: readonly string[]; readonly mono: GlyphAdvances };
  readonly platesRoot: string;
  readonly outputRoot: string;
};

export async function produceDesktopScreenshot(request: DesktopScreenshotJob): Promise<Outcome<Manifest>> {
  const { toolbox, job, shot } = request;
  const device = job.slot.device;
  if (!device) {
    return { ok: false, error: `${job.slot.id} declares no device to record the window on` };
  }
  const id = `${String(request.position).padStart(2, "0")}-${shot.id}`;
  const plate = await readPlate(toolbox.files, request.platesRoot, { chapter: shot, device: device.id, language: job.language });
  const findings = [
    ...auditPlate(id, device, plate.image),
    ...auditFocus(id, shot.critical.focus, plate.focus ? [...plate.focus.keys()] : null),
    ...auditLabels(request.catalog, job.slot, [{ kind: "caption", language: job.language, text: shot.caption[job.language] }]),
  ];
  const plateSize = { width: device.logicalWidth * device.plateScale, height: device.logicalHeight * device.plateScale };
  const composition = compose(request, { id, plate, plateSize });
  const assets = plate.image ? [{ name: DESKTOP_PLATE_FILE, bytes: plate.image }] : [];
  return produceStill({ toolbox, catalog: request.catalog, job, composition, assets, findings, outputRoot: request.outputRoot });
}

type Recorded = { readonly id: string; readonly plate: RecordedPlate; readonly plateSize: { width: number; height: number } };

function compose(request: DesktopScreenshotJob, recorded: Recorded) {
  const { job, shot, texture } = request;
  const canvas = { width: job.slot.width, height: job.slot.height };
  const window = windowRect(canvas, recorded.plateSize);
  const focus = recorded.plate.focus?.get(shot.critical.focus) ?? { x: 0, y: 0, ...recorded.plateSize };
  const critical = { name: shot.critical.focus, rect: projectRegion(focus, shot.critical.region, { rect: window, plate: recorded.plateSize }) };
  const bars = codeBars({ canvas, lines: texture.lines, measure: (token) => textWidth(texture.mono, token, CODE_BAR_FONT_SIZE), rhythm: CODE_BAR_RHYTHM });
  return buildDesktopScreenshot({ id: recorded.id, slot: job.slot, palette: EDITORIAL_PALETTES[shot.palette], window, bars, critical });
}
