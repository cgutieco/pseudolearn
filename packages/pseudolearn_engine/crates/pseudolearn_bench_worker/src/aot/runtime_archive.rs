use std::path::{Path, PathBuf};
use std::process::Command;

const ARCHIVE_NAME: &str = "libpseudolearn_aot_rt.a";

pub fn build() -> Result<PathBuf, String> {
    let engine = Path::new(env!("CARGO_MANIFEST_DIR")).join("../..");
    let target = engine.join("target/aot-bench");
    let cargo = std::env::var("CARGO").unwrap_or_else(|_| "cargo".to_owned());
    let status = Command::new(cargo)
        .current_dir(&engine)
        .env_remove("RUSTFLAGS")
        .env_remove("CARGO_ENCODED_RUSTFLAGS")
        .env("CARGO_TARGET_DIR", &target)
        .args(["rustc", "--release", "--locked", "--jobs", "1"])
        .args(["-p", "pseudolearn_aot_rt", "--lib"])
        .args(["--crate-type", "staticlib"])
        .status()
        .map_err(|error| error.to_string())?;
    if !status.success() {
        return Err("Building the runtime archive failed".to_owned());
    }
    let archive = target.join("release").join(ARCHIVE_NAME);
    if archive.exists() {
        Ok(archive)
    } else {
        Err(format!("Missing runtime archive {}", archive.display()))
    }
}
