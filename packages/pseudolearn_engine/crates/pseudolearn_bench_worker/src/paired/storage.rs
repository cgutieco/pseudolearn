use serde_json::Value;
use std::path::{Path, PathBuf};
use std::process::Command;

pub fn write(path: &Path, value: &Value) -> Result<(), String> {
    let text = serde_json::to_string_pretty(value).map_err(|error| error.to_string())?;
    std::fs::write(path, format!("{text}\n")).map_err(|error| error.to_string())
}

pub fn archive() -> Result<PathBuf, String> {
    build_archive(&[])
}

pub fn telemetry_archive() -> Result<PathBuf, String> {
    build_archive(&["--features", "telemetry"])
}

fn build_archive(features: &[&str]) -> Result<PathBuf, String> {
    let engine = Path::new(env!("CARGO_MANIFEST_DIR")).join("../..");
    let target = engine.join("target/aot-bench");
    let output = Command::new("cargo")
        .current_dir(&engine)
        .env("CARGO_TARGET_DIR", &target)
        .env_remove("RUSTFLAGS")
        .env_remove("CARGO_ENCODED_RUSTFLAGS")
        .args([
            "rustc",
            "--release",
            "--offline",
            "--jobs",
            "1",
            "-p",
            "pseudolearn_native_probe",
            "--lib",
            "--crate-type",
            "staticlib",
        ])
        .args(features)
        .output()
        .map_err(|error| error.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).into_owned());
    }
    Ok(target.join("release/libpseudolearn_native_probe.a"))
}

pub fn fingerprint(path: &Path) -> Result<String, String> {
    let output = Command::new("git")
        .arg("hash-object")
        .arg(path)
        .output()
        .map_err(|error| error.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).into_owned());
    }
    String::from_utf8(output.stdout)
        .map(|text| text.trim().to_owned())
        .map_err(|error| error.to_string())
}

pub fn manifest(directory: &Path, archive: &Path) -> Result<(), String> {
    let executable = std::env::current_exe().map_err(|error| error.to_string())?;
    write(
        &directory.join("artifacts.json"),
        &serde_json::json!({"runtimeArchiveGitBlob":fingerprint(archive)?,
        "workerGitBlob":fingerprint(&executable)?,"runtimeFeatures":[],
        "profile":"release","preflight":"one validated execution in a separate process per workload before measured executions",
        "rustflagsRemovedForRuntime":["RUSTFLAGS","CARGO_ENCODED_RUSTFLAGS"]}),
    )
}
