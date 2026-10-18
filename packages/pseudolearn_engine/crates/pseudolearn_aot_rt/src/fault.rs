use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode, render};
use pseudolearn_source::Span;

use crate::context::{STATUS_FAILED, STATUS_LIMIT};

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub struct SourceRange {
    pub start_line: u32,
    pub start_column: u32,
    pub end_line: u32,
    pub end_column: u32,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct FaultSite {
    pub lexeme: String,
    pub code: DiagnosticCode,
    pub range: SourceRange,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct FaultRecord {
    pub site: u32,
    pub code: Option<DiagnosticCode>,
    pub range: SourceRange,
    pub arguments: Vec<(String, String)>,
}

pub fn render_fault(record: &FaultRecord, locale: &str) -> Option<String> {
    let mut diagnostic = Diagnostic::new(record.code?, Span::empty());
    for (name, value) in &record.arguments {
        diagnostic = diagnostic.with_argument(name, value);
    }
    Some(render(&diagnostic, locale))
}

pub(crate) fn status_of(code: Option<DiagnosticCode>) -> u32 {
    let budget = DiagnosticCode::from_name("statementBudgetExhausted");
    match code {
        None => STATUS_LIMIT,
        Some(code) if Some(code) == budget => STATUS_LIMIT,
        Some(_) => STATUS_FAILED,
    }
}
