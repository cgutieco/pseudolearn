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
