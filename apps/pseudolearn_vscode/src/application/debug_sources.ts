import type { DebugSourceSnapshot } from "../contracts/debug_session";

export class DebugSources {
  readonly snapshots = new Map<number, DebugSourceSnapshot & { revision?: string }>();
  linesStartAtOne = true;
  columnsStartAtOne = true;

  describe(identifier: number): unknown {
    const source = this.snapshots.get(identifier);
    if (!source) return null;
    const name = source.path.split(/[\\/]/).pop() ?? source.path;
    return { name, path: source.path, sourceReference: identifier + 1, presentationHint: "deemphasize",
      origin: "PseudoLearn snapshot", adapterData: { source_id: identifier, revision: source.revision ?? null } };
  }

  identifier(request: unknown): number {
    const source = request !== null && typeof request === "object" ? request as Record<string, unknown> : {};
    const reference = source.sourceReference;
    if (typeof reference === "number" && Number.isSafeInteger(reference) && reference > 0) {
      if (this.snapshots.has(reference - 1)) return reference - 1;
      throw new Error("unknown source reference");
    }
    if (typeof source.path !== "string") throw new Error("missing source");
    const wanted = comparable(source.path);
    for (const [identifier, snapshot] of this.snapshots) {
      if (comparable(snapshot.path) === wanted) return identifier;
    }
    throw new Error("source is outside execution snapshot");
  }

  location(identifier: number, line: number, column: number): [number, number] {
    const characters = [...this.line(identifier, line)].slice(0, Math.max(0, column - 1));
    const units = characters.reduce((total, character) => total + character.length, 0);
    return [Math.max(0, line - (this.linesStartAtOne ? 0 : 1)), units + (this.columnsStartAtOne ? 1 : 0)];
  }

  coreLocation(identifier: number, line: number, column: number): [number, number] {
    const coreLine = line + (this.linesStartAtOne ? 0 : 1);
    const units = column - (this.columnsStartAtOne ? 1 : 0);
    if (units < 0) throw new Error("invalid column");
    let consumed = 0;
    let scalars = 1;
    for (const character of this.line(identifier, coreLine)) {
      if (consumed === units) return [coreLine, scalars];
      consumed += character.length;
      scalars += 1;
    }
    if (consumed === units) return [coreLine, scalars];
    throw new Error("column is not a Unicode boundary");
  }

  private line(identifier: number, line: number): string {
    const text = this.snapshots.get(identifier)?.text ?? "";
    return (text.split("\n")[line - 1] ?? "").replace(/\r$/, "");
  }
}

function comparable(path: string): string {
  try {
    return decodeURIComponent(path);
  } catch {
    return path;
  }
}
