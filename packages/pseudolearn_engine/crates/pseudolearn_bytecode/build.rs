#![forbid(unsafe_code)]

use std::path::Path;

struct OpcodeEntry {
    name: String,
    variant: String,
}

fn main() {
    println!("cargo:rerun-if-changed=../../../pseudolearn_spec/specifications/export.json");
    if let Err(error) = generate() {
        eprintln!("Bytecode opcode generation failed: {error}");
        std::process::exit(1);
    }
}

fn generate() -> Result<(), Box<dyn std::error::Error>> {
    let manifest = std::env::var("CARGO_MANIFEST_DIR")?;
    let export_path =
        Path::new(&manifest).join("../../../pseudolearn_spec/specifications/export.json");
    let export_text = std::fs::read_to_string(export_path)?;
    let parsed: serde_json::Value = serde_json::from_str(&export_text)?;
    let entries = extract_opcodes(&parsed)?;
    let output = generate_opcodes(&entries);
    let out_dir = std::env::var("OUT_DIR")?;
    std::fs::write(Path::new(&out_dir).join("generated_opcodes.rs"), output)?;
    Ok(())
}

fn extract_opcodes(
    parsed: &serde_json::Value,
) -> Result<Vec<OpcodeEntry>, Box<dyn std::error::Error>> {
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
            entries.push(OpcodeEntry {
                name: name.to_owned(),
                variant: to_pascal_case(name),
            });
        }
    }
    if entries.is_empty() || entries.len() > usize::from(u8::MAX) {
        return Err("Instruction catalog does not fit in bytecode opcodes".into());
    }
    Ok(entries)
}

fn generate_opcodes(entries: &[OpcodeEntry]) -> String {
    let chunks: Vec<_> = entries.chunks(25).collect();
    let mut output = String::new();
    append_enum(entries, &mut output);
    append_name_lookup(&chunks, &mut output);
    append_name_mapping(&chunks, &mut output);
    output.push_str("}\n");
    output
}

fn append_enum(entries: &[OpcodeEntry], output: &mut String) {
    output.push_str("#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]\n");
    output.push_str("#[repr(u8)]\npub enum Opcode {\n");
    for (index, entry) in entries.iter().enumerate() {
        output.push_str(&format!("    {} = {index},\n", entry.variant));
    }
    output.push_str("}\n\nimpl Opcode {\n");
}

fn append_name_lookup(chunks: &[&[OpcodeEntry]], output: &mut String) {
    output.push_str("    pub fn from_name(name: &str) -> Option<Self> {\n");
    for index in 0..chunks.len() {
        output.push_str(&format!(
            "        if let Some(opcode) = Self::from_name_slice_{index}(name) {{ return Some(opcode); }}\n"
        ));
    }
    output.push_str("        None\n    }\n\n");
    for (index, chunk) in chunks.iter().enumerate() {
        output.push_str(&format!(
            "    fn from_name_slice_{index}(name: &str) -> Option<Self> {{\n        match name {{\n"
        ));
        for entry in *chunk {
            output.push_str(&format!(
                "            \"{}\" => Some(Self::{}),\n",
                entry.name, entry.variant
            ));
        }
        output.push_str("            _ => None,\n        }\n    }\n\n");
    }
}

fn append_name_mapping(chunks: &[&[OpcodeEntry]], output: &mut String) {
    output.push_str("    pub fn as_name(self) -> &'static str {\n");
    for index in 0..chunks.len() {
        output.push_str(&format!(
            "        if let Some(name) = Self::as_name_slice_{index}(self) {{ return name; }}\n"
        ));
    }
    output.push_str("        \"\"\n    }\n\n");
    for (index, chunk) in chunks.iter().enumerate() {
        output.push_str(&format!(
            "    fn as_name_slice_{index}(opcode: Self) -> Option<&'static str> {{\n        match opcode {{\n"
        ));
        for entry in *chunk {
            output.push_str(&format!(
                "            Self::{} => Some(\"{}\"),\n",
                entry.variant, entry.name
            ));
        }
        output.push_str("            _ => None,\n        }\n    }\n\n");
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
