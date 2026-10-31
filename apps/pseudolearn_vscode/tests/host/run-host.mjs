import { spawnSync } from "node:child_process";
import { cpSync, existsSync, mkdirSync, mkdtempSync, readFileSync, realpathSync, rmSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const extensionRoot = resolve(here, "../..");
const application = "/Applications/Visual Studio Code.app/Contents/MacOS/Code";
const commandLine = "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code";
const mode = process.argv[2] === "restricted" ? "restricted" : "trusted";
const vsix = resolve(extensionRoot, process.argv[3] ?? ".artifacts/pseudolearn-0.1.0-darwin-arm64.vsix");
const base = mkdtempSync(join(realpathSync(process.env.PSEUDOLEARN_HOST_TMP ?? "/tmp"), "ps ñandú "));
const userData = join(base, "user data");
const extensions = join(base, "extensions");
const workspace = join(base, "espacio áéí");
const developmentPath = join(base, "development");
const resultPath = join(base, "result.json");

cpSync(join(extensionRoot, "examples/project"), workspace, { recursive: true });
cpSync(join(extensionRoot, "examples/file/saludo.pseudo"), join(base, "saludo.pseudo"));
mkdirSync(developmentPath, { recursive: true });
writeFileSync(join(developmentPath, "package.json"), JSON.stringify({ name: "host-tests", publisher: "local", version: "0.0.0", engines: { vscode: "^1.144.0" } }));

const transcriptDirectory = process.env.PSEUDOLEARN_HOST_TRANSCRIPT;
const bundledServer = join(extensions, "pseudolearn.pseudolearn-vscode-0.1.0/bin/darwin-arm64/pseudo");
const environment = { PATH: "/usr/bin:/bin", HOME: process.env.HOME, TMPDIR: process.env.TMPDIR };
const install = spawnSync(commandLine, ["--user-data-dir", userData, "--extensions-dir", extensions, "--install-extension", vsix], { env: environment, encoding: "utf8" });
process.stdout.write(install.stdout + install.stderr);

if (transcriptDirectory) {
  mkdirSync(transcriptDirectory, { recursive: true });
  const wrapper = join(base, "pseudo-tee.sh");
  writeFileSync(wrapper, `#!/bin/bash\nif [ "$1" != "lsp" ]; then exec "${bundledServer}" "$@"; fi\n/usr/bin/tee -a "${transcriptDirectory}/client-to-server.log" | "${bundledServer}" "$@" | /usr/bin/tee -a "${transcriptDirectory}/server-to-client.log"\n`, { mode: 0o755 });
  mkdirSync(join(userData, "User"), { recursive: true });
  writeFileSync(join(userData, "User/settings.json"), JSON.stringify({ "pseudolearn.server.path": wrapper }));
  environment.NODE_ENV = "development";
}

const launch = spawnSync(
  application,
  ["--user-data-dir", userData, "--extensions-dir", extensions, `--extensionDevelopmentPath=${developmentPath}`, `--extensionTestsPath=${join(here, "suite.cjs")}`, "--no-sandbox", "--disable-gpu", "--disable-updates", "--skip-welcome", "--skip-release-notes", "--disable-telemetry", ...(mode === "trusted" ? ["--disable-workspace-trust"] : []), workspace],
  { env: { ...environment, PSEUDOLEARN_HOST_MODE: mode, PSEUDOLEARN_HOST_RESULT: resultPath, PSEUDOLEARN_HOST_EXTENSIONS: extensions,
    ...(process.env.PSEUDOLEARN_HOST_DAP_REPORT ? { PSEUDOLEARN_HOST_DAP_REPORT: resolve(process.env.PSEUDOLEARN_HOST_DAP_REPORT) } : {}) }, encoding: "utf8", timeout: 300000 },
);
process.stdout.write(launch.stdout ?? "");
process.stderr.write((launch.stderr ?? "").split("\n").filter((line) => !line.includes("ERROR:")).slice(-20).join("\n"));
const report = existsSync(resultPath) ? JSON.parse(readFileSync(resultPath, "utf8")) : undefined;
if (report) {
  for (const item of report.checks) process.stdout.write(`${item.ok ? "PASS" : "FAIL"} ${item.name}${item.detail ? ` :: ${item.detail.split("\n")[0]}` : ""}\n`);
  process.stdout.write(`mode=${report.mode} trusted=${report.trusted}\n`);
}
process.stdout.write(`status=${launch.status} base=${base}\n`);
if (process.env.PSEUDOLEARN_HOST_KEEP !== "1") rmSync(base, { recursive: true, force: true });
process.exitCode = launch.status === 0 && report && report.checks.every((item) => item.ok) ? 0 : 1;
