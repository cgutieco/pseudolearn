#[path = "codegen/policy.rs"]
mod policy;
use std::path::Path;

fn main() {
    println!("cargo:rerun-if-changed=../../../pseudolearn_spec/specifications/export.json");
    if let Err(error) = generate() {
        eprintln!("Failed to generate diagnostics: {error}");
        std::process::exit(1);
    }
}

fn generate() -> Result<(), Box<dyn std::error::Error>> {
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR")?;
    let export_path =
        Path::new(&manifest_dir).join("../../../pseudolearn_spec/specifications/export.json");
    let export_text = std::fs::read_to_string(export_path)?;
    let parsed: serde_json::Value = serde_json::from_str(&export_text)?;
    let diagnostics = parsed
        .get("resources")
        .and_then(|resource_tree| resource_tree.get("diagnostics"))
        .and_then(serde_json::Value::as_object)
        .ok_or("Missing diagnostics in export.json")?;

    let out_dir = std::env::var("OUT_DIR")?;
    let destination = Path::new(&out_dir).join("generated_diagnostics.rs");
    let mut code = String::new();
    code.push_str(&generate_enum(diagnostics));
    code.push_str(&generate_as_str_methods(diagnostics));
    code.push_str(&generate_from_name_methods(diagnostics));
    code.push_str(&generate_template_methods(diagnostics));
    code.push_str(&policy::generate(diagnostics)?);

    std::fs::write(destination, code)?;
    Ok(())
}

fn generate_enum(diagnostics: &serde_json::Map<String, serde_json::Value>) -> String {
    let mut code = String::new();
    code.push_str("#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]\n");
    code.push_str("pub enum DiagnosticCode {\n");
    for identifier in diagnostics.keys() {
        let pascal = to_pascal_case(identifier);
        code.push_str(&format!("    {pascal},\n"));
    }
    code.push_str("}\n\n");
    code
}

fn generate_as_str_methods(diagnostics: &serde_json::Map<String, serde_json::Value>) -> String {
    let items: Vec<(&String, String)> = diagnostics
        .keys()
        .map(|key_name| (key_name, to_pascal_case(key_name)))
        .collect();
    let chunks: Vec<&[(&String, String)]> = items.chunks(35).collect();
    let mut code = String::new();
    code.push_str("impl DiagnosticCode {\n");
    code.push_str("    pub fn as_str(&self) -> &'static str {\n");
    for index in 0..chunks.len() {
        code.push_str(&format!(
            "        if let Some(name) = self.as_str_part_{index}() {{ return name; }}\n"
        ));
    }
    code.push_str("        \"\"\n");
    code.push_str("    }\n\n");

    for (index, chunk) in chunks.iter().enumerate() {
        code.push_str(&format!(
            "    fn as_str_part_{index}(&self) -> Option<&'static str> {{\n"
        ));
        code.push_str("        match self {\n");
        for (identifier, pascal) in *chunk {
            code.push_str(&format!(
                "            Self::{pascal} => Some(\"{identifier}\"),\n"
            ));
        }
        code.push_str("            _ => None,\n");
        code.push_str("        }\n");
        code.push_str("    }\n\n");
    }
    code.push_str("}\n\n");
    code
}

fn generate_from_name_methods(diagnostics: &serde_json::Map<String, serde_json::Value>) -> String {
    let items: Vec<(&String, String)> = diagnostics
        .keys()
        .map(|key_name| (key_name, to_pascal_case(key_name)))
        .collect();
    let chunks: Vec<&[(&String, String)]> = items.chunks(35).collect();
    let mut code = String::new();
    code.push_str("impl DiagnosticCode {\n");
    code.push_str("    pub fn from_name(name: &str) -> Option<Self> {\n");
    for index in 0..chunks.len() {
        code.push_str(&format!(
            "        if let Some(code) = Self::from_name_part_{index}(name) {{ return Some(code); }}\n"
        ));
    }
    code.push_str("        None\n");
    code.push_str("    }\n\n");

    for (index, chunk) in chunks.iter().enumerate() {
        code.push_str(&format!(
            "    fn from_name_part_{index}(name: &str) -> Option<Self> {{\n"
        ));
        code.push_str("        match name {\n");
        for (identifier, pascal) in *chunk {
            code.push_str(&format!(
                "            \"{identifier}\" => Some(Self::{pascal}),\n"
            ));
        }
        code.push_str("            _ => None,\n");
        code.push_str("        }\n");
        code.push_str("    }\n\n");
    }
    code.push_str("}\n\n");
    code
}

fn generate_template_methods(diagnostics: &serde_json::Map<String, serde_json::Value>) -> String {
    let items: Vec<(&String, &serde_json::Value)> = diagnostics.iter().collect();
    let chunks: Vec<&[(&String, &serde_json::Value)]> = items.chunks(35).collect();
    let mut code = String::new();
    code.push_str("impl DiagnosticCode {\n");
    code.push_str("    pub fn template(&self, locale: &str) -> &'static str {\n");
    for index in 0..chunks.len() {
        code.push_str(&format!(
            "        if let Some(text) = self.template_part_{index}(locale) {{ return text; }}\n"
        ));
    }
    code.push_str("        \"\"\n");
    code.push_str("    }\n\n");

    for (index, chunk) in chunks.iter().enumerate() {
        code.push_str(&format!(
            "    fn template_part_{index}(&self, locale: &str) -> Option<&'static str> {{\n"
        ));
        code.push_str("        match self {\n");
        code.push_str(&format_template_arms(chunk));
        code.push_str("            _ => None,\n");
        code.push_str("        }\n");
        code.push_str("    }\n\n");
    }
    code.push_str("}\n\n");
    code
}

fn format_template_arms(chunk: &[(&String, &serde_json::Value)]) -> String {
    let mut arms = String::new();
    for (identifier, entry_value) in chunk {
        let pascal = to_pascal_case(identifier);
        let spanish_text = entry_value
            .get("mensajes")
            .and_then(|messages| messages.get("es"))
            .and_then(serde_json::Value::as_str)
            .unwrap_or("");
        let english_text = entry_value
            .get("mensajes")
            .and_then(|messages| messages.get("en"))
            .and_then(serde_json::Value::as_str)
            .unwrap_or("");
        let escaped_es = spanish_text.replace('\\', "\\\\").replace('"', "\\\"");
        let escaped_en = english_text.replace('\\', "\\\\").replace('"', "\\\"");
        arms.push_str(&format!(
            "            Self::{pascal} => Some(if locale == \"en\" {{ \"{escaped_en}\" }} else {{ \"{escaped_es}\" }}),\n"
        ));
    }
    arms
}

fn to_pascal_case(text: &str) -> String {
    let mut outcome = String::new();
    let mut capitalize_next = true;
    for character in text.chars() {
        if character == '_' || character == '-' || character == '.' {
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
