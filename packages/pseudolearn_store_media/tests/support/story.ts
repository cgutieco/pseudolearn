import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { parseScreenshotStory, type ScreenshotStory } from "../../src/story/screenshot_story.ts";

export function storyDocument(): Record<string, unknown> {
  return {
    id: "test-story",
    texture: { es: ["Mientras x > 0 Hacer"], en: ["while x > 0 do"] },
    chapters: [
      { id: "language", kind: "manifesto", plate: "chapter-idea", appTheme: "light", palette: "paper",
        headline: { es: "Esto ya es un\n*lenguaje.*", en: "This is now a\n*language.*" },
        subline: { es: "Escríbelo en español.", en: "Write it in English." },
        code: { es: ["Proceso Hola", "    Escribir \"Hola\";", "FinProceso"], en: ["algorithm Hello", "    write \"Hello\";", "endAlgorithm"] } },
      { id: "nodo", kind: "device", plate: "chapter-nodo", appTheme: "dark", palette: "deep",
        headline: { es: "Nodo *escribe.*", en: "Nodo *writes.*" },
        focus: "verified-code", pin: { x: 0.1, y: 0 }, note: { es: "Verificado", en: "Checked" } },
    ],
  };
}

function parsed(document: unknown): ScreenshotStory {
  const result = parseScreenshotStory(document);
  if (!result.ok) {
    throw new Error(result.errors.map((error) => `${error.path}: ${error.message}`).join("\n"));
  }
  return result.value;
}

export const TEST_STORY: ScreenshotStory = parsed(storyDocument());

export function shippedStory(): ScreenshotStory {
  return parsed(JSON.parse(readFileSync(fileURLToPath(new URL("../../stories/app-store-screenshots.json", import.meta.url)), "utf8")));
}

export function chapterOf(story: ScreenshotStory, id: string) {
  const chapter = story.chapters.find((entry) => entry.id === id);
  if (!chapter) {
    throw new Error(`no chapter ${id}`);
  }
  return chapter;
}
