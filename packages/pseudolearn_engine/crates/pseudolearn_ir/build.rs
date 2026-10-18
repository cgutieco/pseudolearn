use std::path::Path;

struct InstructionEntry {
    name: String,
    pascal: String,
    has_result: bool,
    is_terminator: bool,
    can_trap: bool,
    is_observation: bool,
}

fn main() {
    println!("cargo:rerun-if-changed=../../../pseudolearn_spec/specifications/export.json");
    if let Err(error) = generate() {
        eprintln!("IR instruction generation failed: {error}");
        std::process::exit(1);
    }
}

fn generate() -> Result<(), Box<dyn std::error::Error>> {
    let manifest = std::env::var("CARGO_MANIFEST_DIR")?;
    let export_path =
        Path::new(&manifest).join("../../../pseudolearn_spec/specifications/export.json");
    let export_text = std::fs::read_to_string(export_path)?;
    let parsed: serde_json::Value = serde_json::from_str(&export_text)?;
    let instructions = extract_instructions(&parsed)?;

    let mut output = String::new();
    output.push_str(&generate_enum(&instructions));
    output.push_str(&generate_as_str(&instructions));
    output.push_str(&generate_from_name(&instructions));
    output.push_str(&generate_properties(&instructions));

    let out_dir = std::env::var("OUT_DIR")?;
    std::fs::write(
        Path::new(&out_dir).join("generated_instructions.rs"),
        output,
    )?;
    Ok(())
}

fn extract_instructions(
    parsed: &serde_json::Value,
) -> Result<Vec<InstructionEntry>, Box<dyn std::error::Error>> {
    let specifications = parsed
        .get("specifications")
        .and_then(serde_json::Value::as_array)
        .ok_or("Missing specifications array in export.json")?;
    let instruction_spec = specifications
        .iter()
        .find(|spec| {
            spec.get("metadata")
                .and_then(|meta| meta.get("id"))
                .and_then(serde_json::Value::as_str)
                == Some("IR.INSTRUCTIONS")
        })
        .ok_or("Missing IR.INSTRUCTIONS specification")?;
    let blocks = instruction_spec
        .get("blocks")
        .and_then(serde_json::Value::as_array)
        .ok_or("Missing blocks in IR.INSTRUCTIONS")?;

    let mut entries = Vec::new();
    for block in blocks {
        if block.get("kind").and_then(serde_json::Value::as_str) == Some("instruccion") {
            entries.push(parse_instruction_block(block)?);
        }
    }
    Ok(entries)
}

fn parse_instruction_block(
    block: &serde_json::Value,
) -> Result<InstructionEntry, Box<dyn std::error::Error>> {
    let fields = block.get("fields").ok_or("Missing fields")?;
    let name = fields
        .get("nombre")
        .and_then(serde_json::Value::as_str)
        .ok_or("Missing name")?
        .to_owned();
    let signature = fields
        .get("firma")
        .and_then(serde_json::Value::as_str)
        .unwrap_or("");
    let has_result = signature.contains("->") && !signature.ends_with("-> unit");
    let is_terminator = matches!(
        name.as_str(),
        "jump" | "branch" | "return" | "trap.missing_return" | "unreachable"
    );
    let can_trap = fields
        .get("trampas")
        .and_then(serde_json::Value::as_array)
        .is_some_and(|traps| !traps.is_empty());
    let is_observation = fields
        .get("observacion")
        .and_then(serde_json::Value::as_array)
        .is_some_and(|observations| !observations.is_empty());
    let pascal = to_pascal_case(&name);
    Ok(InstructionEntry {
        name,
        pascal,
        has_result,
        is_terminator,
        can_trap,
        is_observation,
    })
}

fn generate_enum(entries: &[InstructionEntry]) -> String {
    let mut code = String::new();
    code.push_str("#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]\n");
    code.push_str("pub enum Operation {\n");
    for entry in entries {
        code.push_str(&format!("    {},\n", entry.pascal));
    }
    code.push_str("}\n\n");
    code.push_str("impl Operation {\n");
    code.push_str("    pub const ALL: &'static [Operation] = &[\n");
    for entry in entries {
        code.push_str(&format!("        Operation::{},\n", entry.pascal));
    }
    code.push_str("    ];\n");
    code.push_str("}\n\n");
    code
}

