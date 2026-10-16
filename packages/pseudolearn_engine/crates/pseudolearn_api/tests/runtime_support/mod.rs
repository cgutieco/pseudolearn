mod cases;
mod diagnostics;
mod memory;

use serde_json::Value;

pub fn verify() -> Result<(), String> {
    let fixtures = fixtures()?;
    cases::verify(&fixtures)?;
    memory::verify(&fixtures)
}

fn fixtures() -> Result<Value, String> {
    let root = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("../../../pseudolearn_spec");
    let output = std::process::Command::new("cargo")
        .args(["run", "--offline", "--quiet", "--manifest-path"])
        .arg(root.join("Cargo.toml"))
        .args([
            "-p",
            "see_cli",
            "--bin",
            "see",
            "--",
            "runtime-fixtures",
            "--root",
        ])
        .arg(&root)
        .output()
        .map_err(|error| error.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).into_owned());
    }
    serde_json::from_slice(&output.stdout).map_err(|error| error.to_string())
}

pub(super) fn compile(
    source: &str,
    profile: &str,
    strictness: &str,
) -> Result<pseudolearn_vm::LoadedProgram, String> {
    let module = pseudolearn_api::compile_source_to_module(source, profile, strictness)
        .map_err(|errors| format!("Compilation {errors:?}"))?;
    let bytecode = pseudolearn_bytecode::compile_module(&module)
        .map_err(|error| format!("Bytecode {error:?}"))?;
    pseudolearn_vm::load(&bytecode).map_err(|error| format!("Load {error:?}"))
}
