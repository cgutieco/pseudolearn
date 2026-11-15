import type { InterfaceLanguage } from "../contracts/extension_configuration";
import type { RunCompletion, RunEvent } from "../contracts/editor_run";
import { diagnosticCodeFrame } from "./diagnostic_code_frame";
import { finishLabel } from "./run_messages";

export const maximumStudentErrors = 20;

const maximumTechnicalRecords = 40;
const maximumTechnicalLineLength = 2048;
const maximumTechnicalLength = 32_768;

export interface DiagnosticReportSource {
  sourceId: number;
  path: string;
  label: string;
  text?: string;
  tabSize: number;
}

export interface DiagnosticReportProblem {
  path: string;
  line: number;
  character: number;
  endLine: number;
  endCharacter: number;
  message: string;
  code?: string;
  severity: "error" | "warning" | "information";
}

export interface DiagnosticReport {
  text: string;
  problems: DiagnosticReportProblem[];
  technicalLines: string[];
  errorCount: number;
}

interface Position {
  line: number;
  column: number;
}

interface ParsedDiagnostic {
  path: string;
  label: string;
  message: string;
  severity: DiagnosticReportProblem["severity"];
  code?: string;
  start: Position;
  end: Position;
  source?: DiagnosticReportSource;
}

export function countDiagnosticErrors(
  event: Extract<RunEvent, { event: "diagnostics" }>,
): number {
  return event.diagnostics.filter((entry) => recordOf(entry)?.severity === "error").length;
}

export function buildDiagnosticReport(
  event: Extract<RunEvent, { event: "diagnostics" }>,
  sources: DiagnosticReportSource[],
  language: InterfaceLanguage,
  completion?: RunCompletion,
): DiagnosticReport {
  const diagnostics = parsedDiagnostics(event, sources, language);
  const errors = diagnostics.filter((diagnostic) => diagnostic.severity === "error");
  const errorCount = countDiagnosticErrors(event);
  const visibleErrors = errors.slice(0, maximumStudentErrors);
  return {
    text: studentText(visibleErrors, errorCount, language, completion),
    problems: diagnostics.map(problemOf),
    technicalLines: technicalLines(event),
    errorCount,
  };
}

function parsedDiagnostics(
  event: Extract<RunEvent, { event: "diagnostics" }>,
  sources: DiagnosticReportSource[],
  language: InterfaceLanguage,
): ParsedDiagnostic[] {
  return event.diagnostics
    .map((entry) => parseDiagnostic(entry, sources, language))
    .filter((entry): entry is ParsedDiagnostic => entry !== undefined)
    .sort(compareDiagnostics);
}

function parseDiagnostic(
  value: unknown,
  sources: DiagnosticReportSource[],
  language: InterfaceLanguage,
): ParsedDiagnostic | undefined {
  const diagnostic = recordOf(value);
  const span = recordOf(diagnostic?.span);
  const start = positionOf(span?.start);
  const end = positionOf(span?.end) ?? start;
  const message = diagnostic?.message;
  const severity = severityOf(diagnostic?.severity);
  if (!diagnostic || !start || !end || typeof message !== "string" || !severity) {
    return undefined;
  }
  const source = sourceOf(span, sources);
  return {
    path: source?.path ?? "",
    label: source?.label ?? unknownFileLabel(language),
    message,
    severity,
    code: typeof diagnostic.code === "string" ? diagnostic.code : undefined,
    start,
    end,
    source,
  };
}

function sourceOf(
  span: Record<string, unknown> | undefined,
  sources: DiagnosticReportSource[],
): DiagnosticReportSource | undefined {
  const identity = recordOf(span?.source);
  const sourceId = identity?.source_id;
  if (typeof sourceId === "number") {
    return sources.find((source) => source.sourceId === sourceId);
  }
  return sources.length === 1 ? sources[0] : undefined;
}

function positionOf(value: unknown): Position | undefined {
  const position = recordOf(value);
  const { line, column } = position ?? {};
  if (!positiveInteger(line) || !positiveInteger(column)) {
    return undefined;
  }
  return { line, column };
}

function positiveInteger(value: unknown): value is number {
  return typeof value === "number" && Number.isInteger(value) && value > 0;
}

function severityOf(value: unknown): DiagnosticReportProblem["severity"] | undefined {
  if (value === "error") {
    return "error";
  }
  if (value === "warning") {
    return "warning";
  }
  return value === "info" ? "information" : undefined;
}

function compareDiagnostics(left: ParsedDiagnostic, right: ParsedDiagnostic): number {
  return compareText(left.label, right.label)
    || left.start.line - right.start.line
    || left.start.column - right.start.column;
}

