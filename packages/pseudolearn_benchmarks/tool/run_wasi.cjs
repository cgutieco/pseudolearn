const fs = require('node:fs');
const path = require('node:path');
const { WASI } = require('node:wasi');

async function run() {
  const [moduleName, directoryName, ...moduleArguments] = process.argv.slice(2);
  if (!moduleName || !directoryName) {
    throw new Error('Usage: run_wasi.cjs <module.wasm> <preopen-directory> [module-arguments...]');
  }
  const modulePath = path.resolve(moduleName);
  const directory = path.resolve(directoryName);
  const wasi = new WASI({
    version: 'preview1',
    args: [modulePath, ...moduleArguments],
    env: {},
    preopens: { [directory]: directory },
    returnOnExit: true,
  });
  const module = await WebAssembly.compile(fs.readFileSync(modulePath));
  const instance = await WebAssembly.instantiate(module, {
    wasi_snapshot_preview1: wasi.wasiImport,
  });
  process.exitCode = wasi.start(instance);
}

run().catch(error => {
  process.stderr.write(`${error}\n`);
  process.exitCode = 1;
});
