import type { LensLayout } from "../layout/lens_layout.ts";
import { MONO_FONT_FILE, SANS_FONT_FILE } from "./editorial_markup.ts";
import { LENS_PALETTE as P } from "./lens_palette.ts";

const GLOW_WIDTH = 0.19;
const SKEW_DEGREES = 14;

export function lensStyle(layout: LensLayout): string {
  const u = layout.unit;
  const radius = 96 * u;
  return `@font-face { font-family: "Sans"; src: url("${SANS_FONT_FILE}"); font-weight: 700; }
@font-face { font-family: "Mono"; src: url("${MONO_FONT_FILE}"); font-weight: 500; }
#stage { background: ${P.field}; overflow: hidden; }
.row { position: absolute; left: 0; top: 0; width: 1px; height: 1px; }
.shift { position: absolute; top: 0; }
.code { position: absolute; font-family: "Mono"; font-weight: 500; font-size: ${layout.monoSize}px; color: ${P.river}; opacity: ${P.riverOpacity}; white-space: nowrap; }
#lens { position: absolute; border-radius: ${radius}px; overflow: hidden; background: radial-gradient(ellipse at 50% 40%, ${P.lensCenter} 0%, ${P.lensEdge} 70%); box-shadow: 0 ${50 * u}px ${140 * u}px ${P.shadow}, 0 ${12 * u}px ${40 * u}px rgba(7,45,47,.25); }
#lens-inner { position: absolute; left: 0; top: 0; }
#lens-rim { position: absolute; inset: 0; border-radius: ${radius}px; box-shadow: inset 0 0 0 ${3 * u}px ${P.rim}, inset 0 ${30 * u}px ${80 * u}px rgba(255,255,255,.04); }
.node { position: absolute; display: flex; align-items: center; justify-content: center; border: ${4 * u}px solid rgb(${rgb(P.nodeStroke)}); background: ${P.node}; color: ${P.nodeInk}; font-family: "Sans"; font-weight: 700; font-size: ${layout.sansSize}px; white-space: nowrap; }
.node.terminal { border-radius: ${60 * u}px; }
.node.process { border-radius: ${10 * u}px; }
.node.io { border-radius: ${6 * u}px; transform: skewX(-${SKEW_DEGREES}deg); } .node.io span { display: inline-block; transform: skewX(${SKEW_DEGREES}deg); }
.node.decision { border-radius: ${64 * u}px; border-width: ${5 * u}px; }
.node.join { border-radius: 50%; background: ${P.join}; border-color: ${P.join}; }
.arrow { position: absolute; height: ${4 * u}px; background: ${P.arrow}; }
.arrow::after { content: ""; position: absolute; right: ${-2 * u}px; top: ${-9 * u}px; border-left: ${18 * u}px solid ${P.arrow}; border-top: ${11 * u}px solid transparent; border-bottom: ${11 * u}px solid transparent; }`;
}

export function lensScript(layout: LensLayout, durationSeconds: number): string {
  const { lens } = layout;
  const stroke = P.nodeStroke;
  const run = P.running;
  return `const DURATION=${durationSeconds},MIDDLE=${lens.x + lens.width / 2},GLOW=${lens.width * GLOW_WIDTH},UNIT=${layout.unit};
const rows=[...document.querySelectorAll(".row")];
const nodes=[...document.querySelectorAll("#lens .node")].map((node)=>[node,node.closest(".row")]);
const mix=(from,to,amount)=>Math.round(from+(to-from)*amount);
function render(time){
  rows.forEach((row)=>{const tile=Number(row.dataset.tile);const offset=((Number(row.dataset.phase)+tile*time/DURATION)%tile+tile)%tile;row.dataset.offset=String(offset);row.style.transform="translateX("+(-offset)+"px)";});
  nodes.forEach(([node,row])=>{const x=Number(node.dataset.center)-Number(row.dataset.offset);const glow=Math.exp(-Math.pow((x-MIDDLE)/GLOW,2));
    node.style.borderColor="rgb("+mix(${stroke.red},${run.red},glow)+","+mix(${stroke.green},${run.green},glow)+","+mix(${stroke.blue},${run.blue},glow)+")";
    node.style.boxShadow="0 0 "+(50*UNIT*glow)+"px rgba(${run.red},${run.green},${run.blue},"+(0.5*glow)+")";});
}`;
}

function rgb(color: { red: number; green: number; blue: number }): string {
  return `${color.red},${color.green},${color.blue}`;
}
