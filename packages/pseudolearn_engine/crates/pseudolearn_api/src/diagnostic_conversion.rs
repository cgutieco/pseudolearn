use crate::model::{AnalyzeResponse, ApiDiagnostic, ApiPosition, ApiSpan, ApiUnit};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode, DiagnosticSeverity, render};
use pseudolearn_source::{SourceText, Span};
use pseudolearn_syntax::{ModuleSchema, SyntaxTree, UnitKind};

pub(crate) fn convert(diagnostic: &Diagnostic, source: &SourceText, locale: &str) -> ApiDiagnostic {
    let checked = if pseudolearn_diagnostics::validate_arguments(diagnostic) {
        std::borrow::Cow::Borrowed(diagnostic)
    } else {
        std::borrow::Cow::Owned(Diagnostic::new(
            DiagnosticCode::InternalFault,
            diagnostic.span,
        ))
    };
    let diagnostic = crate::argument_conversion::resolve(&checked, locale);
    let severity = match diagnostic.severity {
        DiagnosticSeverity::Error => "error",
        DiagnosticSeverity::Warning => "warning",
        DiagnosticSeverity::Information => "info",
    };
    ApiDiagnostic {
        code: diagnostic.code.as_str().to_owned(),
        class: diagnostic.class.as_str().to_owned(),
        severity: severity.to_owned(),
        message: render(&diagnostic, locale),
        span: span(diagnostic.span, source),
        arguments: crate::argument_conversion::wire(&diagnostic),
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
    let Some(arguments) = crate::argument_conversion::decode(diagnostic, code) else {
        return diagnostic.message.clone();
    };
    model.arguments = arguments;
    render(&model, locale)
}

pub(crate) fn span(original: Span, source: &SourceText) -> ApiSpan {
    if !pseudolearn_source::is_valid_span(source, original) {
        return ApiSpan::new(
            ApiPosition { line: 1, column: 1 },
            ApiPosition { line: 1, column: 1 },
        );
    }
    let start = source.line_and_column(original.start);
    let ending = source.line_and_column(original.ending);
    ApiSpan::in_source(
        ApiPosition {
            line: start.0,
            column: start.1,
        },
        ApiPosition {
            line: ending.0,
            column: ending.1,
        },
        crate::source_identity::api_identity(source),
    )
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
    AnalyzeResponse::new(false, vec![convert(&diagnostic, &source, "es")], Vec::new())
}
