export type TokenKind =
  | "comment"
  | "string"
  | "template"
  | "regex"
  | "identifier"
  | "number"
  | "punctuation";

export interface SourceToken {
  readonly kind: TokenKind;
  readonly text: string;
  readonly line: number;
}

const keywordsBeforeExpression = new Set([
  "return",
  "typeof",
  "instanceof",
  "in",
  "of",
  "new",
  "delete",
  "void",
  "throw",
  "case",
  "do",
  "else",
  "yield",
  "await",
]);

export function tokenize(source: string): SourceToken[] {
  return new SourceScanner(source).scanAll();
}

class SourceScanner {
  private index = 0;
  private line = 1;
  private braceDepth = 0;
  private readonly templateResumeDepths: number[] = [];
  private readonly tokens: SourceToken[] = [];

  constructor(private readonly source: string) {}

  scanAll(): SourceToken[] {
    while (this.index < this.source.length) this.scanNext();
    return this.tokens;
  }

  private scanNext(): void {
    const current = this.source[this.index];
    const next = this.source[this.index + 1];
    if (isWhitespace(current)) return this.skipWhitespace();
    if (current === "/" && next === "/") return this.scanLineComment();
    if (current === "/" && next === "*") return this.scanBlockComment();
    if (current === '"' || current === "'") return this.scanQuoted(current);
    if (current === "`") return this.scanTemplateChunk(this.index + 1);
    if (current === "/" && this.regexAllowed()) return this.scanRegex();
    if (isIdentifierStart(current)) return this.scanWhile("identifier", isIdentifierPart);
    if (isDigit(current)) return this.scanWhile("number", isIdentifierPart);
    this.scanPunctuation(current);
  }

  private skipWhitespace(): void {
    if (this.source[this.index] === "\n") this.line++;
    this.index++;
  }

  private scanLineComment(): void {
    const end = this.source.indexOf("\n", this.index);
    this.emit("comment", end === -1 ? this.source.length : end);
  }

  private scanBlockComment(): void {
    const close = this.source.indexOf("*/", this.index + 2);
    this.emit("comment", close === -1 ? this.source.length : close + 2);
  }

  private scanQuoted(quote: string): void {
    let cursor = this.index + 1;
    while (cursor < this.source.length && this.source[cursor] !== quote) {
      if (this.source[cursor] === "\n") break;
      cursor += this.source[cursor] === "\\" ? 2 : 1;
    }
    this.emit("string", Math.min(cursor + 1, this.source.length));
  }

  private scanTemplateChunk(contentStart: number): void {
    let cursor = contentStart;
    while (cursor < this.source.length) {
      const character = this.source[cursor];
      if (character === "\\") {
        cursor += 2;
      } else if (character === "`") {
        return this.emit("template", cursor + 1);
      } else if (character === "$" && this.source[cursor + 1] === "{") {
        this.templateResumeDepths.push(this.braceDepth);
        return this.emit("template", cursor + 2);
      } else {
        cursor++;
      }
    }
    this.emit("template", this.source.length);
  }

  private scanRegex(): void {
    let cursor = this.index + 1;
    let insideClass = false;
    while (cursor < this.source.length && this.source[cursor] !== "\n") {
      const character = this.source[cursor];
      if (character === "\\") {
        cursor += 2;
        continue;
      }
      if (character === "[") insideClass = true;
      if (character === "]") insideClass = false;
      if (character === "/" && !insideClass) break;
      cursor++;
    }
    cursor++;
    while (cursor < this.source.length && isIdentifierPart(this.source[cursor])) cursor++;
    this.emit("regex", Math.min(cursor, this.source.length));
  }

  private scanWhile(kind: TokenKind, accepts: (character: string) => boolean): void {
    let cursor = this.index;
    while (cursor < this.source.length && accepts(this.source[cursor])) cursor++;
    this.emit(kind, cursor);
  }

  private scanPunctuation(character: string): void {
    if (character === "{") this.braceDepth++;
    if (character === "}") {
      const resumeDepth = this.templateResumeDepths[this.templateResumeDepths.length - 1];
      if (resumeDepth === this.braceDepth) {
        this.templateResumeDepths.pop();
        return this.scanTemplateChunk(this.index + 1);
      }
      this.braceDepth--;
    }
    this.emit("punctuation", this.index + 1);
  }

  private regexAllowed(): boolean {
    const previous = this.tokens.findLast((token) => token.kind !== "comment");
    if (previous === undefined) return true;
    if (previous.kind === "identifier") return keywordsBeforeExpression.has(previous.text);
    if (previous.kind === "punctuation") return !")]}".includes(previous.text);
    return previous.kind === "template" && previous.text.endsWith("${");
  }

  private emit(kind: TokenKind, end: number): void {
    const text = this.source.slice(this.index, end);
    this.tokens.push({ kind, text, line: this.line });
    this.line += text.split("\n").length - 1;
    this.index = end;
  }
}

function isWhitespace(character: string): boolean {
  return character === " " || character === "\n" || character === "\t" || character === "\r";
}

function isDigit(character: string): boolean {
  return character >= "0" && character <= "9";
}

function isIdentifierStart(character: string): boolean {
  const lower = character.toLowerCase();
  return (lower >= "a" && lower <= "z") || character === "_" || character === "$";
}

function isIdentifierPart(character: string): boolean {
  return isIdentifierStart(character) || isDigit(character);
}
