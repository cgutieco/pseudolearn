import { isRecord } from "../../agent-responses/domain/credits.ts";

export function priceIdsOf(data: Record<string, unknown>): string[] {
  const items = Array.isArray(data.items) ? data.items : [];
  return items.flatMap((item) => {
    const price = isRecord(item) && isRecord(item.price) ? item.price : {};
    const id = textOf(price.id) ?? (isRecord(item) ? textOf(item.price_id) : null);
    return id === null ? [] : [id];
  });
}

export function textOf(value: unknown): string | null {
  return typeof value === "string" && value.length > 0 ? value : null;
}

export function dateOf(value: unknown): Date | null {
  if (typeof value !== "string") return null;
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}
