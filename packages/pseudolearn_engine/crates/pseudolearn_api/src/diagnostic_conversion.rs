use crate::model::{AnalyzeResponse, ApiDiagnostic, ApiPosition, ApiSpan, ApiUnit};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode, DiagnosticSeverity, render};
use pseudolearn_source::{SourceText, Span};
use pseudolearn_syntax::{ModuleSchema, SyntaxTree, UnitKind};

pub(crate) fn convert(diagnostic: &Diagnostic, source: &SourceText, locale: &str) -> ApiDiagnostic {
    let severity = match diagnostic.severity {
        DiagnosticSeverity::Error => "error",
        DiagnosticSeverity::Warning => "warning",
        DiagnosticSeverity::Information => "info",
    };
    ApiDiagnostic {
        code: diagnostic.code.as_str().to_owned(),
        class: diagnostic.class.as_str().to_owned(),
        severity: severity.to_owned(),
        message: render(diagnostic, locale),
        span: span(diagnostic.span, source),
        arguments: diagnostic.arguments.clone(),
        related: diagnostic
            .related
            .iter()
            .map(|related| span(*related, source))
            .collect(),
    }
}

pub fn render_diagnostic(diagnostic: &ApiDiagnostic, locale: &str) -> String {
    let Some(code) = DiagnosticCode::from_name(&diagnostic.code) else {
        return diagnostic.message.clone();
    };
    let mut model = Diagnostic::new(code, Span::empty());
    model.arguments.clone_from(&diagnostic.arguments);
    render(&model, locale)
}

fn span(original: Span, source: &SourceText) -> ApiSpan {
    let start = source.line_and_column(original.start);
    let ending = source.line_and_column(original.ending);
    ApiSpan {
        start: ApiPosition {
            line: start.0,
            column: start.1,
        },
        end: ApiPosition {
            line: ending.0,
            column: ending.1,
        },
    }
}

pub(crate) fn schema(tree: &SyntaxTree, source: &SourceText) -> Vec<ApiUnit> {
    ModuleSchema::extract(tree, source)
        .units
        .into_iter()
        .map(|unit| ApiUnit {
            kind: match unit.kind {
                UnitKind::Program => "algorithm",
                UnitKind::Class => "class",
                UnitKind::Procedure | UnitKind::Function => "subprogram",
            }
            .to_owned(),
            name: unit.name,
            span: span(unit.span, source),
        })
        .collect()
}

pub(crate) fn internal_fault() -> AnalyzeResponse {
    let source = SourceText::new(String::new());
    let diagnostic = Diagnostic::new(DiagnosticCode::InternalFault, Span::empty());
    AnalyzeResponse::new(false, vec![convert(&diagnostic, &source, "es")])
}
