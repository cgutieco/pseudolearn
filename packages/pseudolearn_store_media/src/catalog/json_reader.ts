import type { CatalogError } from "./catalog_types.ts";

export type JsonObject = Readonly<Record<string, unknown>>;

export class JsonReader {
  readonly errors: CatalogError[] = [];

  object(value: unknown, path: string): JsonObject {
    if (typeof value === "object" && value !== null && !Array.isArray(value)) {
      return value as JsonObject;
    }
    this.fail(path, "expected an object");
    return {};
  }

  array(value: unknown, path: string): readonly unknown[] {
    if (Array.isArray(value)) {
      return value;
    }
    this.fail(path, "expected an array");
    return [];
  }

  text(value: unknown, path: string): string {
    if (typeof value === "string" && value.length > 0) {
      return value;
    }
    this.fail(path, "expected a non-empty string");
    return "";
  }

  number(value: unknown, path: string, range: { min: number; max: number }): number {
    if (typeof value === "number" && Number.isFinite(value) && value >= range.min && value <= range.max) {
      return value;
    }
    this.fail(path, `expected a number between ${range.min} and ${range.max}`);
    return range.min;
  }

  member<T extends string>(value: unknown, path: string, allowed: readonly T[]): T {
    if (typeof value === "string" && (allowed as readonly string[]).includes(value)) {
      return value as T;
    }
    this.fail(path, `expected one of ${allowed.join(", ")}`);
    return allowed[0] as T;
  }

  keys(value: JsonObject, path: string, allowed: readonly string[]): void {
    for (const key of Object.keys(value)) {
      if (!allowed.includes(key)) {
        this.fail(`${path}.${key}`, "unknown key");
      }
    }
  }

  fail(path: string, message: string): void {
    this.errors.push({ path, message });
  }
}
