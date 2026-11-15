import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import sharp from "sharp";

const extensionRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
export const ICON_SOURCE = "media/icons/pseudo-file.svg";
export const ICON_OUTPUT = "media/icon.png";
export const ICON_SIZE = 256;

export async function renderMarketplaceIcon(root = extensionRoot) {
  const bytes = await sharp(resolve(root, ICON_SOURCE), { density: 384 })
    .resize(ICON_SIZE, ICON_SIZE)
    .png({ compressionLevel: 9 })
    .toBuffer();
  const outputPath = resolve(root, ICON_OUTPUT);
  mkdirSync(dirname(outputPath), { recursive: true });
  writeFileSync(outputPath, bytes);
  return { outputPath, byteLength: bytes.byteLength };
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  try {
    const { byteLength } = await renderMarketplaceIcon();
    process.stdout.write(`${ICON_OUTPUT} ${byteLength} bytes\n`);
  } catch (error) {
    process.stderr.write(`${error instanceof Error ? error.message : String(error)}\nGenerate the source with the brand engine: python3 -m pseudolearn_brand build\n`);
    process.exitCode = 1;
  }
}
