import { execFile } from "node:child_process";
import type { CommandRunnerPort } from "../contracts/editor_documents";

const maximumBuffer = 8 * 1024 * 1024;

export class NodeCommandRunner implements CommandRunnerPort {
  run(
    executable: string,
    argumentsList: string[],
    workingDirectory: string,
  ): Promise<{ code: number | null; stdout: string }> {
    return new Promise((resolve) => {
      execFile(
        executable,
        argumentsList,
        { cwd: workingDirectory, env: {}, maxBuffer: maximumBuffer, shell: false },
        (error, stdout) => {
          const code = error ? (typeof error.code === "number" ? error.code : null) : 0;
          resolve({ code, stdout: String(stdout) });
        },
      );
    });
  }
}
