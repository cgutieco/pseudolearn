import { describe, expect, it } from "vitest";
import {
  buildDiagnosticReport,
  countDiagnosticErrors,
  maximumStudentErrors,
  type DiagnosticReportSource,
} from "../../src/application/diagnostic_report";
import type { RunCompletion, RunEvent } from "../../src/contracts/editor_run";

type DiagnosticsEvent = Extract<RunEvent, { event: "diagnostics" }>;

const source = (sourceId: number, path: string, text?: string): DiagnosticReportSource => ({
  sourceId,
  path,
  label: path,
  text,
  tabSize: 4,
});

const diagnostic = (input: {
  message: string;
  line?: number;
  column?: number;
  sourceId?: number;
  severity?: string;
  endColumn?: number;
}) => ({
  code: "immutableBindingAssignment",
  class: "semantic",
  severity: input.severity ?? "error",
  message: input.message,
  span: {
    start: { line: input.line ?? 1, column: input.column ?? 1 },
    end: { line: input.line ?? 1, column: input.endColumn ?? (input.column ?? 1) + 1 },
    ...(input.sourceId === undefined ? {} : { source: { source_id: input.sourceId } }),
  },
  arguments: {},
  related: [],
});

const event = (
  diagnostics: unknown[],
  sources: DiagnosticsEvent["sources"] = [{ sourceId: 1, path: "hello.pseudo" }],
  projectErrors: unknown[] = [],
): DiagnosticsEvent => ({ event: "diagnostics", diagnostics, projectErrors, sources });

