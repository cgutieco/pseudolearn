import { inspectImage } from "../pipeline/inspect_image.ts";
import { nodeFileStore } from "../render/node_file_store.ts";
import type { CommandContext } from "./main.ts";

export async function runAuditImage(context: CommandContext): Promise<number> {
  const slot = context.catalog.slots.find((entry) => entry.id === context.slotIds[0]);
  if (!slot || !context.file || slot.video) {
    context.write("audit-image needs one --slot of an image kind and --file");
    return 2;
  }
  const findings = await inspectImage(nodeFileStore(), slot, context.file);
  findings.forEach((entry) => context.write(`${entry.rule} ${entry.target}: ${entry.message}`));
  context.write(findings.length === 0 ? `${context.file} accepted for ${slot.id}` : `${context.file} rejected for ${slot.id}`);
  return findings.length === 0 ? 0 : 1;
}
