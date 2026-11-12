import { describe, expect, it } from "vitest";
import { byteLength, errorRanges, outputSegments } from "../../src/application/debug_output";
import { displayValue } from "../../src/application/debug_values";

describe("debug output segments", () => {
  it("splits around error byte ranges in program order", () => {
    expect(outputSegments("ab\nERR\ncd\n", 0, [[3, 7]])).toEqual([["stdout", "ab\n"], ["stderr", "ERR\n"], ["stdout", "cd\n"]]);
    expect(outputSegments("ab\nERR\ncd\n", 7, [[3, 7]])).toEqual([["stdout", "cd\n"]]);
    expect(outputSegments("ab\nERR\n", 5, [[3, 7]])).toEqual([["stderr", "R\n"]]);
  });

  it("counts UTF-8 bytes and ignores malformed ranges", () => {
    expect(byteLength("ñ")).toBe(2);
    expect(outputSegments("ñx", 2, [])).toEqual([["stdout", "x"]]);
    expect(errorRanges(["bad", ["1"], ["2", "4"]] as never)).toEqual([[2, 4]]);
    expect(errorRanges(undefined)).toEqual([]);
    expect(outputSegments("", 0, [])).toEqual([]);
  });
});

describe("debug values", () => {
  it("shows text, absence, channels and references like the desktop adapter", () => {
    expect(displayValue({ valor: "20" }, undefined)).toBe("20");
    expect(displayValue({ nulo: true }, undefined)).toBe("nulo");
    expect(displayValue({ sin_valor: true }, undefined)).toBe("sin_valor");
    expect(displayValue({ canal: { identidad: "1", en_cola: "0", capacidad: "2", abierto: false } }, undefined)).toBe("canal(1) 0/2 cerrado");
    expect(displayValue({ ref: "4" }, "4")).toBe("referencia(4)");
    expect(displayValue({ canal: { identidad: "1" } }, undefined)).toBe("{\"identidad\":\"1\"}");
    expect(displayValue("7", undefined)).toBe("7");
  });
});
