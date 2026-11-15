use crate::agent_sheet::{SheetLanguage, heading, label, paragraph};
use serde_json::Value;
use std::fmt::Write;

pub fn vocabulary(
    sheet: &mut String,
    resources: &Value,
    language: &SheetLanguage<'_>,
) -> Result<(), String> {
    heading(sheet, language, "vocabulary", 2)?;
    paragraph(sheet, &label(language, "vocabularyNote")?);
    let entries = resources
        .get("vocabulary")
        .and_then(Value::as_object)
        .ok_or("SEE-AGENT-SHEET: missing vocabulary")?;
    writeln!(
        sheet,
        "| {} | es | en |\n|---|---|---|",
        label(language, "identity")?
    )
    .map_err(|error| error.to_string())?;
    for (identity, entry) in entries {
        let (spanish, english) = lexemes(entry)?;
        writeln!(sheet, "| {identity} | `{spanish}` | `{english}` |")
            .map_err(|error| error.to_string())?;
    }
    sheet.push('\n');
    Ok(())
}

pub fn library(
    sheet: &mut String,
    resources: &Value,
    language: &SheetLanguage<'_>,
) -> Result<(), String> {
    heading(sheet, language, "library", 2)?;
    let entries = resources
        .get("functions")
        .and_then(Value::as_object)
        .ok_or("SEE-AGENT-SHEET: missing functions")?;
    writeln!(
        sheet,
        "| es | en | {} | {} |\n|---|---|---|---|",
        label(language, "parameters")?,
        label(language, "result")?
    )
    .map_err(|error| error.to_string())?;
    for entry in entries.values() {
        let (spanish, english) = lexemes(entry)?;
        let parameters = joined(entry.get("parametros"));
        let result = entry.get("retorno").and_then(Value::as_str).unwrap_or("");
        writeln!(
            sheet,
            "| `{spanish}` | `{english}` | {parameters} | {result} |"
        )
        .map_err(|error| error.to_string())?;
    }
    sheet.push('\n');
    operations(sheet, resources, language)
}

fn operations(
    sheet: &mut String,
    resources: &Value,
    language: &SheetLanguage<'_>,
) -> Result<(), String> {
    heading(sheet, language, "operations", 3)?;
    paragraph(sheet, &label(language, "operationsNote")?);
    let entries = resources
        .pointer("/capabilityLibrary/operations")
        .and_then(Value::as_array)
        .ok_or("SEE-AGENT-SHEET: missing capability operations")?;
    for entry in entries {
        let spanish = entry.get("es").and_then(Value::as_str).unwrap_or("");
        let english = entry.get("en").and_then(Value::as_str).unwrap_or("");
        let parameters = joined(entry.get("parameters"));
        let result = entry.get("result").and_then(Value::as_str).unwrap_or("");
        writeln!(
            sheet,
            "- `{spanish}` / `{english}` ({parameters}) → {result}"
        )
        .map_err(|error| error.to_string())?;
    }
    sheet.push('\n');
    Ok(())
}

fn lexemes(entry: &Value) -> Result<(&str, &str), String> {
    let forms = entry
        .get("lexemas")
        .ok_or("SEE-AGENT-SHEET: missing lexemes")?;
    let spanish = forms
        .get("es")
        .and_then(Value::as_str)
        .ok_or("SEE-AGENT-SHEET: missing es")?;
    let english = forms
        .get("en")
        .and_then(Value::as_str)
        .ok_or("SEE-AGENT-SHEET: missing en")?;
    Ok((spanish, english))
}

fn joined(value: Option<&Value>) -> String {
    value
        .and_then(Value::as_array)
        .map(|entries| {
            entries
                .iter()
                .map(|entry| {
                    entry
                        .as_str()
                        .map_or_else(|| entry.to_string(), str::to_owned)
                })
                .collect::<Vec<_>>()
                .join(", ")
        })
        .unwrap_or_default()
}
