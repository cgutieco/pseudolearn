use pseudolearn_semantic::ServiceAnalysis;
use pseudolearn_source::{LineIndex, SourceText, Span};
use serde::{Deserialize, Serialize};

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Position {
    pub line: u32,
    pub column: u32,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Range {
    pub start: Position,
    pub end: Position,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub enum HighlightKind {
    Text,
    Read,
    Write,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct DocumentHighlight {
    pub range: Range,
    pub kind: HighlightKind,
}

pub fn byte_offset_at_position(source: &SourceText, position: Position) -> usize {
    let indexer = LineIndex::build(source.as_str());
    let line_start = indexer
        .line_start(usize::try_from(position.line.saturating_sub(1)).unwrap_or(0))
        .unwrap_or(0);
    usize::try_from(line_start.saturating_add(position.column.saturating_sub(1))).unwrap_or(0)
}

pub fn span_to_range(source: &SourceText, span: Span) -> Range {
    let (start_line, start_col) = source.line_and_column(span.start);
    let (end_line, end_col) = source.line_and_column(span.ending);
    Range {
        start: Position {
            line: start_line,
            column: start_col,
        },
        end: Position {
            line: end_line,
            column: end_col,
        },
    }
}

pub fn find_definition(
    analysis: &ServiceAnalysis,
    source: &SourceText,
    position: Position,
) -> Option<Range> {
    let offset = byte_offset_at_position(source, position);
    let span = analysis.definition_span_at_byte_offset(offset)?;
    let definition_range = span_to_range(source, span);
    Some(adjust_multiline_definition_range(
        source,
        definition_range,
        offset,
    ))
}

fn adjust_multiline_definition_range(
    source: &SourceText,
    definition_range: Range,
    offset: usize,
) -> Range {
    if definition_range.start.line == definition_range.end.line {
        return definition_range;
    }
    let identifier_name = extract_word_at_offset(source.as_str(), offset);
    if identifier_name.is_empty() {
        return definition_range;
    }
    let start_line_index =
        usize::try_from(definition_range.start.line.saturating_sub(1)).unwrap_or(0);
    let Some(line_text) = source.as_str().lines().nth(start_line_index) else {
        return definition_range;
    };
    let Some(column_match) = line_text.find(&identifier_name) else {
        return definition_range;
    };
    let column_start = u32::try_from(column_match.saturating_add(1)).unwrap_or(1);
    let column_end = column_start.saturating_add(u32::try_from(identifier_name.len()).unwrap_or(0));
    Range {
        start: Position {
            line: definition_range.start.line,
            column: column_start,
        },
        end: Position {
            line: definition_range.start.line,
            column: column_end,
        },
    }
}

fn extract_word_at_offset(text: &str, offset: usize) -> String {
    let start = text
        .get(..offset)
        .and_then(|prefix| {
            prefix.rfind(|character: char| !character.is_alphanumeric() && character != '_')
        })
        .map(|index| index.saturating_add(1))
        .unwrap_or(0);
    let ending = text
        .get(offset..)
        .and_then(|suffix| {
            suffix.find(|character: char| !character.is_alphanumeric() && character != '_')
        })
        .map(|index| offset.saturating_add(index))
        .unwrap_or(text.len());
    text.get(start..ending).unwrap_or("").to_owned()
}

pub fn find_references(
    analysis: &ServiceAnalysis,
    source: &SourceText,
    position: Position,
) -> Vec<Range> {
    let offset = byte_offset_at_position(source, position);
    analysis
        .references_at_byte_offset(offset)
        .iter()
        .map(|reference| span_to_range(source, reference.span))
        .collect()
}

pub fn document_highlights(
    analysis: &ServiceAnalysis,
    source: &SourceText,
    position: Position,
) -> Vec<DocumentHighlight> {
    let offset = byte_offset_at_position(source, position);
    let mut highlights: Vec<DocumentHighlight> = Vec::new();
    for reference in analysis.references_at_byte_offset(offset) {
        let range = span_to_range(source, reference.span);
        let kind = if reference.is_write || reference.is_declaration {
            HighlightKind::Write
        } else {
            HighlightKind::Read
        };
        if let Some(existing) = highlights.iter_mut().find(|entry| entry.range == range) {
            if kind == HighlightKind::Write {
                existing.kind = HighlightKind::Write;
            }
        } else {
            highlights.push(DocumentHighlight { range, kind });
        }
    }
    highlights
}
