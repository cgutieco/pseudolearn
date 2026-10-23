use crate::help_catalog::{HelpExample, HelpLocale};
use crate::help_content::HelpContent;

const MARKDOWN_SPECIALS: &str = "\\`*_{}[]()#+-.!|<>~&:/@";
pub const MAXIMUM_RENDERED_BYTES: usize = 8192;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum HelpRenderError {
    TooLarge { limit: usize },
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum HelpFormat {
    Markdown,
    PlainText,
}

struct Labels {
    purpose: &'static str,
    parts: &'static str,
    constraints: &'static str,
    common_errors: &'static str,
    examples: &'static str,
    omitted: &'static str,
}

const SPANISH: Labels = Labels {
    purpose: "Propósito",
    parts: "Partes",
    constraints: "Restricciones",
    common_errors: "Errores comunes",
    examples: "Ejemplos",
    omitted: "Contenido omitido por superar el límite de tamaño.",
};

const ENGLISH: Labels = Labels {
    purpose: "Purpose",
    parts: "Parts",
    constraints: "Constraints",
    common_errors: "Common errors",
    examples: "Examples",
    omitted: "Content omitted because it exceeds the size limit.",
};

pub fn omitted_notice(locale: HelpLocale) -> &'static str {
    labels_for(locale).omitted
}

fn labels_for(locale: HelpLocale) -> &'static Labels {
    match locale {
        HelpLocale::Spanish => &SPANISH,
        HelpLocale::English => &ENGLISH,
    }
}

pub fn render_help(
    content: &HelpContent,
    locale: HelpLocale,
    format: HelpFormat,
) -> Result<String, HelpRenderError> {
    let labels = labels_for(locale);
    let mut blocks = vec![
        heading(content.title, format),
        inert_text(content.summary, format),
    ];
    if let Some(description) = content.description {
        blocks.push(inert_text(description, format));
    }
    blocks.push(section(labels.purpose, &[content.purpose], format));
    push_section(&mut blocks, labels.parts, &part_lines(content), format);
    push_section(&mut blocks, labels.constraints, content.constraints, format);
    push_section(
        &mut blocks,
        labels.common_errors,
        content.common_errors,
        format,
    );
    push_section(
        &mut blocks,
        labels.examples,
        &example_lines(content),
        format,
    );
    let rendered = blocks.join("\n\n");
    if rendered.len() > MAXIMUM_RENDERED_BYTES {
        return Err(HelpRenderError::TooLarge {
            limit: MAXIMUM_RENDERED_BYTES,
        });
    }
    Ok(rendered)
}

fn part_lines(content: &HelpContent) -> Vec<&'static str> {
    content.parts.iter().map(|part| part.text).collect()
}

fn example_lines(content: &HelpContent) -> Vec<&'static str> {
    content
        .examples
        .iter()
        .map(|example| example.label)
        .collect()
}

fn push_section<Line: AsRef<str>>(
    blocks: &mut Vec<String>,
    label: &str,
    lines: &[Line],
    format: HelpFormat,
) {
    if !lines.is_empty() {
        blocks.push(section(label, lines, format));
    }
}

fn section<Line: AsRef<str>>(label: &str, lines: &[Line], format: HelpFormat) -> String {
    let body: Vec<String> = lines
        .iter()
        .map(|line| format!("- {}", inert_text(line.as_ref(), format)))
        .collect();
    format!("{}\n{}", heading(label, format), body.join("\n"))
}

fn heading(value: &str, format: HelpFormat) -> String {
    match format {
        HelpFormat::Markdown => format!("**{}**", escape_markdown(value)),
        HelpFormat::PlainText => inert_text(value, format),
    }
}

pub fn inert_text(value: &str, format: HelpFormat) -> String {
    match format {
        HelpFormat::Markdown => escape_markdown(value),
        HelpFormat::PlainText => value
            .chars()
            .filter(|glyph| !is_inert_control(*glyph))
            .collect(),
    }
}

fn is_inert_control(glyph: char) -> bool {
    glyph.is_control()
        || matches!(glyph, '\u{200E}' | '\u{200F}' | '\u{202A}'..='\u{202E}' | '\u{2066}'..='\u{2069}')
}

pub fn escape_markdown(value: &str) -> String {
    let mut escaped = String::with_capacity(value.len());
    for glyph in value.chars().filter(|glyph| !is_inert_control(*glyph)) {
        if MARKDOWN_SPECIALS.contains(glyph) {
            escaped.push('\\');
        }
        escaped.push(glyph);
    }
    escaped
}

pub fn example_reference(example: &HelpExample) -> String {
    format!(
        "{}@{}#{}",
        example.specification, example.version, example.case
    )
}
