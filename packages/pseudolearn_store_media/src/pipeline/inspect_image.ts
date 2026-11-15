import type { Slot } from "../catalog/catalog_types.ts";
import type { Finding } from "../audit/finding.ts";
import { auditImage } from "../audit/image_audit.ts";
import type { FileStore } from "./ports.ts";

export async function inspectImage(files: FileStore, slot: Slot, path: string): Promise<readonly Finding[]> {
  return auditImage({ slot, target: path, bytes: await files.readBytes(path) });
}
