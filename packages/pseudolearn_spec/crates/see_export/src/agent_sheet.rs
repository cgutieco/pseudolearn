use see_model::{Block, Corpus, field};
use serde_json::Value;
use std::fmt::Write;

pub struct SheetLanguage<'language> {
    pub code: &'language str,
    pub labels: &'language Value,
}

pub fn render(
    corpus: &Corpus,
    resources: &Value,
    settings: &Value,
    language: &SheetLanguage<'_>,
) -> Result<String, String> {
    let mut sheet = String::new();
    heading(&mut sheet, language, "title", 1)?;
    paragraph(&mut sheet, &label(language, "introduction")?);
    principles(&mut sheet, settings, language)?;
    crate::agent_sheet_vocabulary::vocabulary(&mut sheet, resources, language)?;
    crate::agent_sheet_vocabulary::library(&mut sheet, resources, language)?;
    grammar(&mut sheet, resources, language)?;
    differences(&mut sheet, corpus, settings, language)?;
    crate::agent_sheet_examples::examples(&mut sheet, corpus, settings, language)?;
    Ok(sheet)
}

pub fn label(language: &SheetLanguage<'_>, key: &str) -> Result<String, String> {
    language
        .labels
        .get(key)
        .and_then(Value::as_str)
        .map(str::to_owned)
        .ok_or_else(|| format!("SEE-AGENT-SHEET: missing label {key} for {}", language.code))
}

pub fn heading(
    sheet: &mut String,
    language: &SheetLanguage<'_>,
    key: &str,
    level: usize,
) -> Result<(), String> {
    let marks = "#".repeat(level);
    writeln!(sheet, "{marks} {}\n", label(language, key)?).map_err(|error| error.to_string())
}

pub fn paragraph(sheet: &mut String, text: &str) {
    sheet.push_str(text);
    sheet.push_str("\n\n");
}

pub fn localized<'value>(value: &'value Value, code: &str) -> Result<&'value str, String> {
    value
        .get(code)
        .and_then(Value::as_str)
        .ok_or_else(|| format!("SEE-AGENT-SHEET: missing {code} text"))
}

pub fn rule_text<'corpus>(
    corpus: &'corpus Corpus,
    reference: &str,
) -> Result<&'corpus str, String> {
    let (specification, rule) = reference
        .split_once('#')
        .ok_or_else(|| format!("SEE-AGENT-SHEET: invalid reference {reference}"))?;
    block_of(corpus, specification, "regla", rule)
        .map(|block| field(block, "texto"))
        .filter(|text| !text.is_empty())
        .ok_or_else(|| format!("SEE-AGENT-SHEET: unknown rule {reference}"))
}

pub fn block_of<'corpus>(
    corpus: &'corpus Corpus,
    specification: &str,
    kind: &str,
    identity: &str,
) -> Option<&'corpus Block> {
    corpus
        .iter()
        .find(|candidate| candidate.metadata.id == specification)?
        .blocks
        .iter()
        .find(|block| block.kind == kind && field(block, "id") == identity)
}

fn principles(
    sheet: &mut String,
    settings: &Value,
    language: &SheetLanguage<'_>,
) -> Result<(), String> {
    heading(sheet, language, "principles", 2)?;
    let entries = settings
        .get("principles")
        .and_then(|principles| principles.get(language.code))
        .and_then(Value::as_array)
        .ok_or("SEE-AGENT-SHEET: missing principles")?;
    for entry in entries {
        let text = entry.as_str().ok_or("SEE-AGENT-SHEET: invalid principle")?;
        writeln!(sheet, "- {text}").map_err(|error| error.to_string())?;
    }
    sheet.push('\n');
    Ok(())
}

fn grammar(
    sheet: &mut String,
    resources: &Value,
    language: &SheetLanguage<'_>,
) -> Result<(), String> {
    heading(sheet, language, "grammar", 2)?;
    paragraph(sheet, &label(language, "grammarNote")?);
    let productions = resources
        .pointer("/grammar/producciones")
        .and_then(Value::as_object)
        .ok_or("SEE-AGENT-SHEET: missing grammar")?;
    sheet.push_str("```ebnf\n");
    for (name, production) in productions {
        let text = production
            .as_str()
            .ok_or("SEE-AGENT-SHEET: invalid production")?;
        writeln!(sheet, "{name} = {text} ;").map_err(|error| error.to_string())?;
    }
    sheet.push_str("```\n\n");
    Ok(())
}

fn differences(
    sheet: &mut String,
    corpus: &Corpus,
    settings: &Value,
    language: &SheetLanguage<'_>,
) -> Result<(), String> {
    heading(sheet, language, "differences", 2)?;
    let entries = settings
        .get("differences")
        .and_then(Value::as_array)
        .ok_or("SEE-AGENT-SHEET: missing differences")?;
    let rule_label = label(language, "rule")?;
    for entry in entries {
        let reference = entry
            .get("rule")
            .and_then(Value::as_str)
            .ok_or("SEE-AGENT-SHEET: difference without rule")?;
        let note = localized(entry, language.code)?;
        let text = rule_text(corpus, reference)?;
        writeln!(sheet, "- {note} {rule_label} `{reference}`: «{text}»")
            .map_err(|error| error.to_string())?;
    }
    sheet.push('\n');
    Ok(())
}
