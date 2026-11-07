use crate::help_sources::{CaseProgram, Failure, Sources};
use serde_json::Value;

#[derive(Clone, Copy)]
enum FormProfile {
    Spanish,
    English,
}

pub fn cards(catalog: &Value, sources: &Sources) -> Result<String, Failure> {
    let mut generated = String::from("pub(crate) static CARDS: &[HelpCard] = &[\n");
    for card in array(catalog, "cards")? {
        generated.push_str(&card_literal(card, sources)?);
    }
    generated.push_str("];\n");
    Ok(generated)
}

fn card_literal(card: &Value, sources: &Sources) -> Result<String, Failure> {
    let identity = field(card, "identity")?;
    let content = field(card, "content")?;
    Ok(format!(
        "HelpCard {{ id: {:?}, kind: {:?}, identity: {:?}, role: {:?}, category: {}, tokens: &[{}], spanish_form: &[{}], english_form: &[{}], spanish: {}, english: {} }},\n",
        text(card, "id")?,
        text(identity, "kind")?,
        text(identity, "id")?,
        text(identity, "role")?,
        category_literal(text(card, "category")?)?,
        joined(array(card, "tokens")?, |token| Ok(format!(
            "{:?}",
            text(token, "identity")?
        )))?,
        form_literal(card, sources, FormProfile::Spanish)?,
        form_literal(card, sources, FormProfile::English)?,
        locale_literal(field(content, "es")?, sources)?,
        locale_literal(field(content, "en")?, sources)?,
    ))
}

fn category_literal(category: &str) -> Result<&'static str, Failure> {
    Ok(match category {
        "block" => "HelpCategory::Block",
        "instruction" => "HelpCategory::Instruction",
        "symbol" => "HelpCategory::Symbol",
        "function" => "HelpCategory::Function",
        "type" => "HelpCategory::Type",
        "value" => "HelpCategory::Value",
        other => return Err(format!("Unknown help category {other}").into()),
    })
}

fn form_literal(card: &Value, sources: &Sources, profile: FormProfile) -> Result<String, Failure> {
    joined(array(card, "form")?, |line| {
        let indent = field(line, "indent")?
            .as_u64()
            .ok_or("Help form indent is not a number")?;
        let pieces = joined(array(line, "segments")?, |segment| {
            piece_literal(segment, sources, profile)
        })?;
        Ok(format!(
            "FormLine {{ indent: {indent}, pieces: &[{pieces}] }}"
        ))
    })
}

fn piece_literal(
    segment: &Value,
    sources: &Sources,
    profile: FormProfile,
) -> Result<String, Failure> {
    let joined = segment
        .get("join")
        .and_then(Value::as_bool)
        .unwrap_or(false);
    let kind = if let Some(token) = segment.get("token").and_then(Value::as_str) {
        let lexemes = sources.lexemes(token)?;
        let lexeme = match profile {
            FormProfile::Spanish => &lexemes.spanish,
            FormProfile::English => &lexemes.english,
        };
        format!("FormSegment::Code {{ identity: {token:?}, text: {lexeme:?} }}")
    } else if let Some(slot) = segment.get("slot").and_then(Value::as_str) {
        format!("FormSegment::Slot({slot:?})")
    } else {
        "FormSegment::Ellipsis".to_owned()
    };
    Ok(format!("FormPiece {{ segment: {kind}, joined: {joined} }}"))
}

fn locale_literal(content: &Value, sources: &Sources) -> Result<String, Failure> {
    Ok(format!(
        "LocaleContent {{ title: {:?}, summary: {:?}, parts: &[{}], slots: &[{}], result: {:?}, rules: &[{}], common_errors: &[{}], examples: &[{}] }}",
        text(content, "title")?,
        text(content, "summary")?,
        joined(array(content, "parts")?, |part| part_literal(part, sources))?,
        joined(array(content, "slots")?, |slot| Ok(format!(
            "HelpSlot {{ id: {:?}, label: {:?}, text: {:?} }}",
            text(slot, "id")?,
            text(slot, "label")?,
            text(slot, "text")?
        )))?,
        content.get("result").and_then(Value::as_str),
        joined(array(content, "rules")?, |rule| Ok(format!(
            "{:?}",
            rule.as_str().ok_or("Help rule is not text")?
        )))?,
        joined(array(content, "common_errors")?, |error| error_literal(
            error, sources
        ))?,
        joined(array(content, "examples")?, |example| example_literal(
            example, sources
        ))?,
    ))
}

fn part_literal(part: &Value, sources: &Sources) -> Result<String, Failure> {
    let identity = text(part, "identity")?;
    let lexemes = sources.lexemes(identity)?;
    Ok(format!(
        "HelpPart {{ identity: {identity:?}, text: {:?}, spanish_lexeme: {:?}, english_lexeme: {:?} }}",
        text(part, "text")?,
        lexemes.spanish,
        lexemes.english
    ))
}

fn error_literal(error: &Value, sources: &Sources) -> Result<String, Failure> {
    let program = match error.get("case") {
        Some(reference) => format!("Some({})", program_literal(sources.program(reference)?)),
        None => "None".to_owned(),
    };
    Ok(format!(
        "HelpCommonError {{ text: {:?}, program: {program} }}",
        text(error, "text")?
    ))
}

fn example_literal(example: &Value, sources: &Sources) -> Result<String, Failure> {
    Ok(format!(
        "HelpExample {{ specification: {:?}, version: {:?}, case: {:?}, kind: {:?}, note: {:?}, program: {} }}",
        text(example, "specification")?,
        text(example, "version")?,
        text(example, "case")?,
        text(example, "kind")?,
        text(example, "note")?,
        program_literal(sources.program(example)?),
    ))
}

fn program_literal(program: &CaseProgram) -> String {
    format!(
        "ExampleProgram {{ spanish: {:?}, english: {:?}, output: {:?} }}",
        program.spanish, program.english, program.output
    )
}

fn joined(
    values: &[Value],
    literal: impl Fn(&Value) -> Result<String, Failure>,
) -> Result<String, Failure> {
    let mut literals = Vec::with_capacity(values.len());
    for value in values {
        literals.push(literal(value)?);
    }
    Ok(literals.join(", "))
}

fn field<'value>(value: &'value Value, key: &str) -> Result<&'value Value, Failure> {
    value
        .get(key)
        .ok_or_else(|| format!("Missing help field {key}").into())
}

fn text<'value>(value: &'value Value, key: &str) -> Result<&'value str, Failure> {
    field(value, key)?
        .as_str()
        .ok_or_else(|| format!("Help field {key} is not text").into())
}

fn array<'value>(value: &'value Value, key: &str) -> Result<&'value Vec<Value>, Failure> {
    field(value, key)?
        .as_array()
        .ok_or_else(|| format!("Help field {key} is not a list").into())
}
