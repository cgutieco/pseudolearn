export function percentile(values, fraction) {
  const sorted = [...values].sort((left, right) => left - right);
  return sorted[Math.max(0, Math.ceil(sorted.length * fraction) - 1)];
}

function mean(values) {
  return values.reduce((total, value) => total + value, 0) / values.length;
}

function interval(means) {
  let seed = 42681;
  const random = () => {
    seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0;
    return seed / 4294967296;
  };
  const samples = Array.from({ length: 2000 }, () => mean(means.map(() => means[Math.floor(random() * means.length)])));
  return [percentile(samples, 0.025), percentile(samples, 0.975)];
}

export function summarize(rows) {
  if (!rows.length || new Set(rows.map((row) => row.build)).size !== 1) throw new Error("Missing or mixed build measurements");
  if (rows.some((row) => row.unit !== "ms" || !Number.isFinite(row.milliseconds) || row.milliseconds < 0
    || !row.valid || row.output !== row.expected)) throw new Error("Invalid attempt retained; comparison cannot be qualified");
  const groups = Map.groupBy(rows, (row) => `${row.target}/${row.workload}`);
  return Object.fromEntries([...groups].map(([key, attempts]) => {
    const processes = Map.groupBy(attempts, (row) => row.process);
    if (processes.size !== 10 || [...processes.values()].some((group) => group.length !== 30
      || new Set(group.map((row) => row.iteration)).size !== 30)) throw new Error("Expected 10 independent processes and 30 attempts");
    const values = attempts.map((row) => row.milliseconds);
    const means = [...processes.values()].map((group) => mean(group.map((row) => row.milliseconds)));
    return [key, { attempts: values.length, valid: values.length, mean: mean(values), p95: percentile(values, 0.95), ci95: interval(means), bootstrapSeed: 42681 }];
  }));
}

export function validatePhysical(rows, kit) {
  const seen = new Set();
  for (const row of rows) {
    const combination = kit.combinations.find((entry) => entry.id === row.combination);
    if (!row.physical || row.synthetic || !combination) throw new Error("Unrecognized or synthetic physical evidence");
    const key = `${row.combination}/${row.cycle}`;
    if (seen.has(key) || !Number.isInteger(row.cycle) || row.cycle < 1 || row.cycle > kit.cycles) throw new Error("Duplicate or invalid cycle");
    seen.add(key);
    if (!row.device || row.controlDevice !== row.device || row.wasmSha256 !== kit.wasmSha256
      || row.controlWasmSha256 !== kit.wasmSha256) throw new Error("Device or Wasm control mismatch");
    if (!row.saveConfirmed || row.finalSourceSha256 !== kit.sources[combination.load].finalSha256) throw new Error("Text loss or unconfirmed save");
    if (![row.editMilliseconds, row.cancelMilliseconds, row.runMilliseconds, row.controlMilliseconds].every((value) => Number.isFinite(value) && value >= 0)) throw new Error("Missing timings or cancellation");
    if (row.totalMemoryBytes !== null && !row.memoryMethod) throw new Error("Memory requires a physical method");
  }
  if (seen.size !== kit.combinations.length * kit.cycles) throw new Error("Physical combinations or cycles missing");
  return { combinations: kit.combinations.length, cycles: rows.length, textLoss: 0,
    editingP95: percentile(rows.map((row) => row.editMilliseconds), 0.95),
    cancellationMaximum: Math.max(...rows.map((row) => row.cancelMilliseconds)),
    maximumRuntimeRatio: Math.max(...rows.map((row) => row.runMilliseconds / row.controlMilliseconds)) };
}
