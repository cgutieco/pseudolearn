#![forbid(unsafe_code)]

use std::path::Path;

const EXPORT_PATH: &str = "../../../pseudolearn_spec/specifications/export.json";
const FORMS_PATH: &str = "data/dispatch_forms.json";

fn main() {
    println!("cargo:rerun-if-changed={EXPORT_PATH}");
    println!("cargo:rerun-if-changed={FORMS_PATH}");
    if let Err(error) = generate() {
        eprintln!("VM dispatch generation failed: {error}");
        std::process::exit(1);
    }
}

fn generate() -> pseudolearn_vm_dispatch::GenerationResult<()> {
    let manifest = std::env::var("CARGO_MANIFEST_DIR")?;
    let source = pseudolearn_vm_dispatch::generate(
        &Path::new(&manifest).join(EXPORT_PATH),
        &Path::new(&manifest).join(FORMS_PATH),
    )?;
    let out_dir = std::env::var("OUT_DIR")?;
    std::fs::write(Path::new(&out_dir).join("generated_dispatch.rs"), source)?;
    Ok(())
}
