export const THERMOSTAT_PALETTE = {
  centre: "#11484B",
  edge: "#062628",
  code: "#95D1D4",
  current: "#FFFFFF",
  output: "#F7F4EC",
  number: "#FFFFFF",
  reached: "#F29045",
  bar: "rgba(149,209,212,.16)",
  conditionBar: "rgba(242,144,69,.30)",
} as const;

export function thermostatContrastPairs() {
  const P = THERMOSTAT_PALETTE;
  return [
    { role: "current line", foreground: P.current, background: P.centre },
    { role: "program output", foreground: P.output, background: P.centre },
    { role: "variable name", foreground: P.code, background: P.centre },
    { role: "variable value", foreground: P.number, background: P.centre },
    { role: "reached value and closing", foreground: P.reached, background: P.edge },
  ];
}
