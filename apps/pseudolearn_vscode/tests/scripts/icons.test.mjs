import { existsSync, mkdtempSync, mkdirSync, readFileSync, copyFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import sharp from "sharp";
import { describe, expect, it } from "vitest";
import { ICON_OUTPUT, ICON_SIZE, ICON_SOURCE, renderMarketplaceIcon } from "../../scripts/generate-icon.mjs";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const manifest = JSON.parse(readFileSync(resolve(root, "package.json"), "utf8"));
const themePath = resolve(root, "media/icons/pseudolearn-icon-theme.json");
const theme = JSON.parse(readFileSync(themePath, "utf8"));

describe("Extension icons", () => {
  it("declares the Marketplace icon, the language icon and the icon theme", () => {
    expect(manifest.icon).toBe(ICON_OUTPUT);
    expect(manifest.contributes.languages[0].icon).toBeDefined();
    expect(manifest.contributes.iconThemes.map((entry) => entry.id)).toContain("pseudolearn-icons");
  });

  it("points every icon definition of the theme at an existing file", () => {
    for (const definition of Object.values(theme.iconDefinitions)) {
      expect(existsSync(resolve(dirname(themePath), definition.iconPath))).toBe(true);
    }
  });

  it("maps the pseudo extension and the language id to the brand icon", () => {
    expect(theme.fileExtensions.pseudo).toBe("pseudoFile");
    expect(theme.languageIds.pseudolearn).toBe("pseudoFile");
    expect(theme.iconDefinitions.pseudoFile.iconPath).toBe("./pseudo-file.svg");
  });

});

describe("Marketplace icon rendering", () => {
  it("renders the Marketplace icon as a square PNG from the brand SVG", async () => {
    const scratch = mkdtempSync(join(tmpdir(), "pseudolearn-icon-"));
    try {
      mkdirSync(join(scratch, "media/icons"), { recursive: true });
      copyFileSync(resolve(root, ICON_SOURCE), join(scratch, ICON_SOURCE));
      const { outputPath } = await renderMarketplaceIcon(scratch);
      const { width, height, format } = await sharp(outputPath).metadata();
      expect([width, height, format]).toEqual([ICON_SIZE, ICON_SIZE, "png"]);
    } finally {
      rmSync(scratch, { recursive: true, force: true });
    }
  });

  it("fails when the brand SVG is missing", async () => {
    const scratch = mkdtempSync(join(tmpdir(), "pseudolearn-icon-"));
    try {
      await expect(renderMarketplaceIcon(scratch)).rejects.toThrow();
    } finally {
      rmSync(scratch, { recursive: true, force: true });
    }
  });
});
