use serde_json::Value;
use std::fmt::Write;
use std::path::Path;

fn main() {
    println!("cargo:rerun-if-changed=../../packages/pseudolearn_spec/specifications/export.json");
    if let Err(error) = generate() {
        eprintln!("CLI generation failed: {error}");
        std::process::exit(1);
    }
}

fn generate() -> Result<(), Box<dyn std::error::Error>> {
    let manifest = std::env::var("CARGO_MANIFEST_DIR")?;
    let path =
        Path::new(&manifest).join("../../packages/pseudolearn_spec/specifications/export.json");
    let corpus: Value = serde_json::from_str(&std::fs::read_to_string(path)?)?;
    let messages = corpus
        .pointer("/resources/cliMessages")
        .and_then(Value::as_object)
        .ok_or("Missing CLI messages")?;
    let mut generated = String::from("static MESSAGES: &[(&str, &str, &str)] = &[\n");
    for (name, entry) in messages {
        for locale in ["es", "en"] {
            let pattern = entry
                .get("mensajes")
                .and_then(|messages| messages.get(locale))
                .and_then(Value::as_str)
                .ok_or("Missing message locale")?;
            let pattern = format!("{pattern}\n");
            writeln!(generated, "({name:?}, {locale:?}, {pattern:?}),")?;
        }
    }
    generated.push_str("];\npub fn template(key: &str, locale: &str) -> &'static str { MESSAGES.iter().find(|(name, language, _)| *name == key && *language == locale).map_or(\"\", |(_, _, pattern)| *pattern) }\n");
    let output = std::env::var("OUT_DIR")?;
    std::fs::write(Path::new(&output).join("generated_messages.rs"), generated)?;
    Ok(())
}
