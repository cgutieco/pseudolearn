import { spawn } from "node:child_process";
import { createInterface } from "node:readline";
import type { ProcessLauncherPort, RunProcessPort } from "../contracts/editor_run";

export class NodeProcessLauncher implements ProcessLauncherPort {
  launch(executable: string, argumentsList: string[], workingDirectory: string): RunProcessPort {
    const child = spawn(executable, argumentsList, {
      cwd: workingDirectory,
      shell: false,
      env: {},
      stdio: ["pipe", "pipe", "pipe"],
    });
    const lines = createInterface({ input: child.stdout });
    child.stdin.on("error", () => undefined);
    child.stderr.resume();
    return {
      onLine: (listener) => lines.on("line", listener),
      onExit: (listener) => {
        child.on("close", (code) => listener(code));
        child.on("error", () => listener(null));
      },
      send: (line) => {
        if (child.stdin.writable) {
          child.stdin.write(`${line}\n`);
        }
      },
      terminate: () => {
        child.kill("SIGKILL");
      },
    };
  }
}
