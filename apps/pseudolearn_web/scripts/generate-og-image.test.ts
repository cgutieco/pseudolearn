import { copyFileSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import sharp from 'sharp';
import { afterEach, describe, expect, it } from 'vitest';
import {
  renderSocialCard,
  SOCIAL_CARD_HEIGHT,
  SOCIAL_CARD_OUTPUT,
  SOCIAL_CARD_SOURCE,
  SOCIAL_CARD_WIDTH,
} from './generate-og-image.mjs';

const projectRoot = join(dirname(fileURLToPath(import.meta.url)), '..');
const workDirectories: string[] = [];

function workDirectory(): string {
  const directory = mkdtempSync(join(tmpdir(), 'og-image-'));
  workDirectories.push(directory);
  return directory;
}

function withSource(directory: string, copySource: (target: string) => void): void {
  const target = join(directory, SOCIAL_CARD_SOURCE);
  mkdirSync(dirname(target), { recursive: true });
  copySource(target);
}

afterEach(() => {
  for (const directory of workDirectories.splice(0)) rmSync(directory, { recursive: true, force: true });
});

describe('renderSocialCard', () => {
  it('rasterizes the generated card into a PNG of the declared size', async () => {
    const directory = workDirectory();
    withSource(directory, (target) => copyFileSync(join(projectRoot, SOCIAL_CARD_SOURCE), target));
    const { outputPath } = await renderSocialCard(directory);
    const metadata = await sharp(readFileSync(outputPath)).metadata();
    expect([metadata.format, metadata.width, metadata.height]).toEqual([
      'png',
      SOCIAL_CARD_WIDTH,
      SOCIAL_CARD_HEIGHT,
    ]);
    expect(outputPath).toBe(join(directory, SOCIAL_CARD_OUTPUT));
  });

  it('paints the brand ground and keeps the corners opaque', async () => {
    const directory = workDirectory();
    withSource(directory, (target) => copyFileSync(join(projectRoot, SOCIAL_CARD_SOURCE), target));
    const { outputPath } = await renderSocialCard(directory);
    const { data, info } = await sharp(outputPath).raw().toBuffer({ resolveWithObject: true });
    const alphaAtTopLeft = data[info.channels - 1];
    expect(alphaAtTopLeft).toBe(255);
  });

  it('fails with the command that produces the source when the engine has not run', async () => {
    await expect(renderSocialCard(workDirectory())).rejects.toThrow('python3 -m pseudolearn_brand build');
  });

  it('rejects a source whose size no longer matches the Open Graph tags', async () => {
    const directory = workDirectory();
    withSource(directory, (target) =>
      writeFileSync(
        target,
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><rect width="100" height="100"/></svg>',
      ),
    );
    await expect(renderSocialCard(directory)).rejects.toThrow('100x100');
  });
});
