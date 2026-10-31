export interface DiagnosticCodeFrameRequest {
  text?: string;
  line: number;
  startColumn: number;
  endLine: number;
  endColumn: number;
  tabSize: number;
}

export function diagnosticCodeFrame(request: DiagnosticCodeFrameRequest): string | undefined {
  const sourceLine = request.text?.split(/\r\n|\r|\n/)[request.line - 1];
  if (sourceLine === undefined) {
    return undefined;
  }
  const source = expandTabs(sourceLine, request.tabSize);
  const start = visualColumn(sourceLine, request.startColumn - 1, request.tabSize);
  const end = request.endLine === request.line
    ? visualColumn(sourceLine, request.endColumn - 1, request.tabSize)
    : visualColumn(sourceLine, Array.from(sourceLine).length, request.tabSize);
  const width = Math.max(1, end - start);
  const number = String(request.line);
  return `    ${number} | ${source}\n    ${" ".repeat(number.length)} | ${" ".repeat(start)}${"^".repeat(width)}`;
}

function expandTabs(line: string, tabSize: number): string {
  let column = 0;
  let output = "";
  for (const character of line) {
    const width = character === "\t" ? tabWidth(column, tabSize) : characterWidth(character);
    output += character === "\t" ? " ".repeat(width) : character;
    column += width;
  }
  return output;
}

function visualColumn(line: string, endIndex: number, tabSize: number): number {
  let column = 0;
  for (const character of Array.from(line).slice(0, endIndex)) {
    column += character === "\t" ? tabWidth(column, tabSize) : characterWidth(character);
  }
  return column;
}

function tabWidth(column: number, tabSize: number): number {
  const width = Number.isInteger(tabSize) && tabSize > 0 ? tabSize : 4;
  return width - (column % width);
}

function characterWidth(character: string): number {
  const point = character.codePointAt(0) ?? 0;
  if (point === 0xfeff || point === 0x200d || /\p{Mark}/u.test(character)) {
    return 0;
  }
  return isWideCharacter(point) ? 2 : 1;
}

function isWideCharacter(point: number): boolean {
  return point >= 0x1100 && point <= 0x115f
    || point === 0x2329 || point === 0x232a
    || point >= 0x2e80 && point <= 0xa4cf
    || point >= 0xac00 && point <= 0xd7a3
    || point >= 0xf900 && point <= 0xfaff
    || point >= 0xfe10 && point <= 0xfe6f
    || point >= 0xff00 && point <= 0xff60
    || point >= 0xffe0 && point <= 0xffe6
    || point >= 0x1f300 && point <= 0x1faff
    || point >= 0x20000 && point <= 0x3fffd;
}
