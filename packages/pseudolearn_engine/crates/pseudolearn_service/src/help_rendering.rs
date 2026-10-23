use crate::help_catalog::{HelpExample, HelpLocale};
use crate::help_content::HelpContent;

const MARKDOWN_SPECIALS: &str = "\\`*_{}[]()#+-.!|<>~&";

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
}

const SPANISH: Labels = Labels {
    purpose: "Propósito",
    parts: "Partes",
    constraints: "Restricciones",
    common_errors: "Errores comunes",
    examples: "Ejemplos",
};

const ENGLISH: Labels = Labels {
    purpose: "Purpose",
    parts: "Parts",
    constraints: "Constraints",
    common_errors: "Common errors",
    examples: "Examples",
};

pub fn render_help(content: &HelpContent, locale: HelpLocale, format: HelpFormat) -> String {
    let labels = match locale {
        HelpLocale::Spanish => &SPANISH,
        HelpLocale::English => &ENGLISH,
    };
    let mut blocks = vec![
        heading(content.title, format),
        text(content.summary, format),
    ];
    if let Some(description) = content.description {
        blocks.push(text(description, format));
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
    blocks.join("\n\n")
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
        .map(|line| format!("- {}", text(line.as_ref(), format)))
        .collect();
    format!("{}\n{}", heading(label, format), body.join("\n"))
}

fn heading(value: &str, format: HelpFormat) -> String {
    match format {
        HelpFormat::Markdown => format!("**{}**", escape_markdown(value)),
        HelpFormat::PlainText => value.to_owned(),
    }
}

fn text(value: &str, format: HelpFormat) -> String {
    match format {
        HelpFormat::Markdown => escape_markdown(value),
        HelpFormat::PlainText => value.to_owned(),
    }
}

pub fn escape_markdown(value: &str) -> String {
    let mut escaped = String::with_capacity(value.len());
    for glyph in value.chars() {
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
