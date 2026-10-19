#[path = "codegen/function_metadata.rs"]
mod function_metadata;
#[path = "codegen/perfect_hash.rs"]
mod perfect_hash;
use std::path::Path;

fn main() {
    println!("cargo:rerun-if-changed=../../../pseudolearn_spec/specifications/export.json");
    if let Err(error) = generate() {
        eprintln!("Failed to generate lexicon: {error}");
        std::process::exit(1);
    }
}

fn generate() -> Result<(), Box<dyn std::error::Error>> {
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR")?;
    let export_path =
        Path::new(&manifest_dir).join("../../../pseudolearn_spec/specifications/export.json");
    let export_text = std::fs::read_to_string(export_path)?;
    let parsed: serde_json::Value = serde_json::from_str(&export_text)?;
    let vocabulary = parsed
        .get("resources")
        .and_then(|resource_tree| resource_tree.get("vocabulary"))
        .and_then(serde_json::Value::as_object)
        .ok_or("Missing vocabulary in export.json")?;
    let functions = parsed
        .get("resources")
        .and_then(|resource_tree| resource_tree.get("functions"))
        .and_then(serde_json::Value::as_object)
        .ok_or("Missing functions in export.json")?;

    let out_dir = std::env::var("OUT_DIR")?;
    let destination = Path::new(&out_dir).join("generated_lexicon.rs");
    let mut code = String::new();
    code.push_str(&generate_enums(vocabulary, functions));
    code.push_str(&generate_keywords(vocabulary));
    code.push_str(&generate_builtins(functions));
    code.push_str(&function_metadata::signatures(functions)?);
    code.push_str(&function_metadata::canonical_words(vocabulary)?);
    code.push_str(&function_metadata::canonical_builtin_words(functions)?);
    code.push_str(&function_metadata::compound_prefixes(vocabulary));
    code.push_str(&generate_openers(vocabulary));

    std::fs::write(destination, code)?;
    Ok(())
}

fn generate_enums(
    vocabulary: &serde_json::Map<String, serde_json::Value>,
    functions: &serde_json::Map<String, serde_json::Value>,
) -> String {
    let mut code = String::new();
    code.push_str("#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]\n");
    code.push_str("pub enum KeywordKind {\n");
    for identity in vocabulary.keys() {
        let pascal = to_pascal_case(identity);
        code.push_str(&format!("    {pascal},\n"));
    }
    code.push_str("}\n\n");
    code.push_str("#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]\n");
    code.push_str("pub enum BuiltinKind {\n");
    for identity in functions.keys() {
        let pascal = to_pascal_case(identity);
        code.push_str(&format!("    {pascal},\n"));
    }
    code.push_str("}\n\n");
    code
}

fn generate_keywords(vocabulary: &serde_json::Map<String, serde_json::Value>) -> String {
    let mut code = String::new();
    code.push_str("impl KeywordKind {\n");
    code.push_str("    pub fn all() -> &'static [KeywordKind] {\n        &[\n");
    for identity in vocabulary.keys() {
        let pascal = to_pascal_case(identity);
        code.push_str(&format!("            Self::{pascal},\n"));
    }
    code.push_str("        ]\n    }\n");
    code.push_str("    pub fn as_str(&self) -> &'static str {\n");
    code.push_str("        match self {\n");
    for identity in vocabulary.keys() {
        let pascal = to_pascal_case(identity);
        code.push_str(&format!("            Self::{pascal} => \"{identity}\",\n"));
    }
    code.push_str("        }\n");
    code.push_str("    }\n");
    code.push_str("}\n\n");

    code.push_str(&perfect_hash::generate(
        "keyword",
        "KeywordKind",
        collect_pairs(vocabulary),
    ));

    code
}

fn generate_builtins(functions: &serde_json::Map<String, serde_json::Value>) -> String {
    let mut code = String::new();
    code.push_str("impl BuiltinKind {\n");
    code.push_str("    pub fn all() -> &'static [BuiltinKind] {\n        &[\n");
    for identity in functions.keys() {
        let pascal = to_pascal_case(identity);
        code.push_str(&format!("            Self::{pascal},\n"));
    }
    code.push_str("        ]\n    }\n");
    code.push_str("    pub fn as_str(&self) -> &'static str {\n");
    code.push_str("        match self {\n");
    for identity in functions.keys() {
        let pascal = to_pascal_case(identity);
        code.push_str(&format!("            Self::{pascal} => \"{identity}\",\n"));
    }
    code.push_str("        }\n");
    code.push_str("    }\n");
    code.push_str("}\n\n");

    code.push_str(&perfect_hash::generate(
        "builtin",
        "BuiltinKind",
        collect_pairs(functions),
    ));

    code
}

