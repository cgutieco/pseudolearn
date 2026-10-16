use crate::storage;
use serde_json::{Value, json};
use std::path::Path;
use std::process::Command;

pub fn mathematics(native: &Path, wasm: &Path) -> Result<Value, String> {
    let manifest: Value = storage::read_json(&native.join("manifest.json"))?;
    let other: Value = storage::read_json(&wasm.join("manifest.json"))?;
    if manifest != other
        || manifest.get("countPerFunction").and_then(Value::as_u64) != Some(1_000_000)
    {
        return Err("E17-MATH: expected identical manifests with one million arguments".to_owned());
    }
    let mut results = serde_json::Map::new();
    let mut total_differences = 0_usize;
    for function in see_conformance::math_arguments::MATH_FUNCTIONS {
        let name = function.name();
        let read = |directory: &Path, suffix: &str| {
            std::fs::read_to_string(directory.join(format!("{name}.{suffix}")))
                .map_err(|error| error.to_string())
        };
        let differences = function_difference(&read, (native, wasm))?;
        total_differences = total_differences.saturating_add(differences);
        results.insert(
            name.to_owned(),
            json!({"arguments":1_000_000,"differences":differences}),
        );
    }
    Ok(json!({"manifest":manifest,"functions":results,"differences":total_differences}))
}

pub fn brotli_size(path: &Path) -> Result<u64, String> {
    let output = Command::new("node").args(["-e", "const fs=require('node:fs'),zlib=require('node:zlib');process.stdout.write(String(zlib.brotliCompressSync(fs.readFileSync(process.argv[1])).length));"])
        .arg(path).output().map_err(|error| error.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).into_owned());
    }
    String::from_utf8(output.stdout)
        .map_err(|error| error.to_string())?
        .parse()
        .map_err(|error| format!("{error}"))
}

fn function_difference(
    read: &impl Fn(&Path, &str) -> Result<String, String>,
    paths: (&Path, &Path),
) -> Result<usize, String> {
    let (native, wasm) = paths;
    let arguments = read(native, "arguments")?;
    if arguments != read(wasm, "arguments")? {
        return Err("E17-MATH: different arguments".to_owned());
    }
    let expected = read(native, "results")?;
    let actual = read(wasm, "results")?;
    if [
        arguments.lines().count(),
        expected.lines().count(),
        actual.lines().count(),
    ]
    .iter()
    .any(|count| *count != 1_000_000)
    {
        return Err("E17-MATH: incomplete results".to_owned());
    }
    Ok(expected
        .lines()
        .zip(actual.lines())
        .filter(|(left, right)| left != right)
        .count())
}

pub fn complete(report: &Value) -> bool {
    let number = |name| report.get(name).and_then(Value::as_u64).unwrap_or(0);
    number("generatedPrograms") >= 10_000
        && number("emiPairs") >= 10_000
        && number("corpusRequests") > 0
        && number("formatBoundaryCases") >= 48
        && number("brotliBytes") > 0
        && number("brotliBytes") <= 614_400
        && report
            .pointer("/mathematics/differences")
            .and_then(Value::as_u64)
            == Some(0)
        && ["nativeStderr", "wasmStderr"]
            .iter()
            .all(|name| report.get(name).and_then(Value::as_str) == Some(""))
}
