#![forbid(unsafe_code)]

use crate::{GenerationResult, array_field, text_field};

pub(crate) fn instruction_names(export: &serde_json::Value) -> GenerationResult<Vec<String>> {
    let specification = array_field(export, "specifications")?
        .iter()
        .find(|entry| {
            entry
                .pointer("/metadata/id")
                .and_then(serde_json::Value::as_str)
                == Some("IR.INSTRUCTIONS")
        })
        .ok_or("Missing IR.INSTRUCTIONS")?;
    let mut names = Vec::new();
    for block in array_field(specification, "blocks")? {
        if block.get("kind").and_then(serde_json::Value::as_str) == Some("instruccion") {
            let fields = block.get("fields").ok_or("Missing instruction fields")?;
            names.push(text_field(fields, "nombre")?.to_owned());
        }
    }
    if names.is_empty() {
        return Err("IR.INSTRUCTIONS is empty".into());
    }
    Ok(names)
}

pub(crate) fn verify_coverage(
    names: &[String],
    categories: &[serde_json::Value],
    operations: &[serde_json::Value],
) -> GenerationResult<()> {
    for name in names {
        let scalar = dispatch_category(name, categories) == "Scalar";
        let covered = operations
            .iter()
            .any(|operation| text_field(operation, "opcode").ok() == Some(name.as_str()));
        if scalar && !covered {
            return Err(format!("Scalar instruction {name} has no dispatch form").into());
        }
    }
    Ok(())
}

pub(crate) fn render_kinds(names: &[String], categories: &[serde_json::Value]) -> String {
    let arms_list: Vec<(String, String)> = names
        .iter()
        .map(|name| (pascal_case(name), dispatch_category(name, categories)))
        .collect();
    let kinds = arms_list
        .iter()
        .map(|(_, kind)| kind.as_str())
        .collect::<std::collections::BTreeSet<_>>()
        .into_iter()
        .collect::<Vec<_>>()
        .join(", ");
    let arms = arms_list
        .iter()
        .map(|(pascal, kind)| {
            format!("pseudolearn_bytecode::Opcode::{pascal} => DispatchKind::{kind},")
        })
        .collect::<Vec<_>>()
        .join(" ");
    format!(
        "#[derive(Clone, Copy, Debug, Eq, PartialEq)]\npub(crate) enum DispatchKind {{ {kinds} }}\n\npub(crate) fn dispatch_kind(opcode: pseudolearn_bytecode::Opcode) -> DispatchKind {{ match opcode {{ {arms} }} }}\n\n"
    )
}

fn dispatch_category(name: &str, categories: &[serde_json::Value]) -> String {
    let listed = |field: &str, category: &serde_json::Value, matches: &dyn Fn(&str) -> bool| {
        array_field(category, field)
            .map(|entries| {
                entries
                    .iter()
                    .filter_map(serde_json::Value::as_str)
                    .any(matches)
            })
            .unwrap_or(false)
    };
    categories
        .iter()
        .find(|category| {
            listed("prefixes", category, &|prefix| name.starts_with(prefix))
                || listed("names", category, &|exact| name == exact)
        })
        .and_then(|category| text_field(category, "kind").ok())
        .unwrap_or("Other")
        .to_owned()
}

pub(crate) fn pascal_case(name: &str) -> String {
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
