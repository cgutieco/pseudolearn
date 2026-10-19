use crate::ApiError;
use pseudolearn_diagnostics::{DiagnosticCode, DiagnosticSeverity};
use serde_json::{Value, json};

pub(crate) fn query(arguments: &Value) -> Result<Value, ApiError> {
    let name = text(arguments, "code")?;
    let locale = text(arguments, "locale")?;
    let code = DiagnosticCode::from_name(name).ok_or_else(|| usage("unknown diagnostic code"))?;
    let rigor = match text(arguments, "strictness")? {
        "strict" => "estricto",
        "flexible" => "flexible",
        _ => return Err(usage("invalid strictness")),
    };
    Ok(json!({
        "code": code.as_str(),
        "template": code.template(locale),
        "severity": wire_severity(code.severity(rigor)),
    }))
}

fn text<'arguments>(
    arguments: &'arguments Value,
    field: &str,
) -> Result<&'arguments str, ApiError> {
    arguments
        .get(field)
        .and_then(Value::as_str)
        .ok_or_else(|| usage("missing argument"))
}

fn wire_severity(severity: DiagnosticSeverity) -> &'static str {
    match severity {
        DiagnosticSeverity::Error => "error",
        DiagnosticSeverity::Warning => "warning",
        DiagnosticSeverity::Information => "info",
    }
}

fn usage(detail: &str) -> ApiError {
    ApiError::InvalidProtocol(detail.to_owned())
}
