import type { Size } from "../layout/pixel_rect.ts";
import type { ThermostatLayout } from "../layout/thermostat_layout.ts";
import { MONO_FONT_FILE, SANS_FONT_FILE } from "./editorial_markup.ts";
import { THERMOSTAT_PALETTE as P } from "./thermostat_palette.ts";

export function thermostatStyle(layout: ThermostatLayout, canvas: Size): string {
  const { code, numbers, unit } = layout;
  return `@font-face { font-family: "Sans"; src: url("${SANS_FONT_FILE}"); font-weight: 700; }
@font-face { font-family: "Mono"; src: url("${MONO_FONT_FILE}"); font-weight: 500; }
#stage { background: radial-gradient(ellipse at 40% 35%, ${P.centre} 0%, ${P.edge} 80%); overflow: hidden; }
.line { position: absolute; left: ${code.x}px; font-family: "Mono"; font-size: ${code.fontSize}px; white-space: pre; color: ${P.code}; }
#bar { position: absolute; left: ${code.x - 24 * unit}px; width: ${numbers.x - code.x - 16 * unit}px; height: ${code.lineHeight}px; border-radius: ${10 * unit}px; }
.label { position: absolute; left: ${numbers.x + 12 * unit}px; font-family: "Mono"; font-size: ${numbers.labelSize}px; color: ${P.code}; }
.value { position: absolute; left: ${numbers.x}px; font-family: "Sans"; font-weight: 700; line-height: 1; color: ${P.number}; }
.big { top: ${250 * unit}px; font-size: ${numbers.bigSize}px; letter-spacing: -0.04em; }
.small { top: ${680 * unit}px; left: ${numbers.x + 8 * unit}px; font-size: ${numbers.smallSize}px; }
#out { position: absolute; left: ${code.x}px; top: ${code.y + 11 * code.lineHeight + 20 * unit}px; font-family: "Mono"; font-size: ${28 * unit}px; line-height: 1.6; color: ${P.output}; }
#closing { position: absolute; left: 0; top: ${480 * unit}px; width: ${canvas.width}px; text-align: center; font-family: "Sans"; font-weight: 700; font-size: ${layout.closingSize}px; color: ${P.reached}; opacity: 0; }
#tail { position: absolute; inset: 0; opacity: 0; }
#tail video { position: absolute; left: 0; top: 0; width: ${canvas.width}px; height: ${canvas.height}px; }
#lockup { position: absolute; left: ${canvas.width / 2 - 330 * unit}px; top: ${440 * unit}px; width: ${660 * unit}px; height: auto; opacity: 0; }`;
}
