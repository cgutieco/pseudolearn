use crate::{ApiDiagnostic, ApiPosition, ApiSourceIdentity, ApiSpan};
use pseudolearn_diagnostics::DiagnosticCode;
use std::collections::BTreeMap;

pub(crate) fn unsupported(locale: &str, source: Option<ApiSourceIdentity>) -> ApiDiagnostic {
    let code = DiagnosticCode::NativeTasksUnsupported;
    let origin = ApiPosition { line: 1, column: 1 };
    let mut diagnostic = ApiDiagnostic {
        code: code.as_str().to_owned(),
        class: code.default_class().as_str().to_owned(),
        severity: "error".to_owned(),
        message: String::new(),
        span: ApiSpan::in_source(origin.clone(), origin, source),
        arguments: BTreeMap::new(),
        related: Vec::new(),
    };
    diagnostic.message = crate::render_diagnostic(&diagnostic, locale);
    diagnostic
}