fn generate_as_str(entries: &[InstructionEntry]) -> String {
    let chunks: Vec<&[InstructionEntry]> = entries.chunks(25).collect();
    let mut code = String::new();
    code.push_str("impl Operation {\n");
    code.push_str("    pub fn as_str(&self) -> &'static str {\n");
    for index in 0..chunks.len() {
        code.push_str(&format!(
            "        if let Some(text) = self.as_str_slice_{index}() {{ return text; }}\n"
        ));
    }
    code.push_str("        \"\"\n");
    code.push_str("    }\n\n");

    for (index, chunk) in chunks.iter().enumerate() {
        code.push_str(&format!(
            "    fn as_str_slice_{index}(&self) -> Option<&'static str> {{\n"
        ));
        code.push_str("        match self {\n");
        for entry in *chunk {
            code.push_str(&format!(
                "            Self::{} => Some(\"{}\"),\n",
                entry.pascal, entry.name
            ));
        }
        code.push_str("            _ => None,\n");
        code.push_str("        }\n");
        code.push_str("    }\n\n");
    }
    code.push_str("}\n\n");
    code
}

fn generate_from_name(entries: &[InstructionEntry]) -> String {
    let chunks: Vec<&[InstructionEntry]> = entries.chunks(25).collect();
    let mut code = String::new();
    code.push_str("impl Operation {\n");
    code.push_str("    pub fn from_name(name: &str) -> Option<Self> {\n");
    for index in 0..chunks.len() {
        code.push_str(&format!(
            "        if let Some(operation) = Self::from_name_slice_{index}(name) {{ return Some(operation); }}\n"
        ));
    }
    code.push_str("        None\n");
    code.push_str("    }\n\n");

    for (index, chunk) in chunks.iter().enumerate() {
        code.push_str(&format!(
            "    fn from_name_slice_{index}(name: &str) -> Option<Self> {{\n"
        ));
        code.push_str("        match name {\n");
        for entry in *chunk {
            code.push_str(&format!(
                "            \"{}\" => Some(Self::{}),\n",
                entry.name, entry.pascal
            ));
        }
        code.push_str("            _ => None,\n");
        code.push_str("        }\n");
        code.push_str("    }\n\n");
    }
    code.push_str("}\n\n");
    code
}

fn generate_properties(entries: &[InstructionEntry]) -> String {
    let mut code = String::new();
    code.push_str("impl Operation {\n");
    code.push_str("    pub fn is_terminator(&self) -> bool {\n");
    code.push_str("        matches!(self,\n");
    for entry in entries.iter().filter(|entry| entry.is_terminator) {
        code.push_str(&format!("            | Self::{}\n", entry.pascal));
    }
    code.push_str("        )\n");
    code.push_str("    }\n\n");

    code.push_str("    pub fn can_trap(&self) -> bool {\n");
    code.push_str("        matches!(self,\n");
    for entry in entries.iter().filter(|entry| entry.can_trap) {
        code.push_str(&format!("            | Self::{}\n", entry.pascal));
    }
    code.push_str("        )\n");
    code.push_str("    }\n\n");

    code.push_str("    pub fn is_observation(&self) -> bool {\n");
    code.push_str("        matches!(self,\n");
    for entry in entries.iter().filter(|entry| entry.is_observation) {
        code.push_str(&format!("            | Self::{}\n", entry.pascal));
    }
    code.push_str("        )\n");
    code.push_str("    }\n\n");

    code.push_str("    pub fn has_result(&self) -> bool {\n");
    code.push_str("        matches!(self,\n");
    for entry in entries.iter().filter(|entry| entry.has_result) {
        code.push_str(&format!("            | Self::{}\n", entry.pascal));
    }
    code.push_str("        )\n");
    code.push_str("    }\n");
    code.push_str("}\n");
    code
}

fn to_pascal_case(name: &str) -> String {
    let mut outcome = String::new();
    let mut capitalize_next = true;
    for character in name.chars() {
        if character == '.' || character == '_' || character == '-' {
            capitalize_next = true;
        } else if capitalize_next {
            outcome.extend(character.to_uppercase());
            capitalize_next = false;
        } else {
            outcome.push(character);
        }
    }
    outcome
}
