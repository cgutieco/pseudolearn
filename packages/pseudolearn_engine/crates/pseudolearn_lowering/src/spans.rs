#![forbid(unsafe_code)]

use pseudolearn_ir::{IrPosition, IrSpan};
use pseudolearn_source::{SourceText, Span, is_valid_span};

pub fn resolve_span(span: Span, source_text: &SourceText) -> Option<IrSpan> {
    if (span.start == 0 && span.ending == 0) || !is_valid_span(source_text, span) {
        return None;
    }
    let (start_line, start_column) = source_text.line_and_column(span.start);
    let (end_line, end_column) = source_text.line_and_column(span.ending);
    Some(IrSpan::in_source(
        span.source_id,
        IrPosition::new(start_line, start_column),
        IrPosition::new(end_line, end_column),
    ))
}

pub(crate) fn header_span(span: Span, source: &SourceText) -> Option<IrSpan> {
    let text = source.slice(span)?;
    let header = text.lines().next()?;
    let ending = span.start.checked_add(u32::try_from(header.len()).ok()?)?;
    resolve_span(
        Span {
            source_id: span.source_id,
            start: span.start,
            ending,
        },
        source,
    )
}
