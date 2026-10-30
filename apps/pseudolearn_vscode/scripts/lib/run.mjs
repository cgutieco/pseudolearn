import { spawnSync } from "node:child_process";

export function run(command, argumentsList, cwd) {
  const result = spawnSync(command, argumentsList, { cwd, encoding: "utf8", maxBuffer: 16 * 1024 * 1024, stdio: "pipe" });
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(result.stderr || `${command} exited with status ${result.status}`);
  return result.stdout;
}
