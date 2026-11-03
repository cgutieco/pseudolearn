import type { DebugLaunch, DebugLaunchResult } from "../contracts/debug_session";

export function debugLaunch(configuration: Record<string, unknown>): DebugLaunchResult {
  if (configuration.stopOnEntry !== undefined && typeof configuration.stopOnEntry !== "boolean") {
    return { ok: false, reason: "options" };
  }
  if (configuration.backend !== undefined && configuration.backend !== "vm") {
    return { ok: false, reason: "backend" };
  }
  const authority = ["grants", "permissions", "origins", "filesRoot", "serverPath", "env"];
  if (authority.some((field) => configuration[field] !== undefined)) {
    return { ok: false, reason: "authority" };
  }
  if (configuration.args !== undefined && (!Array.isArray(configuration.args)
      || configuration.args.some((value: unknown) => typeof value !== "string"))) return { ok: false, reason: "options" };
  if (configuration.cwd !== undefined && !text(configuration.cwd)) return { ok: false, reason: "options" };
  const program = text(configuration.program);
  const project = text(configuration.project);
  if (Boolean(program) === Boolean(project)) {
    return { ok: false, reason: "target" };
  }
  const entry = text(configuration.entry);
  if (project && !entry) {
    return { ok: false, reason: "entry" };
  }
  return options(configuration, { ...(program ? { program } : { project, entry }), stopOnEntry: configuration.stopOnEntry !== false });
}

function options(configuration: Record<string, unknown>, value: DebugLaunch): DebugLaunchResult {
  const seed = configuration.seed;
  if (seed !== undefined && (typeof seed !== "string" || !/^(0|-?[1-9][0-9]*)$/.test(seed))) {
    return { ok: false, reason: "seed" };
  }
  if (seed !== undefined && (BigInt(seed) < -(1n << 63n) || BigInt(seed) >= (1n << 63n))) {
    return { ok: false, reason: "seed" };
  }
  if (configuration.profile !== undefined && !["es", "en"].includes(String(configuration.profile))) {
    return { ok: false, reason: "options" };
  }
  if (configuration.strictness !== undefined && !["strict", "flexible"].includes(String(configuration.strictness))) {
    return { ok: false, reason: "options" };
  }
  if (Array.isArray(configuration.args)) value.args = configuration.args as string[];
  if (text(configuration.cwd)) value.cwd = text(configuration.cwd);
  if (seed !== undefined) value.seed = seed;
  if (configuration.profile !== undefined) value.profile = configuration.profile as "es" | "en";
  if (configuration.strictness !== undefined) value.strictness = configuration.strictness as "strict" | "flexible";
  if (text(configuration.workspaceRoot)) value.workspaceRoot = text(configuration.workspaceRoot);
  return { ok: true, value };
}

function text(value: unknown): string | undefined {
  return typeof value === "string" && value.length > 0 ? value : undefined;
}
