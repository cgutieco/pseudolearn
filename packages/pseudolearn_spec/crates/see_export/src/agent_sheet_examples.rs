use crate::agent_sheet::{SheetLanguage, block_of, heading, label, paragraph, rule_text};
use see_model::{Block, Corpus, field, strings};
use serde_json::Value;
use std::fmt::Write;

pub fn examples(
    sheet: &mut String,
    corpus: &Corpus,
    settings: &Value,
    language: &SheetLanguage<'_>,
) -> Result<(), String> {
    heading(sheet, language, "examples", 2)?;
    paragraph(sheet, &label(language, "examplesNote")?);
    let references = settings
        .get("examples")
        .and_then(Value::as_array)
        .ok_or("SEE-AGENT-SHEET: missing examples")?;
    let output_label = label(language, "expectedOutput")?;
    for reference in references {
        let reference = reference
            .as_str()
            .ok_or("SEE-AGENT-SHEET: invalid example")?;
        let (program, output, rule) = example(corpus, reference, language.code)?;
        writeln!(
            sheet,
            "### `{reference}`\n\n{rule}\n\n```pseudolearn\n{program}```\n"
        )
        .map_err(|error| error.to_string())?;
        writeln!(sheet, "{output_label}:\n\n```text\n{output}```\n")
            .map_err(|error| error.to_string())?;
    }
    Ok(())
}

pub fn example<'corpus>(
    corpus: &'corpus Corpus,
    reference: &str,
    code: &str,
) -> Result<(&'corpus str, &'corpus str, &'corpus str), String> {
    let (specification, identity) = reference
        .split_once('#')
        .ok_or_else(|| format!("SEE-AGENT-SHEET: invalid example {reference}"))?;
    let case = block_of(corpus, specification, "caso", identity)
        .ok_or_else(|| format!("SEE-AGENT-SHEET: unknown case {reference}"))?;
    if field(case, "operacion") != "execute"
        || !strings(case.fields.get("perfiles")).contains(&code)
    {
        return Err(format!(
            "SEE-AGENT-SHEET: {reference} is not an executed {code} case"
        ));
    }
    let program = program_of(case, code)
        .ok_or_else(|| format!("SEE-AGENT-SHEET: {reference} has no {code} program"))?;
    let output = case
        .fields
        .get("espera")
        .filter(|expected| expected.get("terminacion").and_then(Value::as_str) == Some("completed"))
        .and_then(|expected| expected.get("salida"))
        .and_then(Value::as_str)
        .ok_or_else(|| format!("SEE-AGENT-SHEET: {reference} has no completed output"))?;
    let rule = rule_text(corpus, &format!("{specification}#{}", field(case, "regla")))?;
    Ok((program, output, rule))
}

fn program_of<'case>(case: &'case Block, code: &str) -> Option<&'case str> {
    case.fields
        .get("programas")
        .and_then(|programs| programs.get(code))
        .and_then(Value::as_str)
        .or_else(|| {
            let base = field(case, "perfil_base");
            let base = if base.is_empty() { "es" } else { base };
            (base == code)
                .then(|| field(case, "programa"))
                .filter(|program| !program.is_empty())
        })
}