const completion: RunCompletion = {
  status: "failed",
  termination: null,
  diagnosticErrorCount: 1,
};

  it("returns no student report for an event without errors", () => {
    const report = buildDiagnosticReport(
      event([diagnostic({ message: "A warning", severity: "warning" })]),
      [source(1, "hello.pseudo", "x")],
      "es",
    );
    expect(report.text).toBe("");
    expect(report.errorCount).toBe(0);
    expect(report.problems[0]?.severity).toBe("warning");
  });

  it("renders one catalog message with its source line and range", () => {
    const report = buildDiagnosticReport(
      event([diagnostic({ message: "Catalog message", line: 1, column: 2 })]),
      [source(1, "hello.pseudo", "name <- 1")],
      "es",
      completion,
    );
    expect(report.text).toContain("No se ejecutó el programa: hay 1 error.");
    expect(report.text).toContain("Error en hello.pseudo, línea 1, columna 2:");
    expect(report.text).toContain("Catalog message");
    expect(report.text).toContain("    1 | name <- 1");
    expect(report.technicalLines[0]).toContain('"code":"immutableBindingAssignment"');
  });

  it("sorts diagnostics by file, line, and column", () => {
    const report = buildDiagnosticReport(
      event([
        diagnostic({ message: "second file", sourceId: 2 }),
        diagnostic({ message: "later line", line: 4, sourceId: 1 }),
        diagnostic({ message: "first column", line: 2, column: 3, sourceId: 1 }),
      ], [
        { sourceId: 1, path: "src/main.pseudo" },
        { sourceId: 2, path: "lib/math.pseudo" },
      ]),
      [
        source(1, "/workspace/src/main.pseudo", "a\nbc\n\nd"),
        source(2, "/workspace/lib/math.pseudo", "x"),
      ],
      "en",
    );
    expect(report.text.indexOf("lib/math.pseudo")).toBeLessThan(report.text.indexOf("src/main.pseudo"));
    expect(report.text.indexOf("first column")).toBeLessThan(report.text.indexOf("later line"));
  });

  it("limits student errors and reports the hidden count", () => {
    const diagnostics = Array.from({ length: maximumStudentErrors + 3 }, (_, index) =>
      diagnostic({ message: `Error ${index + 1}`, column: index + 1 }),
    );
    const report = buildDiagnosticReport(event(diagnostics), [source(1, "many.pseudo", "x".repeat(40))], "en");
    expect(report.errorCount).toBe(maximumStudentErrors + 3);
    expect(report.text).toContain("and 3 more");
    expect(report.text).toContain("Error 20");
    expect(report.text).not.toContain("Error 21");
    expect(report.technicalLines).toHaveLength(maximumStudentErrors + 3);
  });

  it("places a caret at the end of a line", () => {
    const report = buildDiagnosticReport(
      event([diagnostic({ message: "At end", column: 4, endColumn: 4 })]),
      [source(1, "end.pseudo", "abc")],
      "en",
    );
    expect(report.text).toContain("    1 | abc\n      |    ^");
  });

  it("omits a code frame when the reported line does not exist", () => {
    const report = buildDiagnosticReport(
      event([diagnostic({ message: "Missing line", line: 3, column: 2 })]),
      [source(1, "short.pseudo", "one\r\ntwo")],
      "en",
    );
    expect(report.text).toContain("Error in short.pseudo, line 3, column 2:");
    expect(report.text).not.toContain("    3 |");
  });

  it("omits a code frame when a source cannot be read", () => {
    const report = buildDiagnosticReport(
      event([diagnostic({ message: "Unreadable source" })]),
      [source(1, "binary.pseudo")],
      "es",
    );
    expect(report.text).toContain("Unreadable source");
    expect(report.text).not.toContain("    1 |");
  });

  it("expands tabs with the same stops in code and caret", () => {
    const report = buildDiagnosticReport(
      event([diagnostic({ message: "Tabbed name", column: 2, endColumn: 7 })]),
      [source(1, "tabs.pseudo", "\tvalue")],
      "es",
    );
    expect(report.text).toContain("    1 |     value\n      |     ^^^^^");
  });

  it("uses Unicode scalar columns for supplementary characters", () => {
    const report = buildDiagnosticReport(
      event([diagnostic({ message: "After emoji", column: 2, endColumn: 3 })]),
      [source(1, "unicode.pseudo", "😀x")],
      "es",
    );
    expect(report.text).toContain("    1 | 😀x\n      |   ^");
    expect(report.problems[0]?.character).toBe(2);
    expect(report.problems[0]?.endCharacter).toBe(3);
  });

  it("handles CRLF source without carrying the line ending into the frame", () => {
    const report = buildDiagnosticReport(
      event([diagnostic({ message: "Second line", line: 2, column: 2, endColumn: 3 })]),
      [source(1, "crlf.pseudo", "first\r\nsecond")],
      "en",
    );
    expect(report.text).toContain("    2 | second\n      |  ^");
  });

  it("localizes only its labels and keeps the catalog text unchanged", () => {
    const report = buildDiagnosticReport(
      event([diagnostic({ message: "El vínculo es inmutable" })]),
      [source(1, "hello.pseudo", "x")],
      "en",
      completion,
    );
    expect(report.text).toContain("The program was not run: 1 error.");
    expect(report.text).toContain("Error in hello.pseudo, line 1, column 1:");
    expect(report.text).toContain("El vínculo es inmutable");
  });

  it("keeps diagnostics in the Problems model when they are errors", () => {
    const report = buildDiagnosticReport(
      event([diagnostic({ message: "Problem" })]),
      [source(1, "/workspace/hello.pseudo", "x")],
      "es",
    );
    expect(report.problems).toEqual([
      expect.objectContaining({ path: "/workspace/hello.pseudo", line: 1, character: 0, severity: "error" }),
    ]);
  });

  it("bounds raw technical diagnostics and includes project errors there", () => {
    const report = buildDiagnosticReport(
      event([diagnostic({ message: "x".repeat(10_000) })], undefined, [{ code: "projectFailure" }]),
      [source(1, "large.pseudo", "x")],
      "es",
    );
    expect(report.technicalLines.join("\n").length).toBeLessThan(32_900);
    expect(report.technicalLines[0]).toContain("…");
    expect(report.technicalLines.join("\n")).toContain('"code":"projectFailure"');
    expect(report.text).not.toContain('"arguments"');
    const many = buildDiagnosticReport(
      event(Array.from({ length: 45 }, (_, index) => diagnostic({ message: `Error ${index}` }))),
      [source(1, "large.pseudo", "x")],
      "es",
    );
    expect(many.technicalLines).toHaveLength(41);
    expect(many.technicalLines[40]).toContain("records omitted");
  });

  it("does not call a finished run successful when its event also has errors", () => {
    const finishedWithErrors: RunCompletion = {
      status: "completed",
      termination: "completed",
      diagnosticErrorCount: countDiagnosticErrors(event([diagnostic({ message: "Mismatch" })])),
    };
    const report = buildDiagnosticReport(
      event([diagnostic({ message: "Mismatch" })]),
      [source(1, "inconsistent.pseudo", "x")],
      "es",
      finishedWithErrors,
    );
    expect(report.text).toContain("No se ejecutó el programa: hay 1 error.");
    expect(report.text).not.toContain("Ejecución completada.");
  });
