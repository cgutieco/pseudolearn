import { createHash } from "node:crypto";
import { access, copyFile, mkdir, readFile, writeFile } from "node:fs/promises";
import { createRequire } from "node:module";
import { dirname, join } from "node:path";
import type { FileStore } from "../pipeline/ports.ts";

const require = createRequire(import.meta.url);
const TIMELINE_LIBRARY_SOURCE = require.resolve("gsap/dist/gsap.min.js");
const TIMELINE_LIBRARY_NAME = "gsap.min.js";

export function nodeFileStore(): FileStore {
  return {
    ensureDirectory: async (path) => {
      await mkdir(path, { recursive: true });
    },
    writeText: async (path, content) => {
      await mkdir(dirname(path), { recursive: true });
      await writeFile(path, content, "utf8");
    },
    writeBytes: async (path, content) => {
      await mkdir(dirname(path), { recursive: true });
      await writeFile(path, content);
    },
    readBytes: async (path) => new Uint8Array(await readFile(path)),
    readBytesIfPresent: async (path) => (await pathExists(path)) ? new Uint8Array(await readFile(path)) : null,
    copyTimelineLibrary: async (directory) => {
      await copyFile(TIMELINE_LIBRARY_SOURCE, join(directory, TIMELINE_LIBRARY_NAME));
    },
    sha256: async (path) => createHash("sha256").update(await readFile(path)).digest("hex"),
    join: (...parts) => join(...parts),
  };
}

async function pathExists(path: string): Promise<boolean> {
  try {
    await access(path);
    return true;
  } catch {
    return false;
  }
}
