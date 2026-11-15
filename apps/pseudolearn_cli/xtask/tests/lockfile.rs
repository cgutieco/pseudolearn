use std::path::{Path, PathBuf};
use std::process::{Command, Output};

fn fixture(name: &str, lock: &str) -> Result<PathBuf, String> {
    let root = std::env::temp_dir().join(format!("xtask-lock-{name}-{}", std::process::id()));
    let dependency = root.join("dependency");
    std::fs::create_dir_all(dependency.join("src")).map_err(|error| error.to_string())?;
    std::fs::create_dir_all(root.join("src")).map_err(|error| error.to_string())?;
    let files = [
        (
            root.join("Cargo.toml"),
            "[package]\nname = \"consumer\"\nversion = \"0.1.0\"\nedition = \"2024\"\n\n[dependencies]\ndependency = { path = \"dependency\" }\n",
        ),
        (root.join("src/lib.rs"), ""),
        (
            dependency.join("Cargo.toml"),
            "[package]\nname = \"dependency\"\nversion = \"0.1.0\"\nedition = \"2024\"\n",
        ),
        (dependency.join("src/lib.rs"), ""),
        (root.join("Cargo.lock"), lock),
    ];
    for (path, text) in files {
        std::fs::write(path, text).map_err(|error| error.to_string())?;
    }
    Ok(root)
}

fn check_lock(directory: &Path) -> Result<Output, String> {
    Command::new(env!("CARGO_BIN_EXE_xtask"))
        .args(["check-lock", &directory.to_string_lossy()])
        .output()
        .map_err(|error| error.to_string())
}

const CURRENT: &str = "version = 4\n\n[[package]]\nname = \"consumer\"\nversion = \"0.1.0\"\ndependencies = [\n \"dependency\",\n]\n\n[[package]]\nname = \"dependency\"\nversion = \"0.1.0\"\n";
const STALE: &str = "version = 4\n\n[[package]]\nname = \"consumer\"\nversion = \"0.1.0\"\n";

#[test]
fn a_lockfile_that_matches_the_manifests_passes() -> Result<(), String> {
    let root = fixture("current", CURRENT)?;
    let output = check_lock(&root)?;
    assert!(
        output.status.success(),
        "{}",
        String::from_utf8_lossy(&output.stderr)
    );
    Ok(())
}

#[test]
fn a_lockfile_missing_a_dependency_fails_instead_of_being_rewritten() -> Result<(), String> {
    let root = fixture("stale", STALE)?;
    let output = check_lock(&root)?;
    assert!(!output.status.success());
    assert!(String::from_utf8_lossy(&output.stderr).contains("Cargo.lock is out of date"));
    let lock =
        std::fs::read_to_string(root.join("Cargo.lock")).map_err(|error| error.to_string())?;
    assert_eq!(lock, STALE);
    Ok(())
}
