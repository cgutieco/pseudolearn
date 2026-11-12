use crate::help_catalog::{ExampleProgram, HelpLocale};
use crate::help_content::HelpContent;
use crate::help_form::{entry_name, entry_text, form_text, part_entries};
use crate::help_labels::{HelpLabels, labels_for};

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

pub fn omitted_notice(locale: HelpLocale) -> &'static str {
    labels_for(locale).omitted
}

pub fn render_help(
    content: &HelpContent,
    locale: HelpLocale,
    format: HelpFormat,
) -> Result<String, HelpRenderError> {
    let labels = labels_for(locale);
    let mut blocks = introduction_blocks(content, labels, format);
    blocks.extend(detail_blocks(content, labels, format));
    blocks.extend(example_blocks(content, labels, format));
    let rendered = blocks.join("\n\n");
    if rendered.len() > MAXIMUM_RENDERED_BYTES {
        return Err(HelpRenderError::TooLarge {
            limit: MAXIMUM_RENDERED_BYTES,
        });
    }
    Ok(rendered)
}

fn introduction_blocks(
    content: &HelpContent,
    labels: &HelpLabels,
    format: HelpFormat,
) -> Vec<String> {
    vec![
        heading(content.title, format),
        emphasis(labels.category(content.category), format),
        inert_text(content.summary, format),
        titled(
            labels.how_to_write,
            code_block(&form_text(content.form, content.slots), format),
            format,
        ),
    ]
}

fn detail_blocks(content: &HelpContent, labels: &HelpLabels, format: HelpFormat) -> Vec<String> {
    let mut blocks = Vec::new();
    push_list(
        &mut blocks,
        labels.parts,
        &part_lines(content, format),
        format,
    );
    if let Some(result) = content.result {
        blocks.push(titled(labels.result, inert_text(result, format), format));
    }
    let rules: Vec<String> = content
        .rules
        .iter()
        .map(|rule| inert_text(rule, format))
        .collect();
    push_list(&mut blocks, labels.rules, &rules, format);
    let errors = error_lines(content, labels, format);
    push_list(&mut blocks, labels.common_errors, &errors, format);
    blocks
}

fn part_lines(content: &HelpContent, format: HelpFormat) -> Vec<String> {
    part_entries(content.form, content.parts, content.slots)
        .into_iter()
        .map(|entry| {
            let name = entry_name(entry, content.profile);
            let name = match format {
                HelpFormat::Markdown => code_span(&name),
                HelpFormat::PlainText => inert_text(&name, format),
            };
            format!("{name}: {}", inert_text(entry_text(entry), format))
        })
        .collect()
}

fn error_lines(content: &HelpContent, labels: &HelpLabels, format: HelpFormat) -> Vec<String> {
    content
        .common_errors
        .iter()
        .map(|error| {
            let text = inert_text(error.text, format);
            match &error.program {
                Some(program) => {
                    format!("{text}\n{}", program_text(program, content, labels, format))
                }
                None => text,
            }
        })
        .collect()
}

fn example_blocks(content: &HelpContent, labels: &HelpLabels, format: HelpFormat) -> Vec<String> {
    let label = if content.examples.len() > 1 {
        labels.examples
    } else {
        labels.example
    };
    let mut blocks = vec![heading(label, format)];
    for example in content.examples {
        blocks.push(program_text(&example.program, content, labels, format));
        blocks.push(inert_text(example.note, format));
    }
    blocks
}

fn program_text(
    program: &ExampleProgram,
    content: &HelpContent,
    labels: &HelpLabels,
    format: HelpFormat,
) -> String {
    let source = code_block(program.source(content.profile).trim_end(), format);
    match program.output {
        Some(output) => format!(
            "{source}\n{}\n{}",
            emphasis(labels.output, format),
            code_block(output.trim_end(), format)
        ),
        None => source,
    }
}

fn push_list(blocks: &mut Vec<String>, label: &str, lines: &[String], format: HelpFormat) {
    if lines.is_empty() {
        return;
    }
    let body: Vec<String> = lines
        .iter()
        .map(|line| format!("- {}", indent_continuation(line)))
        .collect();
    blocks.push(titled(label, body.join("\n"), format));
}

fn indent_continuation(line: &str) -> String {
    line.replace('\n', "\n  ")
}

fn titled(label: &str, body: String, format: HelpFormat) -> String {
    format!("{}\n{body}", heading(label, format))
}

fn heading(value: &str, format: HelpFormat) -> String {
    match format {
        HelpFormat::Markdown => format!("**{}**", escape_markdown(value)),
        HelpFormat::PlainText => inert_text(value, format),
    }
}

fn emphasis(value: &str, format: HelpFormat) -> String {
    match format {
        HelpFormat::Markdown => format!("*{}*", escape_markdown(value)),
        HelpFormat::PlainText => inert_text(value, format),
    }
}

fn code_span(value: &str) -> String {
    let code = inert_text(value, HelpFormat::PlainText);
    let fence = "`".repeat(longest_backtick_run(&code).saturating_add(1));
    format!("{fence}{code}{fence}")
}

pub fn code_block(value: &str, format: HelpFormat) -> String {
    let code = inert_code(value);
    match format {
        HelpFormat::Markdown => {
            let fence = "`".repeat(longest_backtick_run(&code).saturating_add(1).max(3));
            format!("{fence}\n{code}\n{fence}")
        }
        HelpFormat::PlainText => code
            .lines()
            .map(|line| format!("    {line}"))
            .collect::<Vec<_>>()
            .join("\n"),
    }
}

fn longest_backtick_run(value: &str) -> usize {
    value
        .split(|glyph| glyph != '`')
        .map(str::len)
        .max()
        .unwrap_or(0)
}

fn inert_code(value: &str) -> String {
    value
        .chars()
        .filter(|glyph| *glyph == '\n' || !is_inert_control(*glyph))
        .collect()
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
