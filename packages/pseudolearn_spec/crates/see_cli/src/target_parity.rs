use crate::{arguments::Arguments, storage};
use see_conformance::protocol::Session;
use see_model::{Corpus, contract::Vocabulary};
use serde_json::{Value, json};
use std::{path::Path, process::Command, time::Duration};

struct Targets {
    native: Session,
    wasm: Session,
    differences: Vec<Value>,
}

pub fn execute(arguments: &Arguments, corpus: &Corpus) -> Result<String, String> {
    let engine = arguments
        .root
        .join("../pseudolearn_engine")
        .canonicalize()
        .map_err(|error| error.to_string())?;
    let wasm_path = engine.join("target/wasm32-wasip1/release/conformance_adapter.wasm");
    let mut targets = Targets::start(&engine, &wasm_path)?;
    let vocabulary: Vocabulary =
        storage::read_json(&arguments.root.join("specifications/cases/vocabulary.json"))?;
    let fixtures = see_conformance::runtime_fixtures::execution_cases(corpus, &vocabulary)?;
    let count = crate::property_selection::number(arguments, "count")?.unwrap_or(10_000);
    let seed = crate::property_selection::number::<u64>(arguments, "seed")?.unwrap_or(20_261_016);
    for fixture in &fixtures {
        targets.compare(fixture.get("request").ok_or("Missing parity request")?)?;
    }
    targets.generated(&vocabulary, seed, count)?;
    let format_count = targets.format(&vocabulary)?;
    let native_errors = targets.native.finish()?;
    let wasm_errors = targets.wasm.finish()?;
    let compressed = crate::target_evidence::brotli_size(&wasm_path)?;
    let math = mathematics(arguments)?;
    save(
        arguments,
        json!({"experiment":"E-17",
        "seed":seed,"corpusRequests":fixtures.len(),"generatedPrograms":count,"emiPairs":count,
        "differences":targets.differences,"nativeStderr":native_errors,"wasmStderr":wasm_errors,
        "wasmBytes":std::fs::metadata(&wasm_path).map_err(|error| error.to_string())?.len(),
        "brotliBytes":compressed,"mathematics":math,"hostFlags":["--no-incremental-marking"],
        "formatBoundaryCases":format_count}),
    )
}

impl Targets {
    fn start(engine: &Path, wasm_path: &Path) -> Result<Self, String> {
        let mut native_command = Command::new(engine.join("target/release/conformance_adapter"));
        let mut wasm_command = Command::new("node");
        wasm_command
            .args([
                "--no-warnings",
                "--no-incremental-marking",
                "-e",
                WASI_RUNNER,
            ])
            .arg(wasm_path);
        Ok(Self {
            native: Session::start(&mut native_command, Duration::from_secs(30))?,
            wasm: Session::start(&mut wasm_command, Duration::from_secs(30))?,
            differences: Vec::new(),
        })
    }

    fn compare(&mut self, request: &Value) -> Result<Value, String> {
        let expected = self
            .native
            .request(request)
            .map_err(|error| format!("native: {error}; request: {request}"))?;
        let actual = self
            .wasm
            .request(request)
            .map_err(|error| format!("wasm: {error}; request: {request}"))?;
        if expected != actual {
            self.differences
                .push(json!({"request":request,"native":expected,"wasm":actual}));
        }
        Ok(expected)
    }

    fn format(&mut self, vocabulary: &Vocabulary) -> Result<usize, String> {
        let requests = see_conformance::target_programs::format_boundaries(vocabulary)?;
        for (request, bits) in &requests {
            let response = self.compare(request)?;
            let actual = response
                .get("output")
                .and_then(Value::as_str)
                .and_then(|output| output.trim().parse::<f64>().ok())
                .map(f64::to_bits);
            if actual != Some(*bits) {
                self.differences.push(
                    json!({"kind":"format_bits","request":request,"expected":bits,"actual":actual}),
                );
            }
        }
        Ok(requests.len())
    }

    fn generated(&mut self, vocabulary: &Vocabulary, seed: u64, count: u32) -> Result<(), String> {
        for sample in 0..count {
            let (program, emi, expected) =
                see_conformance::target_programs::generated(vocabulary, seed, sample)?;
            let original = self.compare(&program)?;
            let transformed = self.compare(&emi)?;
            if transformed.get("output").and_then(Value::as_str) != Some(expected.as_str())
                || transformed
                    .pointer("/termination/kind")
                    .and_then(Value::as_str)
                    != Some("completed")
            {
                self.differences.push(json!({"sample":sample,"kind":"independent_oracle","request":emi,"expected":expected,"actual":transformed}));
            }
            for name in ["output", "termination"] {
                if original.get(name) != transformed.get(name) {
                    self.differences.push(json!({"sample":sample,"kind":"EMI","field":name,"original":original,"transformed":transformed}));
                }
            }
        }
        Ok(())
    }
}

const WASI_RUNNER: &str = "const fs=require('node:fs');const {WASI}=require('node:wasi');const wasi=new WASI({version:'preview1',args:[process.argv[1]],env:{},preopens:{}});WebAssembly.compile(fs.readFileSync(process.argv[1])).then(module=>WebAssembly.instantiate(module,{wasi_snapshot_preview1:wasi.wasiImport})).then(instance=>wasi.start(instance)).catch(error=>{process.stderr.write(String(error));process.exitCode=1;});";

fn mathematics(arguments: &Arguments) -> Result<Option<Value>, String> {
    match (
        arguments.options.get("input"),
        arguments.options.get("output"),
    ) {
        (Some(native), Some(wasm)) => {
            crate::target_evidence::mathematics(Path::new(native), Path::new(wasm)).map(Some)
        }
        _ => Ok(None),
    }
}

fn save(arguments: &Arguments, mut report: Value) -> Result<String, String> {
    let matches = report
        .get("differences")
        .and_then(Value::as_array)
        .is_some_and(Vec::is_empty);
    let complete = matches && crate::target_evidence::complete(&report);
    let fields = report.as_object_mut().ok_or("Invalid parity report")?;
    fields.insert("all_passed".to_owned(), json!(complete));
    fields.insert(
        "status".to_owned(),
        json!(if complete { "passed" } else { "partial" }),
    );
    storage::artifact(&arguments.root.join("results/r5-e17.json"), &report, false)?;
    if !matches {
        return Err("Target parity differences; evidence saved".to_owned());
    }
    Ok(format!(
        "Target parity matched; complete: {complete}; evidence saved"
    ))
}
