#[path = "codegen/contextual.rs"]
mod contextual;
#[path = "codegen/grammar_reader.rs"]
mod grammar_reader;
#[path = "codegen/structural.rs"]
mod structural;
#[path = "codegen/views.rs"]
mod views;

use serde_json::Value;
use std::collections::{BTreeMap, BTreeSet};
use std::path::Path;

fn main() {
    println!("cargo:rerun-if-changed=../../../pseudolearn_spec/specifications/export.json");
    if let Err(error) = generate() {
        eprintln!("Syntax generation failed: {error}");
        std::process::exit(1);
    }
}

fn generate() -> Result<(), Box<dyn std::error::Error>> {
    let manifest = std::env::var("CARGO_MANIFEST_DIR")?;
    let export = Path::new(&manifest).join("../../../pseudolearn_spec/specifications/export.json");
    let corpus: Value = serde_json::from_str(&std::fs::read_to_string(export)?)?;
    let grammar = corpus
        .pointer("/resources/grammar")
        .ok_or("Missing grammar")?;
    let productions: BTreeMap<String, String> = serde_json::from_value(
        grammar
            .get("producciones")
            .ok_or("Missing productions")?
            .clone(),
    )?;
    let terminals: BTreeSet<String> = serde_json::from_value(
        grammar
            .get("terminales")
            .ok_or("Missing terminals")?
            .clone(),
    )?;
    grammar_reader::validate(&productions, &terminals)?;
    let nesting = corpus
        .pointer("/resources/analysisLimits/nesting")
        .and_then(Value::as_u64)
        .and_then(|limit| u32::try_from(limit).ok())
        .ok_or("Missing analysis nesting limit")?;
    let names = productions.keys().cloned().chain(terminals).collect();
    let mut generated = views::generate(&names, nesting);
    generated.push_str(&contextual_resources(&corpus)?);
    let output = std::env::var("OUT_DIR")?;
    std::fs::write(Path::new(&output).join("generated_syntax.rs"), generated)?;
    Ok(())
}

fn contextual_resources(corpus: &Value) -> Result<String, Box<dyn std::error::Error>> {
    let mut generated = String::new();
    generated.push_str(&contextual::generate(
        corpus
            .pointer("/resources/contextualVocabulary")
            .ok_or("Missing contextual vocabulary")?,
    )?);
    generated.push_str(&structural::generate(
        corpus
            .pointer("/resources/unsupportedConstructs")
            .ok_or("Missing structural catalog")?,
    )?);
    Ok(generated)
}
