import { copyFileSync, cpSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { hash } from "./lib/web-artifact.mjs";
import { validatePhysical } from "./lib/web-measurements.mjs";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const output = resolve(root, ".artifacts/physical-kit");

function combinations() {
  const dimensions = [["safari-iphone", "chrome-android"], ["vscode.dev", "github.dev"],
    ["touch", "physical"], ["file", "project"], ["normal", "loss"]];
  const rows = dimensions.reduce((rows, values) => rows.flatMap((row) => values.map((value) => [...row, value])), [[]]);
  return rows.map(([phone, host, keyboard, load, network]) => ({ id: [phone, host, keyboard, load, network].join("/"), phone, host, keyboard, load, network }));
}

function instructions() {
  return ["# E-PG-08 · Kit físico", "",
    "Material preparado; no acredita ensayos físicos. La instalación requiere un mecanismo de carga permitido por cada host; no se publica ni se usan cuentas ajenas.", "",
    "Registrar dispositivo, SO, navegador/build, host/proveedor y método de teclado. Para cada combinación completar veinte ciclos: abrir, escribir el texto final previsto, formatear, guardar y comprobar contenido, ejecutar, entregar entrada y detener.", "",
    "Conservar textos y hashes, salida, terminación, red normal/pérdida y recuperaciones. La confirmación del proveedor no acredita persistencia tras cierre, expulsión u offline. Registrar esas observaciones por separado.", "",
    "Medir edición y cancelación en milisegundos. Ejecutar el control con el mismo teléfono, carga y Wasm. RAM total: null cuando no exista método fiable; la memoria lineal de Wasm no es RAM del editor.", "",
    "Exportar filas reales en results.json; no completar resultados con los formularios vacíos. Ejecutar node scripts/physical-kit.mjs analyze <results.json>. La ausencia física conserva el diferimiento autorizado y CF-14 pendiente.", ""].join("\n");
}

function sources() {
  mkdirSync(resolve(output, "file"), { recursive: true });
  const initial = "Algoritmo Probe\nDefinir Mutable number Como Entero <- 0;\nLeer number;\nEscribir number;\nFinAlgoritmo\n";
  const final = initial.replace("Escribir number;", "Escribir number * 2;");
  writeFileSync(resolve(output, "file/initial.pseudo"), initial);
  writeFileSync(resolve(output, "file/final.pseudo"), final);
  cpSync(resolve(root, "tests/fixtures/web/project"), resolve(output, "project"), { recursive: true });
  const project = resolve(output, "project/app/main.pseudo");
  const projectInitial = readFileSync(project, "utf8");
  writeFileSync(resolve(output, "project-final-main.pseudo"), projectInitial.replace("<- 21", "<- 42"));
  return { file: { initialSha256: hash(resolve(output, "file/initial.pseudo")), finalSha256: hash(resolve(output, "file/final.pseudo")), input: "21", output: "42\n" },
    project: { initialSha256: hash(project), finalSha256: hash(resolve(output, "project-final-main.pseudo")), output: "84\n" } };
}

function generate() {
  mkdirSync(resolve(output, "control"), { recursive: true });
  const stage = resolve(root, ".artifacts/web-extension/dist/web/wasm");
  for (const name of ["pseudolearn_wasm.js", "pseudolearn_wasm_bg.wasm"]) copyFileSync(resolve(stage, name), resolve(output, "control", name));
  copyFileSync(resolve(root, "tests/web/physical-control.html"), resolve(output, "control/index.html"));
  const kit = { schema: 1, physical: false, cycles: 20, combinations: combinations(), sources: sources(),
    wasmSha256: hash(resolve(output, "control/pseudolearn_wasm_bg.wasm")), controlSha256: hash(resolve(output, "control/index.html")),
    criteria: { textLoss: 0, editingP95Milliseconds: 150, cancellationMilliseconds: 250, runtimeRatio: 3 } };
  writeFileSync(resolve(output, "manifest.json"), `${JSON.stringify(kit, null, 2)}\n`);
  writeFileSync(resolve(output, "forms.json"), `${JSON.stringify(kit.combinations.map((combination) => ({ ...combination,
    device: null, operatingSystem: null, browserBuild: null, provider: null,
    cycles: Array.from({ length: kit.cycles }, (_, index) => ({ cycle: index + 1, result: null })) })), null, 2)}\n`);
  writeFileSync(resolve(output, "README.md"), instructions());
  process.stdout.write(`${output}\n`);
}

if (process.argv[2] === "analyze") {
  const kit = JSON.parse(readFileSync(resolve(output, "manifest.json"), "utf8"));
  const rows = JSON.parse(readFileSync(resolve(process.argv[3]), "utf8"));
  const result = validatePhysical(rows, kit);
  writeFileSync(resolve(output, "analysis.json"), `${JSON.stringify(result, null, 2)}\n`);
  process.stdout.write(`${JSON.stringify(result)}\n`);
} else generate();
