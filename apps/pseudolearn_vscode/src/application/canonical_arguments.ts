export class NumericText {
  constructor(readonly text: string) {}
}

export function numeric(text: string): NumericText {
  if (!/^-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][+-]?[0-9]+)?$/.test(text)) {
    throw new Error("Noncanonical numeric token");
  }
  return new NumericText(text);
}

export function encodeArguments(value: unknown): string {
  if (value instanceof NumericText) return value.text;
  if (Array.isArray(value)) return `[${value.map(encodeArguments).join(",")}]`;
  if (value !== null && typeof value === "object") {
    return `{${Object.entries(value).filter(([, entry]) => entry !== undefined)
      .map(([key, entry]) => `${JSON.stringify(key)}:${encodeArguments(entry)}`).join(",")}}`;
  }
  if (typeof value === "number" && !Number.isSafeInteger(value)) {
    throw new Error("Unsafe control number");
  }
  const encoded = JSON.stringify(value);
  if (encoded === undefined) throw new Error("Unsupported wire value");
  return encoded;
}
