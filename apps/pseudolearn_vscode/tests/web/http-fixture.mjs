import { createServer as createHttpServer } from "node:http";
import { createServer as createHttpsServer } from "node:https";
import { spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { createHash } from "node:crypto";

const slashes = "/".repeat(2);
const corsHeaders = { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers": "*", "Access-Control-Allow-Methods": "*" };

function spkiHash(certificatePem) {
  const publicKey = spawnSync("openssl", ["x509", "-pubkey", "-noout"], { input: certificatePem });
  const der = spawnSync("openssl", ["pkey", "-pubin", "-outform", "der"], { input: publicKey.stdout });
  return createHash("sha256").update(der.stdout).digest("base64");
}

function certificate() {
  const directory = mkdtempSync(join(tmpdir(), "pseudolearn-tls-"));
  const key = join(directory, "key.pem");
  const cert = join(directory, "cert.pem");
  const result = spawnSync("openssl", ["req", "-x509", "-newkey", "ec", "-pkeyopt", "ec_paramgen_curve:prime256v1", "-nodes",
    "-keyout", key, "-out", cert, "-days", "1", "-subj", "/CN=localhost"], { encoding: "utf8" });
  if (result.status !== 0) throw new Error(`Certificate generation failed: ${result.stderr}`);
  const material = { key: readFileSync(key), cert: readFileSync(cert) };
  material.spki = spkiHash(material.cert);
  rmSync(directory, { recursive: true, force: true });
  return material;
}

export function createHandler(hits) {
  return (request, response) => {
    const path = new URL(request.url, "http://fixture").pathname;
    if (request.method === "OPTIONS") { response.writeHead(204, corsHeaders).end(); return; }
    if (path === "/__hits") { response.writeHead(200, corsHeaders).end(JSON.stringify(hits)); return; }
    hits[path] = (hits[path] ?? 0) + 1;
    const routes = {
      "/ok": () => response.writeHead(200, corsHeaders).end("ok"),
      "/empty": () => response.writeHead(200, corsHeaders).end(),
      "/status-500": () => response.writeHead(500, corsHeaders).end("failure"),
      "/big": () => response.writeHead(200, corsHeaders).end("x".repeat(64)),
      "/redirect": () => response.writeHead(302, { ...corsHeaders, Location: "/ok" }).end(),
      "/nocors": () => response.writeHead(200).end("ok"),
      "/drop": () => request.socket.destroy(),
      "/slow": () => setTimeout(() => response.writeHead(200, corsHeaders).end("late"), 3000),
      "/hang": () => response.writeHead(200, corsHeaders),
    };
    (routes[path] ?? (() => response.writeHead(404, corsHeaders).end()))();
  };
}

function listen(server) {
  return new Promise((resolve) => server.listen(0, "127.0.0.1", () => resolve(server.address().port)));
}

export async function startHttpFixture() {
  const hits = {};
  const handler = createHandler(hits);
  const plain = createHttpServer(handler);
  const material = certificate();
  const secure = createHttpsServer({ key: material.key, cert: material.cert }, handler);
  const [plainPort, securePort] = [await listen(plain), await listen(secure)];
  const close = () => {
    for (const server of [plain, secure]) { server.closeAllConnections(); server.close(); }
  };
  return { http: `http:${slashes}127.0.0.1:${plainPort}`, https: `https:${slashes}localhost:${securePort}`, hits, close, spki: material.spki };
}
