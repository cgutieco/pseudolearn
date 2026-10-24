use crate::{ApiDiagnostic, ApiPosition, ApiSpan};
use pseudolearn_diagnostics::{DiagnosticArgument, DiagnosticCode};
use pseudolearn_vm::{LimitKind, RunExit, TraceEvent, VmTrap};
use serde_json::{Value, json};

pub(crate) fn event_with_source(
    event: &TraceEvent,
    view: Option<&crate::program_view::ProgramView>,
) -> Value {
    let mut value = self::event(event);
    if let (Some(view), Some(fields)) = (view, value.as_object_mut()) {
        fields.insert(
            "source".to_owned(),
            crate::event_source::source_of(view, event),
        );
    }
    value
}

pub(crate) fn event(event: &TraceEvent) -> Value {
    let mut value = json!({"class":event.class.as_str(),"line":event.line,"depth":event.depth});
    if let Some(payload) = &event.payload
        && let Some(fields) = value.as_object_mut()
    {
        fields.insert(
            "data".to_owned(),
            serde_json::from_str(&payload.to_canonical_json()).unwrap_or(Value::Null),
        );
    }
    value
}

pub(crate) fn termination(exit: &RunExit) -> Value {
    match exit {
        RunExit::Completed(_) => json!({"kind":"completed"}),
        RunExit::AwaitingInput => json!({"kind":"awaiting_input"}),
        RunExit::Cancelled => json!({"kind":"cancelled"}),
        RunExit::Trap(trap) => json!({"kind":"failed","code":trap.code}),
        RunExit::LimitReached { kind } => json!({"kind":"limit_reached", "limit": match kind {
            LimitKind::Statements => "statements", LimitKind::Time => "time",
        }}),
        RunExit::Service(_) => json!({"kind":"running"}),
    }
}

fn scoped_identity(
    source: Option<crate::ApiSourceIdentity>,
    source_id: u32,
) -> Option<crate::ApiSourceIdentity> {
    source
        .filter(|identity| identity.source_id == 0 || identity.source_id == source_id)
        .map(|identity| crate::ApiSourceIdentity {
            source_id,
            ..identity
        })
}

pub(crate) fn diagnostic(
    trap: &VmTrap,
    locale: &str,
    source: Option<crate::ApiSourceIdentity>,
) -> ApiDiagnostic {
    let code = DiagnosticCode::from_name(trap.code).unwrap_or(DiagnosticCode::InternalFault);
    let position = |line, column| ApiPosition { line, column };
    let span = |original: pseudolearn_bytecode::SourceSpan| {
        ApiSpan::in_source(
            position(original.start_line, original.start_column),
            position(original.end_line, original.end_column),
            scoped_identity(source, original.source_id.value()),
        )
    };
    let mut diagnostic = ApiDiagnostic {
        code: code.as_str().to_owned(),
        class: code.default_class().as_str().to_owned(),
        severity: match code.severity("estricto") {
            pseudolearn_diagnostics::DiagnosticSeverity::Error => "error",
            pseudolearn_diagnostics::DiagnosticSeverity::Warning => "warning",
            pseudolearn_diagnostics::DiagnosticSeverity::Information => "info",
        }
        .to_owned(),
        message: String::new(),
        span: trap
            .span
            .map(span)
            .unwrap_or_else(|| ApiSpan::in_source(position(1, 1), position(1, 1), source)),
        arguments: trap
            .arguments
            .iter()
            .map(|(key, value)| (key.to_string(), argument(value)))
            .collect(),
        related: trap.related.iter().copied().map(span).collect(),
    };
    diagnostic.message = crate::render_diagnostic(&diagnostic, locale);
    diagnostic
}

fn argument(value: &DiagnosticArgument) -> Value {
    value.wire()
}
