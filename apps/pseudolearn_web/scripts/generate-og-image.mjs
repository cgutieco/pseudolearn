import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { cwd } from 'node:process';
import sharp from 'sharp';
import { isEntryPoint } from './lib/cli.mjs';

export const SOCIAL_CARD_SOURCE = 'src/assets/brand/social-card.svg';
export const SOCIAL_CARD_OUTPUT = 'public/og-image.png';
export const SOCIAL_CARD_WIDTH = 1200;
export const SOCIAL_CARD_HEIGHT = 630;

export async function renderSocialCard(rootDirectory) {
  const sourcePath = join(rootDirectory, SOCIAL_CARD_SOURCE);
  if (!existsSync(sourcePath)) {
    throw new Error(
      `Falta ${SOCIAL_CARD_SOURCE}. Genéralo con el motor de marca: python3 -m pseudolearn_brand build (en packages/pseudolearn_brand).`,
    );
  }
  const { width, height } = await sharp(sourcePath).metadata();
  if (width !== SOCIAL_CARD_WIDTH || height !== SOCIAL_CARD_HEIGHT) {
    throw new Error(
      `${SOCIAL_CARD_SOURCE} mide ${width}x${height} y las etiquetas Open Graph declaran ${SOCIAL_CARD_WIDTH}x${SOCIAL_CARD_HEIGHT}.`,
    );
  }
  const bytes = await sharp(sourcePath).png({ compressionLevel: 9 }).toBuffer();
  const outputPath = join(rootDirectory, SOCIAL_CARD_OUTPUT);
  mkdirSync(dirname(outputPath), { recursive: true });
  writeFileSync(outputPath, bytes);
  return { outputPath, byteLength: bytes.byteLength };
}

async function main() {
  try {
    const { byteLength } = await renderSocialCard(cwd());
    console.log(`✔ ${SOCIAL_CARD_OUTPUT} — ${byteLength} bytes`);
  } catch (error) {
    console.error(`✖ generate:og-image — ${error.message}`);
    process.exitCode = 1;
  }
}

if (isEntryPoint(import.meta.url)) await main();
