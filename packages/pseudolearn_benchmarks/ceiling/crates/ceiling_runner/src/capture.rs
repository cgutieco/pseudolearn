use serde_json::{Value, json};

pub fn command(executable: &str, arguments: &[&str]) -> Result<String, String> {
    let result = std::process::Command::new(executable)
        .args(arguments)
        .output()
        .map_err(|error| error.to_string())?;
    if !result.status.success() {
        return Err(format!(
            "{executable}: {}",
            String::from_utf8_lossy(&result.stderr)
        ));
    }
    String::from_utf8(result.stdout).map_err(|error| error.to_string())
}

pub fn provenance() -> Result<Value, String> {
    let root = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("../..");
    Ok(json!({
        "commit": command("git", &["rev-parse", "HEAD"])?.trim(),
        "dirty": !command("git", &["status", "--porcelain", "--", "."])?.trim().is_empty(),
        "sourceHashes": source_hashes()?,
        "rustc": command("rustc", &["-Vv"])?,
        "os": command("uname", &["-a"])?,
        "hardware": command("sysctl", &["hw.model", "machdep.cpu.brand_string", "hw.memsize"])?,
        "capturedUtc": command("date", &["-u", "+%Y-%m-%dT%H:%M:%SZ"])?.trim(),
        "root": root.to_string_lossy(),
        "processes": 10, "iterations": 30, "seed": 42,
        "minimumSampleMilliseconds": 5,
        "clock": "std::time::Instant, batched to at least 5 ms",
        "minimumObservedClockNanoseconds": clock_resolution(),
        "limitations": ["External load and CPU frequency uncontrolled", "No samples discarded",
            "Kernel ceiling experiment is not VM performance", "Memory and CPU belong to process, not kernel"]
    }))
}

fn source_hashes() -> Result<Value, String> {
    let paths = command(
        "git",
        &[
            "ls-files",
            "--cached",
            "--others",
            "--exclude-standard",
            "--",
            "crates",
            "xtask",
            "Cargo.toml",
            "Cargo.lock",
            "architecture.yaml",
            "rust-toolchain.toml",
            "clippy.toml",
            "deny.toml",
            ".cargo/config.toml",
        ],
    )?;
    let mut hashes = serde_json::Map::new();
    for path in paths.lines() {
        let hash = command("git", &["hash-object", "--", path])?;
        hashes.insert(path.to_owned(), Value::String(hash.trim().to_owned()));
    }
    let corpus = "../../pseudolearn_spec/specifications/export.json";
    hashes.insert(
        corpus.to_owned(),
        Value::String(
            command("git", &["hash-object", "--", corpus])?
                .trim()
                .to_owned(),
        ),
    );
    Ok(Value::Object(hashes))
}

fn clock_resolution() -> u128 {
    (0..10000)
        .filter_map(|_| {
            let start = std::time::Instant::now();
            let elapsed = start.elapsed().as_nanos();
            (elapsed > 0).then_some(elapsed)
        })
        .min()
        .unwrap_or(0)
}
