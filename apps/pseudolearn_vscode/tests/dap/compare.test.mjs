import { expect, it } from "vitest";
import { compare } from "./compare.mjs";

const projection = { thread: "Task 1", frames: [{ name: "Double", source: "$ROOT/app/math.pseudo", revision: "p1.r1.f2", line: 2, column: 1 }],
  variables: [{ name: "number", value: "20", type: "entero" }], expression: "21", largest: "9223372036854775807",
  source: "Retornar number * 2;", historicalReason: "step", historicalFrames: [{ name: "Work", line: 3, column: 1 }] };

it("accepts identical projections and rejects every changed observable", () => {
  compare(projection, structuredClone(projection));
  const changes = [
    (value) => { value.thread = "Task 2"; },
    (value) => { value.frames[0].source = "$ROOT/app/other.pseudo"; },
    (value) => { value.frames[0].revision = "p1.r2.f2"; },
    (value) => { value.frames[0].line = 3; },
    (value) => { value.frames[0].column = 2; },
    (value) => { value.expression = "22"; },
    (value) => { value.variables[0].value = "21"; },
    (value) => { value.historicalReason = "exception"; },
    (value) => { value.source += "modified"; },
    (value) => { value.historicalFrames.reverse(); value.historicalFrames.push({ name: "Extra" }); },
  ];
  for (const change of changes) {
    const modified = structuredClone(projection);
    change(modified);
    expect(() => compare(projection, modified)).toThrow();
  }
});
