export type Run = { readonly text: string; readonly marked: boolean };

export type RunLines = readonly (readonly Run[])[];

const MARK = "*";

export function headlineRuns(text: string): RunLines | null {
  if (text.split(MARK).length % 2 === 0) {
    return null;
  }
  let marked = false;
  return text.split("\n").map((line) => {
    const runs: Run[] = [];
    line.split(MARK).forEach((part, index) => {
      if (index > 0) {
        marked = !marked;
      }
      if (part.length > 0) {
        runs.push({ text: part, marked });
      }
    });
    return runs;
  });
}

export function plainLines(text: string): readonly string[] {
  return text.replaceAll(MARK, "").split("\n");
}
