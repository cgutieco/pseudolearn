import { spawn } from "node:child_process";

export type ProcessResult = {
  readonly code: number;
  readonly stdout: Buffer;
  readonly stderr: string;
};

export function runProcess(command: string, args: readonly string[]): Promise<ProcessResult> {
  return new Promise((resolve) => {
    const child = spawn(command, [...args], { stdio: ["ignore", "pipe", "pipe"] });
    const stdout: Buffer[] = [];
    const stderr: Buffer[] = [];
    child.stdout.on("data", (chunk: Buffer) => stdout.push(chunk));
    child.stderr.on("data", (chunk: Buffer) => stderr.push(chunk));
    child.on("error", (error) => resolve({ code: -1, stdout: Buffer.alloc(0), stderr: error.message }));
    child.on("close", (code) => resolve({
      code: code ?? -1,
      stdout: Buffer.concat(stdout),
      stderr: Buffer.concat(stderr).toString("utf8"),
    }));
  });
}

export function failureOf(command: string, result: ProcessResult): string {
  const lastLines = result.stderr.trim().split("\n").slice(-4).join(" | ");
  return `${command} exited with ${result.code}: ${lastLines}`;
}
