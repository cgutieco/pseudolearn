use serde_json::{Value, json};
use std::path::Path;
use std::process::Command;
use std::time::Instant;

fn capture(program: &str, arguments: &[&str]) -> Result<String, String> {
    let output = Command::new(program)
        .current_dir(Path::new(env!("CARGO_MANIFEST_DIR")).join("../../../.."))
        .args(arguments)
        .output()
        .map_err(|error| error.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).into_owned());
    }
    Ok(String::from_utf8_lossy(&output.stdout).trim().to_owned())
}

pub fn describe() -> Result<Value, String> {
    let tracked = capture(
        "git",
        &[
            "ls-files",
            "--cached",
            "--others",
            "--exclude-standard",
            "packages/pseudolearn_engine",
            "packages/pseudolearn_spec",
            "packages/pseudolearn_benchmarks/ceiling",
        ],
    )?;
    let hashes = source_hashes(&tracked)?;
    let resolution = clock_resolution()?;
    Ok(json!({"commit":capture("git", &["rev-parse", "HEAD"])?,
        "dirty": !capture("git", &["status", "--porcelain"])?.is_empty(),
        "rustc":capture("rustc", &["--version", "--verbose"])?,
        "cc":capture("cc", &["--version"])?,"os":capture("uname", &["-a"])?,
        "hardware":capture("sysctl", &["hw.model", "machdep.cpu.brand_string", "hw.memsize"])?,
        "clock":"std::time::Instant, one complete execution per sample",
        "minimumObservedClockNanoseconds":resolution,
        "capturedBefore":"runtime archive and measured objects",
        "sourceHashes":hashes,"processes":10,"iterations":30,"seed":42,
        "limitations":["CPU frequency, placement and external load uncontrolled", "VM API interval includes machine construction", "V1F remains a hand-written native ceiling", "No samples discarded"]}))
}

fn clock_resolution() -> Result<u64, String> {
    let mut resolution = u128::MAX;
    for _ in 0..1000 {
        let started = Instant::now();
        let elapsed = started.elapsed().as_nanos();
        if elapsed > 0 {
            resolution = resolution.min(elapsed);
        }
    }
    u64::try_from(resolution).map_err(|error| error.to_string())
}

fn source_hashes(tracked: &str) -> Result<serde_json::Map<String, Value>, String> {
    use std::io::Write;
    use std::process::Stdio;
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("../../../..");
    let files: Vec<&str> = tracked
        .lines()
        .filter(|file| !file.contains("/results/") && root.join(file).is_file())
        .collect();
    let mut child = Command::new("git")
        .current_dir(&root)
        .args(["hash-object", "--stdin-paths"])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()
        .map_err(|error| error.to_string())?;
    if let Some(mut input) = child.stdin.take() {
        for file in &files {
            writeln!(input, "{file}").map_err(|error| error.to_string())?;
        }
    }
    let output = child
        .wait_with_output()
        .map_err(|error| error.to_string())?;
    let text = String::from_utf8(output.stdout).map_err(|error| error.to_string())?;
    let hashes: Vec<&str> = text.lines().collect();
    if !output.status.success() || hashes.len() != files.len() {
        return Err("Source hashing failed".to_owned());
    }
    Ok(files
        .into_iter()
        .zip(hashes)
        .map(|(file, hash)| (file.to_owned(), json!(hash)))
        .collect())
}