function compareText(left: string, right: string): number {
  return left < right ? -1 : left > right ? 1 : 0;
}

function problemOf(diagnostic: ParsedDiagnostic): DiagnosticReportProblem {
  return {
    path: diagnostic.path,
    line: diagnostic.start.line,
    character: utf16Column(diagnostic.source, diagnostic.start),
    endLine: diagnostic.end.line,
    endCharacter: utf16Column(diagnostic.source, diagnostic.end),
    message: diagnostic.message,
    code: diagnostic.code,
    severity: diagnostic.severity,
  };
}

function utf16Column(source: DiagnosticReportSource | undefined, position: Position): number {
  const line = source?.text?.split(/\r\n|\r|\n/)[position.line - 1];
  if (line === undefined) {
    return position.column - 1;
  }
  return Array.from(line).slice(0, position.column - 1).join("").length;
}

function studentText(
  errors: ParsedDiagnostic[],
  errorCount: number,
  language: InterfaceLanguage,
  completion?: RunCompletion,
): string {
  if (errorCount === 0) {
    return "";
  }
  const summary = completion
    ? finishLabel({ ...completion, diagnosticErrorCount: errorCount }, language)
    : genericErrorLabel(errorCount, language);
  const entries = errors.map((diagnostic) => studentEntry(diagnostic, language));
  const hiddenCount = errorCount - errors.length;
  if (hiddenCount > 0) {
    entries.push(moreErrorsLabel(hiddenCount, language));
  }
  return [summary, ...entries].join("\n\n");
}

function studentEntry(diagnostic: ParsedDiagnostic, language: InterfaceLanguage): string {
  const location = locationLabel(diagnostic, language);
  const frame = codeFrame(diagnostic);
  return frame
    ? `${location}\n  ${diagnostic.message}\n${frame}`
    : `${location}\n  ${diagnostic.message}`;
}

function locationLabel(diagnostic: ParsedDiagnostic, language: InterfaceLanguage): string {
  return language === "es"
    ? `Error en ${diagnostic.label}, línea ${diagnostic.start.line}, columna ${diagnostic.start.column}:`
    : `Error in ${diagnostic.label}, line ${diagnostic.start.line}, column ${diagnostic.start.column}:`;
}

function codeFrame(diagnostic: ParsedDiagnostic): string | undefined {
  return diagnosticCodeFrame({
    text: diagnostic.source?.text,
    line: diagnostic.start.line,
    startColumn: diagnostic.start.column,
    endLine: diagnostic.end.line,
    endColumn: diagnostic.end.column,
    tabSize: diagnostic.source?.tabSize ?? 4,
  });
}

function genericErrorLabel(count: number, language: InterfaceLanguage): string {
  if (language === "es") {
    return count === 1 ? "Se encontró 1 error." : `Se encontraron ${count} errores.`;
  }
  return count === 1 ? "Found 1 error." : `Found ${count} errors.`;
}

function moreErrorsLabel(count: number, language: InterfaceLanguage): string {
  return language === "es" ? `y ${count} más` : `and ${count} more`;
}

function unknownFileLabel(language: InterfaceLanguage): string {
  return language === "es" ? "archivo desconocido" : "unknown file";
}

function technicalLines(
  event: Extract<RunEvent, { event: "diagnostics" }>,
): string[] {
  const records = [
    ...event.diagnostics.map((value) => ({ label: "diagnostic", value })),
    ...event.projectErrors.map((value) => ({ label: "project error", value })),
  ];
  const lines: string[] = [];
  let length = 0;
  for (const [index, entry] of records.slice(0, maximumTechnicalRecords).entries()) {
    const raw = boundedSerialization(entry.value);
    const line = `${entry.label} ${index + 1}: ${raw}`;
    if (length + line.length + 1 > maximumTechnicalLength) {
      break;
    }
    lines.push(line);
    length += line.length + 1;
  }
  const omitted = records.length - lines.length;
  if (omitted > 0) {
    const note = `${omitted} diagnostic records omitted`;
    const available = maximumTechnicalLength - length - 1;
    if (available > 0) {
      lines.push(note.slice(0, available));
    }
  }
  return lines;
}

function boundedSerialization(value: unknown): string {
  const raw = serialized(value);
  return raw.length > maximumTechnicalLineLength
    ? `${raw.slice(0, maximumTechnicalLineLength - 1)}…`
    : raw;
}

function serialized(value: unknown): string {
  try {
    return JSON.stringify(value) ?? String(value);
  } catch {
    return String(value);
  }
}

function recordOf(value: unknown): Record<string, unknown> | undefined {
  return typeof value === "object" && value !== null && !Array.isArray(value)
    ? value as Record<string, unknown>
    : undefined;
}
