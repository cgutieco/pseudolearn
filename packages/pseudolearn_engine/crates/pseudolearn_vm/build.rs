#![forbid(unsafe_code)]

use std::path::Path;

struct DispatchEntry {
    variant: String,
    category: &'static str,
}

fn main() {
    println!("cargo:rerun-if-changed=../../../pseudolearn_spec/specifications/export.json");
    if let Err(error) = generate() {
        eprintln!("VM dispatch generation failed: {error}");
        std::process::exit(1);
    }
}

fn generate() -> Result<(), Box<dyn std::error::Error>> {
    let manifest = std::env::var("CARGO_MANIFEST_DIR")?;
    let export_path =
        Path::new(&manifest).join("../../../pseudolearn_spec/specifications/export.json");
    let export_text = std::fs::read_to_string(export_path)?;
    let parsed: serde_json::Value = serde_json::from_str(&export_text)?;
    let entries = extract_entries(&parsed)?;
    let source = render_dispatch(&entries);
    let out_dir = std::env::var("OUT_DIR")?;
    std::fs::write(Path::new(&out_dir).join("generated_dispatch.rs"), source)?;
    Ok(())
}

fn extract_entries(
    parsed: &serde_json::Value,
) -> Result<Vec<DispatchEntry>, Box<dyn std::error::Error>> {
    let specifications = parsed
        .get("specifications")
        .and_then(serde_json::Value::as_array)
        .ok_or("Missing specifications array")?;
    let specification = specifications
        .iter()
        .find(|entry| {
            entry
                .get("metadata")
                .and_then(|metadata| metadata.get("id"))
                .and_then(serde_json::Value::as_str)
                == Some("IR.INSTRUCTIONS")
        })
        .ok_or("Missing IR.INSTRUCTIONS")?;
    let blocks = specification
        .get("blocks")
        .and_then(serde_json::Value::as_array)
        .ok_or("Missing instruction blocks")?;
    let mut entries = Vec::new();
    for block in blocks {
        if block.get("kind").and_then(serde_json::Value::as_str) == Some("instruccion") {
            let name = block
                .get("fields")
                .and_then(|fields| fields.get("nombre"))
                .and_then(serde_json::Value::as_str)
                .ok_or("Missing instruction name")?;
            entries.push(DispatchEntry {
                variant: to_pascal_case(name),
                category: dispatch_category(name),
            });
        }
    }
    if entries.is_empty() {
        return Err("IR.INSTRUCTIONS is empty".into());
    }
    Ok(entries)
}

fn render_dispatch(entries: &[DispatchEntry]) -> String {
    let mut source = String::from(
        "#[derive(Clone, Copy, Debug, Eq, PartialEq)]\npub(crate) enum DispatchKind { Constant, ValueState, Integer, Real, Boolean, Character, Control, Observation, Output, Other }\n\npub(crate) fn dispatch_kind(opcode: pseudolearn_bytecode::Opcode) -> DispatchKind {\n    match opcode {\n",
    );
    for entry in entries {
        source.push_str(&format!(
            "        pseudolearn_bytecode::Opcode::{} => DispatchKind::{},\n",
            entry.variant, entry.category
        ));
    }
    source.push_str("    }\n}\n");
    source
}

fn dispatch_category(name: &str) -> &'static str {
    match name.split('.').next().unwrap_or("") {
        "const" => "Constant",
        "value" => "ValueState",
        "int" => "Integer",
        "real" | "math" => "Real",
        "bool" => "Boolean",
        "char" => "Character",
        "stmt" | "decide" => "Observation",
        "out" => "Output",
        _ => match name {
            "jump"
            | "branch"
            | "call"
            | "call.virtual"
            | "return"
            | "trap.missing_return"
            | "unreachable"
            | "loop.check_step" => "Control",
            _ => "Other",
        },
    }
}

fn to_pascal_case(name: &str) -> String {
    let mut output = String::new();
    let mut capitalize = true;
    for character in name.chars() {
        if matches!(character, '.' | '_' | '-') {
            capitalize = true;
        } else if capitalize {
            output.extend(character.to_uppercase());
            capitalize = false;
        } else {
            output.push(character);
        }
    }
    output
}
