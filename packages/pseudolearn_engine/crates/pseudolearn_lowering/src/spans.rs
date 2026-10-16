#![forbid(unsafe_code)]

use pseudolearn_ir::IrSpan;
use pseudolearn_source::{SourceText, Span};

pub fn resolve_span(span: Span, source_text: &SourceText) -> Option<IrSpan> {
    if span.start == 0 && span.ending == 0 {
        return None;
    }
    let (start_line, start_column) = source_text.line_and_column(span.start);
    let (end_line, end_column) = source_text.line_and_column(span.ending);
    Some(IrSpan {
        start_line,
        start_column,
        end_line,
        end_column,
    })
}

pub(crate) fn header_span(span: Span, source: &SourceText) -> Option<IrSpan> {
    let text = source.slice(span)?;
    let header = text.lines().next()?;
    let ending = span.start.checked_add(u32::try_from(header.len()).ok()?)?;
    resolve_span(
        Span {
            start: span.start,
            ending,
        },
        source,
    )
}
