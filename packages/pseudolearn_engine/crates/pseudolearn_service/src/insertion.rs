use crate::completion::CompletionTextEdit;
use crate::completion_types::{CompletionAction, CompletionEntry};
use crate::template_catalog::build_template;
use crate::template_model::{Segment, StopRole, Template, stop, text};
use crate::template_render::{DEFAULT_INDENT_UNIT, Layout, render, render_snippet};
use crate::template_reuse::reuse_existing_closer;
use pseudolearn_lexicon::Profile;

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TextChange {
    pub start_utf8: usize,
    pub end_utf8: usize,
    pub text: String,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct StopRange {
    pub index: u8,
    pub role: StopRole,
    pub start: usize,
    pub end: usize,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Insertion {
    pub edit: TextChange,
    pub stops: Vec<StopRange>,
    pub final_offset: usize,
    pub selection: (usize, usize),
    pub lsp_snippet: Option<String>,
}

pub fn build_insertion(
    entry: &CompletionEntry,
    replace: &CompletionTextEdit,
    source: &str,
    profile: Profile,
) -> Insertion {
    let start = replace.start_utf8;
    match template_for(entry, profile) {
        Some(mut template) => {
            reuse_existing_closer(&mut template, source, replace, profile);
            templated(&template, replace, line_indent(source, start))
        }
        None => plain(entry, replace),
    }
}

fn template_for(entry: &CompletionEntry, profile: Profile) -> Option<Template> {
    match &entry.action {
        CompletionAction::Plain => None,
        CompletionAction::Template { construction } => build_template(construction, profile),
        CompletionAction::Call { parameters } => Some(call_template(&entry.label, parameters)),
    }
}

fn call_template(name: &str, parameters: &[String]) -> Template {
    let mut segments = vec![text(format!("{name}("))];
    for (slot, parameter) in parameters.iter().enumerate() {
        if slot > 0 {
            segments.push(text(", "));
        }
        let index = u8::try_from(slot.saturating_add(1)).unwrap_or(u8::MAX);
        segments.push(stop(index, StopRole::Expression, parameter));
    }
    segments.push(text(")"));
    segments.push(Segment::Final);
    Template { segments }
}

pub(crate) fn templated(
    template: &Template,
    replace: &CompletionTextEdit,
    indent: &str,
) -> Insertion {
    let rendered = render(
        template,
        Layout {
            base_indent: indent,
            unit: DEFAULT_INDENT_UNIT,
        },
    );
    let start = replace.start_utf8;
    let stops: Vec<StopRange> = rendered
        .stops
        .iter()
        .map(|found| StopRange {
            index: found.index,
            role: found.role,
            start: start.saturating_add(found.start),
            end: start.saturating_add(found.end),
        })
        .collect();
    let final_offset = start.saturating_add(rendered.final_offset);
    let selection = stops.first().map_or((final_offset, final_offset), |first| {
        (first.start, first.end)
    });
    Insertion {
        edit: TextChange {
            start_utf8: start,
            end_utf8: replace.end_utf8,
            text: rendered.text,
        },
        stops,
        final_offset,
        selection,
        lsp_snippet: Some(render_snippet(template, DEFAULT_INDENT_UNIT)),
    }
}

fn plain(entry: &CompletionEntry, replace: &CompletionTextEdit) -> Insertion {
    let value = entry
        .insert_text
        .clone()
        .unwrap_or_else(|| entry.label.clone());
    let final_offset = replace.start_utf8.saturating_add(value.len());
    Insertion {
        edit: TextChange {
            start_utf8: replace.start_utf8,
            end_utf8: replace.end_utf8,
            text: value,
        },
        stops: Vec::new(),
        final_offset,
        selection: (final_offset, final_offset),
        lsp_snippet: None,
    }
}

pub fn line_indent(source: &str, offset: usize) -> &str {
    let head = source.get(..offset).unwrap_or("");
    let line_start = head.rfind('\n').map_or(0, |index| index.saturating_add(1));
    let line = source.get(line_start..).unwrap_or("");
    let width = line
        .find(|glyph: char| glyph != ' ' && glyph != '\t')
        .unwrap_or(line.len());
    let end = line.find('\n').map_or(width, |newline| width.min(newline));
    line.get(..end).unwrap_or("")
}

pub fn apply_change(source: &str, change: &TextChange) -> String {
    let head = source.get(..change.start_utf8).unwrap_or(source);
    let tail = source.get(change.end_utf8..).unwrap_or("");
    format!("{head}{}{tail}", change.text)
}