type FormPair = (String, String);
type ProfilePairs = (Vec<FormPair>, Vec<FormPair>);

fn collect_pairs(dictionary: &serde_json::Map<String, serde_json::Value>) -> ProfilePairs {
    let mut spanish_pairs = Vec::new();
    let mut english_pairs = Vec::new();
    for (identity, definition) in dictionary {
        let pascal = to_pascal_case(identity);
        for form in collect_forms(definition, "es") {
            spanish_pairs.push((form, pascal.clone()));
        }
        for form in collect_forms(definition, "en") {
            english_pairs.push((form, pascal.clone()));
        }
    }
    spanish_pairs.sort_by(|left_pair, right_pair| left_pair.0.cmp(&right_pair.0));
    spanish_pairs.dedup_by(|left_pair, right_pair| left_pair.0 == right_pair.0);
    english_pairs.sort_by(|left_pair, right_pair| left_pair.0.cmp(&right_pair.0));
    english_pairs.dedup_by(|left_pair, right_pair| left_pair.0 == right_pair.0);
    (spanish_pairs, english_pairs)
}

fn generate_openers(vocabulary: &serde_json::Map<String, serde_json::Value>) -> String {
    let mut code = String::new();
    let (spanish_openers, english_openers) = collect_openers(vocabulary);

    code.push_str(&format_opener_array("OPENERS_ES", &spanish_openers));
    code.push_str(&format_opener_array("OPENERS_EN", &english_openers));

    code.push_str(
        "pub fn detect_profile_from_opener(folded_word: &str) -> Option<&'static str> {\n",
    );
    code.push_str("    if OPENERS_ES.binary_search(&folded_word).is_ok() {\n");
    code.push_str("        Some(\"es\")\n");
    code.push_str("    } else if OPENERS_EN.binary_search(&folded_word).is_ok() {\n");
    code.push_str("        Some(\"en\")\n");
    code.push_str("    } else {\n");
    code.push_str("        None\n");
    code.push_str("    }\n");
    code.push_str("}\n");
    code
}

fn collect_openers(
    vocabulary: &serde_json::Map<String, serde_json::Value>,
) -> (Vec<String>, Vec<String>) {
    let mut spanish = Vec::new();
    let mut english = Vec::new();
    for opener in ["algorithm", "classKeyword", "subroutine"] {
        if let Some(keyword_definition) = vocabulary.get(opener) {
            for form in collect_forms(keyword_definition, "es") {
                spanish.push(form);
            }
            for form in collect_forms(keyword_definition, "en") {
                english.push(form);
            }
        }
    }
    spanish.sort();
    spanish.dedup();
    english.sort();
    english.dedup();
    (spanish, english)
}

fn format_opener_array(name: &str, items: &[String]) -> String {
    let length = items.len();
    let mut code = format!("const {name}: [&str; {length}] = [\n");
    for form in items {
        let escaped = form.replace('\\', "\\\\").replace('"', "\\\"");
        code.push_str(&format!("    \"{escaped}\",\n"));
    }
    code.push_str("];\n\n");
    code
}

fn collect_forms(definition: &serde_json::Value, profile: &str) -> Vec<String> {
    let mut forms = Vec::new();
    if let Some(lex) = definition
        .get("lexemas")
        .and_then(|lexemes_map| lexemes_map.get(profile))
        .and_then(serde_json::Value::as_str)
    {
        forms.push(folded(lex));
    }
    if let Some(aliases) = definition
        .get("alias")
        .and_then(|alias_map| alias_map.get(profile))
        .and_then(serde_json::Value::as_array)
    {
        for alias in aliases {
            if let Some(alias_text) = alias.as_str() {
                forms.push(folded(alias_text));
            }
        }
    }
    forms.sort();
    forms.dedup();
    forms
}

fn folded(text: &str) -> String {
    text.chars()
        .flat_map(char::to_lowercase)
        .map(|character| match character {
            'á' | 'à' | 'ä' | 'â' => 'a',
            'é' | 'è' | 'ë' | 'ê' => 'e',
            'í' | 'ì' | 'ï' | 'î' => 'i',
            'ó' | 'ò' | 'ö' | 'ô' => 'o',
            'ú' | 'ù' | 'ü' | 'û' => 'u',
            'ñ' => 'n',
            other => other,
        })
        .collect()
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
