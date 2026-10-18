use std::path::{Path, PathBuf};
use std::process::Command;

const ENGINE: &str = "../../packages/pseudolearn_engine";
const RUNTIME_CRATES: [&str; 6] = [
    "pseudolearn_aot_rt",
    "pseudolearn_runtime",
    "pseudolearn_library",
    "pseudolearn_diagnostics",
    "pseudolearn_abi",
    "pseudolearn_source",
];
const ARCHIVE_NAME: &str = "libpseudolearn_runtime_aot.a";

pub fn build() -> Result<(), Box<dyn std::error::Error>> {
    let manifest = PathBuf::from(std::env::var("CARGO_MANIFEST_DIR")?);
    let engine = manifest.join(ENGINE);
    println!(
        "cargo:rerun-if-changed={}",
        engine.join("Cargo.lock").display()
    );
    for name in RUNTIME_CRATES {
        println!(
            "cargo:rerun-if-changed={}",
            engine.join("crates").join(name).display()
        );
    }
    let out_dir = PathBuf::from(std::env::var("OUT_DIR")?);
    let produced = compile_static_library(&engine, &out_dir.join("runtime_target"))?;
    let archive = out_dir.join(ARCHIVE_NAME);
    std::fs::copy(produced, &archive)?;
    strip_debug_information(&archive);
    Ok(())
}

fn compile_static_library(
    engine: &Path,
    target_directory: &Path,
) -> Result<PathBuf, Box<dyn std::error::Error>> {
    let cargo = std::env::var("CARGO").unwrap_or_else(|_| "cargo".to_owned());
    let status = Command::new(cargo)
        .current_dir(engine)
        .env_remove("RUSTFLAGS")
        .env_remove("CARGO_ENCODED_RUSTFLAGS")
        .env("CARGO_TARGET_DIR", target_directory)
        .args(["rustc", "--release", "--locked", "--jobs", "1"])
        .args(["-p", "pseudolearn_aot_rt", "--lib"])
        .args(["--crate-type", "staticlib"])
        .status()?;
    if !status.success() {
        return Err("cargo rustc failed for pseudolearn_aot_rt".into());
    }
    Ok(target_directory
        .join("release")
        .join("libpseudolearn_aot_rt.a"))
}

fn strip_debug_information(archive: &Path) {
    let flags: &[&str] = if cfg!(target_os = "macos") {
        &["-S", "-x"]
    } else {
        &["--strip-debug"]
    };
    let _stripped = Command::new("strip").args(flags).arg(archive).status();
}
