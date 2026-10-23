#[path = "codegen/help_cards.rs"]
mod help_cards;
use std::path::Path;

const EXPORT_PATH: &str = "../../../pseudolearn_spec/specifications/export.json";

fn main() {
    println!("cargo:rerun-if-changed={EXPORT_PATH}");
    if let Err(error) = generate() {
        eprintln!("Failed to generate help catalog: {error}");
        std::process::exit(1);
    }
}

fn generate() -> Result<(), Box<dyn std::error::Error>> {
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR")?;
    let export_text = std::fs::read_to_string(Path::new(&manifest_dir).join(EXPORT_PATH))?;
    let parsed: serde_json::Value = serde_json::from_str(&export_text)?;
    let catalog = parsed
        .get("resources")
        .and_then(|resources| resources.get("helpCatalog"))
        .ok_or("Missing helpCatalog in export.json")?;
    let destination = Path::new(&std::env::var("OUT_DIR")?).join("generated_help_cards.rs");
    std::fs::write(destination, help_cards::cards(catalog)?)?;
    Ok(())
}
