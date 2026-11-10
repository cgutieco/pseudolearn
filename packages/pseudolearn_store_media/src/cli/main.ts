import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { parseArgs } from "node:util";
import { LANGUAGES, type Catalog, type Language } from "../catalog/catalog_types.ts";
import { loadCatalog } from "../render/catalog_files.ts";
import { silenceTelemetry } from "../render/hyperframes_renderer.ts";
import { runAuditImage } from "./audit_image_command.ts";
import { runCalibrate } from "./calibrate_command.ts";
import { runCreative } from "./creative_command.ts";
import { runPlan } from "./plan_command.ts";
import { runPreviews } from "./previews_command.ts";
import { runScreenshots } from "./screenshots_command.ts";

const PACKAGE_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "../..");

export type CommandContext = {
  readonly catalog: Catalog;
  readonly packageRoot: string;
  readonly slotIds: readonly string[];
  readonly languages: readonly Language[];
  readonly file: string | undefined;
  readonly guides: boolean;
  readonly story: string | undefined;
  readonly plates: string | undefined;
  readonly write: (line: string) => void;
};

const COMMANDS: Readonly<Record<string, (context: CommandContext) => Promise<number>>> = {
  plan: runPlan,
  calibrate: runCalibrate,
  "audit-image": runAuditImage,
  screenshots: runScreenshots,
  previews: runPreviews,
  creative: runCreative,
};

async function main(argv: readonly string[]): Promise<number> {
  const { positionals, values } = parseArgs({
    args: [...argv],
    allowPositionals: true,
    options: {
      slot: { type: "string", multiple: true },
      lang: { type: "string", multiple: true },
      file: { type: "string" },
      story: { type: "string" },
      plates: { type: "string" },
      guides: { type: "boolean", default: false },
    },
  });
  const command = COMMANDS[positionals[0] ?? ""];
  if (!command) {
    process.stderr.write(`usage: media <${Object.keys(COMMANDS).join("|")}> [--slot id] [--lang es|en] [--file path] [--story path] [--plates dir] [--guides]\n`);
    return 2;
  }
  const loaded = await loadCatalog(PACKAGE_ROOT);
  if (!loaded.ok) {
    process.stderr.write(`${loaded.errors.map((error) => `${error.path}: ${error.message}`).join("\n")}\n`);
    return 1;
  }
  const languages = (values.lang ?? [...LANGUAGES]).filter((value): value is Language => (LANGUAGES as readonly string[]).includes(value));
  silenceTelemetry(process.env);
  return command({
    catalog: loaded.value,
    packageRoot: PACKAGE_ROOT,
    slotIds: values.slot ?? [],
    languages,
    file: values.file,
    guides: values.guides ?? false,
    story: values.story,
    plates: values.plates,
    write: (line) => process.stdout.write(`${line}\n`),
  });
}

process.exitCode = await main(process.argv.slice(2));
