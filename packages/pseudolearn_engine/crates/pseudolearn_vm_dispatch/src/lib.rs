#![forbid(unsafe_code)]

mod catalog;
mod forms;
mod render;

use std::path::Path;

pub type GenerationResult<Output> = Result<Output, Box<dyn std::error::Error>>;

pub fn generate(export_path: &Path, forms_path: &Path) -> GenerationResult<String> {
    let export = read_json(export_path)?;
    let forms = read_json(forms_path)?;
    let names = catalog::instruction_names(&export)?;
    let operations = array_field(&forms, "operations")?;
    let categories = array_field(&forms, "categories")?;
    catalog::verify_coverage(&names, categories, operations)?;
    let shapes = forms.get("shapes").ok_or("Missing shapes")?;
    let mut rendered = forms::Rendered::default();
    for operation in operations {
        forms::expand_operation(operation, shapes, &mut rendered)?;
    }
    for special in array_field(&forms, "special")? {
        rendered.variants.push(forms::special_variant(special)?);
    }
    let mut source = catalog::render_kinds(&names, categories);
    source.push_str(&render::render_dispatch(&rendered));
    source.push_str(&boolean_format(&export)?);
    Ok(source)
}

fn read_json(path: &Path) -> GenerationResult<serde_json::Value> {
    Ok(serde_json::from_str(&std::fs::read_to_string(path)?)?)
}

fn boolean_format(export: &serde_json::Value) -> GenerationResult<String> {
    let mut source = String::from(
        "pub(crate) fn boolean_lexemes(profile: &str) -> pseudolearn_library::BooleanLexemes<'static> { match profile {",
    );
    for profile in ["en", "es"] {
        let truth = export
            .pointer(&format!(
                "/resources/vocabulary/booleanTrue/lexemas/{profile}"
            ))
            .and_then(serde_json::Value::as_str)
            .ok_or("Missing boolean truth lexeme")?;
        let falsity = export
            .pointer(&format!(
                "/resources/vocabulary/booleanFalse/lexemas/{profile}"
            ))
            .and_then(serde_json::Value::as_str)
            .ok_or("Missing boolean falsity lexeme")?;
        let pattern = if profile == "es" {
            "_".to_owned()
        } else {
            format!("{profile:?}")
        };
        source.push_str(&format!("{pattern} => pseudolearn_library::BooleanLexemes {{truth: {truth:?}, falsity:{falsity:?}}},"));
    }
    source.push_str("} }");
    Ok(source)
}

pub(crate) fn array_field<'value>(
    value: &'value serde_json::Value,
    name: &str,
) -> GenerationResult<&'value Vec<serde_json::Value>> {
    Ok(value
        .get(name)
        .and_then(serde_json::Value::as_array)
        .ok_or(format!("Missing array {name}"))?)
}

pub(crate) fn text_field<'value>(
    value: &'value serde_json::Value,
    name: &str,
) -> GenerationResult<&'value str> {
    Ok(value
        .get(name)
        .and_then(serde_json::Value::as_str)
        .ok_or(format!("Missing text {name}"))?)
}
