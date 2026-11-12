pub fn check(directory: &std::path::Path) -> Result<(), String> {
    let output = std::process::Command::new("cargo")
        .current_dir(directory)
        .args(["metadata", "--locked", "--format-version", "1"])
        .output()
        .map_err(|error| error.to_string())?;
    if output.status.success() {
        return Ok(());
    }
    Err(format!(
        "Cargo.lock is out of date in {}: run cargo update --workspace and commit the lockfile\n{}",
        directory.display(),
        String::from_utf8_lossy(&output.stderr)
    ))
}
