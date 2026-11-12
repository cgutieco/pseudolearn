import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";

function walk(root, relative = "") {
  return readdirSync(join(root, relative)).flatMap((name) => {
    const path = join(relative, name);
    return statSync(join(root, path)).isDirectory() ? walk(root, path) : [path];
  });
}

export function projectFrom(root) {
  const files = [];
  const manifests = [];
  for (const path of walk(root).sort()) {
    const text = readFileSync(join(root, path), "utf8");
    if (path.endsWith(".pseudo")) files.push({ path: path.slice(0, -".pseudo".length), source_id: files.length + 1, text });
    else manifests.push({ location: path.slice(0, path.lastIndexOf("/")), text });
  }
  return { project_id: "1", revision_id: "1", manifests, files };
}

const growth = "Algoritmo Memoria\nDefinir lista Como Vector<Entero> <- Vector();\nDefinir contador Como Entero <- 0;\nMientras contador < 4000 Hacer\nlista.Agregar(contador);\ncontador <- contador + 1;\nFinMientras\nEscribir lista.Longitud();\nFinAlgoritmo\n";
const request = "Algoritmo Red\nSegun SolicitarRed() Hacer\nExito(net):\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/ok\")) Hacer\nExito(response): Escribir response.Estado(); Escribir response.Cuerpo().Longitud();\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";
const valid = "Algoritmo Probe\nEscribir \"ok\";\nFinAlgoritmo\n";

export function workloads(fixtureRoot) {
  return [
    { name: "integer-extreme", source: "Algoritmo Probe\nEscribir 9223372036854775807;\nFinAlgoritmo\n", expected: "9223372036854775807\n" },
    { name: "loop", source: "Algoritmo Probe\nDefinir total Como Entero <- 0;\nMientras total < 1000 Hacer\ntotal <- total + 1;\nFinMientras\nEscribir total;\nFinAlgoritmo\n", expected: "1000\n" },
    { name: "cancellation", source: "Algoritmo Probe\nMientras Verdadero Hacer\nFinMientras\nFinAlgoritmo\n", expected: "", cancel: true },
    { name: "project", kind: "project", project: projectFrom(join(fixtureRoot, "es/proyecto")), expected: "ñandú 🌍\n42\n" },
    { name: "edit", kind: "edit", source: valid, expected: "edits:20 diagnostics:0\n" },
    { name: "memory-growth", source: growth, expected: "4000\n" },
    { name: "http-simulated", source: request, expected: "200\n2\n", network: true },
    { name: "startup-warm", source: valid, expected: "ok\n" },
    { name: "startup-cold", source: valid, expected: "ok\n", cold: true },
  ];
}
