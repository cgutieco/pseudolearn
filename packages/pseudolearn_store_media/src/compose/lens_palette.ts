import { BRAND_DEEP, BRAND_GROUND_BOTTOM } from "./brand.generated.ts";

export const LENS_PALETTE = {
  field: "#F7F4EC",
  river: BRAND_GROUND_BOTTOM,
  riverOpacity: 0.16,
  lensCenter: "#0C3B3E",
  lensEdge: BRAND_DEEP,
  rim: "rgba(149,209,212,.28)",
  node: "#0E3A3D",
  nodeInk: "#E6ECED",
  nodeStroke: { red: 149, green: 209, blue: 212 },
  running: { red: 242, green: 144, blue: 69 },
  join: "#6B8A8C",
  arrow: "#4AA4A8",
  shadow: "rgba(7,45,47,.38)",
} as const;

export function lensContrastPairs() {
  return [
    { role: "node label", foreground: LENS_PALETTE.nodeInk, background: LENS_PALETTE.node },
    { role: "node label on the lens", foreground: LENS_PALETTE.nodeInk, background: LENS_PALETTE.lensEdge },
  ];
}
