import { describe, expect, it } from "vitest";
import { diagnosticCodeFrame } from "../../src/application/diagnostic_code_frame";

  it("expands tabs and underlines the same visual columns", () => {
    expect(diagnosticCodeFrame({
      text: "\tvalue",
      line: 1,
      startColumn: 2,
      endLine: 1,
      endColumn: 7,
      tabSize: 4,
    })).toBe("    1 |     value\n      |     ^^^^^");
  });

  it("aligns after a supplementary wide character", () => {
    expect(diagnosticCodeFrame({
      text: "😀x",
      line: 1,
      startColumn: 2,
      endLine: 1,
      endColumn: 3,
      tabSize: 4,
    })).toBe("    1 | 😀x\n      |   ^");
  });

  it("supports CRLF and a diagnostic at the end of a line", () => {
    expect(diagnosticCodeFrame({
      text: "first\r\nabc",
      line: 2,
      startColumn: 4,
      endLine: 2,
      endColumn: 4,
      tabSize: 4,
    })).toBe("    2 | abc\n      |    ^");
  });

  it("returns no frame for missing source text or a nonexistent line", () => {
    expect(diagnosticCodeFrame({
      line: 1,
      startColumn: 1,
      endLine: 1,
      endColumn: 2,
      tabSize: 4,
    })).toBeUndefined();
    expect(diagnosticCodeFrame({
      text: "one",
      line: 2,
      startColumn: 1,
      endLine: 2,
      endColumn: 2,
      tabSize: 4,
    })).toBeUndefined();
  });
