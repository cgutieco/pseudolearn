use crate::corpus::CorpusCase;
use pseudolearn_api::{
    ExecuteRequest, compile_source_to_ir, conformance_build_request, inspect_benchmark_object,
    prepare_native_benchmark,
};
use serde_json::{Value, json};
use std::path::Path;
use std::process::Command;

pub fn save(case: &CorpusCase, directory: &Path, object: &Path) -> Result<Value, String> {
    let request = conformance_build_request(&ExecuteRequest {
        program: case.source.clone(),
        ..Default::default()
    });
    let prepared = prepare_native_benchmark(&request).map_err(|error| format!("{error:?}"))?;
    let inspected = inspect_benchmark_object(&prepared).map_err(|error| format!("{error:?}"))?;
    let ir =
        compile_source_to_ir(&case.source, "es", "strict").map_err(|error| format!("{error:?}"))?;
    let root = directory.join(&case.name);
    std::fs::create_dir_all(&root).map_err(|error| error.to_string())?;
    std::fs::write(root.join("program.ir"), &ir).map_err(|error| error.to_string())?;
    std::fs::write(root.join("program.clif"), inspected.inspection.join("\n"))
        .map_err(|error| error.to_string())?;
    let output = Command::new("objdump")
        .arg("-d")
        .arg(object)
        .output()
        .map_err(|error| error.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).into_owned());
    }
    std::fs::write(root.join("program.asm"), output.stdout).map_err(|error| error.to_string())?;
    let hash = super::storage::fingerprint(object)?;
    Ok(json!({"objectHash":hash,
        "cellLoadsInIr":ir.matches("cell.load").count(),"cellStoresInIr":ir.matches("cell.store").count(),
        "arrayAllocationsInIr":ir.matches("array.new").count(),"objectAllocationsInIr":ir.matches("object.new").count()}))
}
