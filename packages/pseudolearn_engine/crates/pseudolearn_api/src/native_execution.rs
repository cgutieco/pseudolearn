use crate::{
    ApiDiagnostic, ApiPosition, ApiSpan, ExecuteRequest, ExecuteResponse, NativeBuildRequest,
    render_diagnostic,
};
use pseudolearn_diagnostics::DiagnosticCode;
use serde_json::{Value, json};
use std::collections::BTreeMap;

const SOURCE_NAME: &str = "program.pseudo";
const FIELD_COUNT: usize = 8;
const ERROR_TEMPLATE: &str =
    "E\t{code}\t{source_id}\t{line}\t{column}\t{end_line}\t{end_column}\t{arguments}\n";
const WARNING_TEMPLATE: &str =
    "W\t{code}\t{source_id}\t{line}\t{column}\t{end_line}\t{end_column}\t{arguments}\n";
const INFORMATION_TEMPLATE: &str =
    "I\t{code}\t{source_id}\t{line}\t{column}\t{end_line}\t{end_column}\t{arguments}\n";
const EXHAUSTED_TEMPLATE: &str = "X\n";

#[derive(Clone, Debug, Default)]
pub struct NativeRunReport {
    pub exit_code: Option<i32>,
    pub output: String,
    pub errors: String,
    pub effects: Option<Vec<u8>>,
}

struct ReportedDiagnostic {
    tag: char,
    diagnostic: ApiDiagnostic,
}

pub fn conformance_build_request(request: &ExecuteRequest) -> NativeBuildRequest {
    NativeBuildRequest {
        program: request.program.clone(),
        profile: request.profile.clone(),
        strictness: request.strictness.clone(),
        seed: request.seed,
        forced_collection: request.gc_stress,
        limits: request.limits.clone(),
        source_name: SOURCE_NAME.to_owned(),
        source: request.source,
        locale: request.profile.clone(),
        error_template: ERROR_TEMPLATE.to_owned(),
        warning_template: WARNING_TEMPLATE.to_owned(),
        information_template: INFORMATION_TEMPLATE.to_owned(),
        exhausted_template: EXHAUSTED_TEMPLATE.to_owned(),
    }
}

pub fn rejected_native_response(diagnostics: Vec<ApiDiagnostic>) -> ExecuteResponse {
    response(
        String::new(),
        json!({"kind":"failed","code":"analysisFailed"}),
        diagnostics,
    )
}

pub fn protocol_rejected_native_response(error: &crate::ApiError) -> ExecuteResponse {
    let code = match error {
        crate::ApiError::InvalidProtocol(code) => code.as_str(),
        _ => "internalFault",
    };
    let mut built = response(
        String::new(),
        json!({"kind":"failed","code":code}),
        Vec::new(),
    );
    built.host_observation = Some(json!({"calls":0,"open_resources":0}));
    built
}

pub fn native_execute_response(
    request: &ExecuteRequest,
    warnings: Vec<ApiDiagnostic>,
    run: &NativeRunReport,
) -> ExecuteResponse {
    let reported = parse_report(&run.errors, &request.profile, request.source);
    let termination = termination(run, &reported);
    let mut diagnostics = warnings;
    diagnostics.extend(reported.into_iter().map(|entry| entry.diagnostic));
    let mut built = response(run.output.clone(), termination, diagnostics);
    if let Some(bytes) = run.effects.as_deref() {
        crate::native_effects::apply_native_effect_output(&mut built, bytes);
    }
    built
}

fn response(
    output: String,
    termination: Value,
    diagnostics: Vec<ApiDiagnostic>,
) -> ExecuteResponse {
    ExecuteResponse {
        kind: "execute".to_owned(),
        effect_tape: None,
        pending_effect: None,
        host_observation: None,
        output,
        termination,
        diagnostics,
        events: Vec::new(),
        inputs_consumed: 0,
        state_at: None,
    }
}

fn termination(run: &NativeRunReport, reported: &[ReportedDiagnostic]) -> Value {
    match run.exit_code {
        Some(0) => json!({"kind":"completed"}),
        Some(3) => json!({"kind":"failed","code":fatal_code(reported)}),
        Some(4) if run.errors.lines().any(|line| line == "X") => {
            json!({"kind":"awaiting_input"})
        }
        Some(4) => json!({"kind":"limit_reached","limit":"statements"}),
        _ => json!({"kind":"failed","code":"internalFault"}),
    }
}

fn fatal_code(reported: &[ReportedDiagnostic]) -> String {
    reported
        .iter()
        .rev()
        .find(|entry| entry.tag == 'E')
        .map_or_else(
            || "internalFault".to_owned(),
            |entry| entry.diagnostic.code.clone(),
        )
}

fn parse_report(
    errors: &str,
    locale: &str,
    source: Option<crate::ApiSourceIdentity>,
) -> Vec<ReportedDiagnostic> {
    errors
        .lines()
        .filter_map(|line| parse_line(line, locale, source))
        .collect()
}

fn parse_line(
    line: &str,
    locale: &str,
    source: Option<crate::ApiSourceIdentity>,
) -> Option<ReportedDiagnostic> {
    let [
        tag,
        code,
        source_id,
        start_line,
        start_column,
        end_line,
        end_column,
        arguments,
    ] = report_fields(line)?;
    let name = DiagnosticCode::from_name(code)?;
    let source = source.filter(|identity| {
        identity.is_valid() && source_id.parse::<u32>().ok() == Some(identity.source_id)
    });
    let mut diagnostic = ApiDiagnostic {
        code: name.as_str().to_owned(),
        class: name.default_class().as_str().to_owned(),
        severity: severity_name(tag)?.to_owned(),
        message: String::new(),
        span: ApiSpan::in_source(
            parse_position(start_line, start_column)?,
            parse_position(end_line, end_column)?,
            source,
        ),
        arguments: serde_json::from_str::<BTreeMap<String, Value>>(arguments).ok()?,
        related: Vec::new(),
    };
    diagnostic.message = render_diagnostic(&diagnostic, locale);
    Some(ReportedDiagnostic {
        tag: tag.chars().next()?,
        diagnostic,
    })
}

fn parse_position(line: &str, column: &str) -> Option<ApiPosition> {
    Some(ApiPosition {
        line: line.parse().ok()?,
        column: column.parse().ok()?,
    })
}

fn report_fields(line: &str) -> Option<[&str; FIELD_COUNT]> {
    let mut fields = line.splitn(FIELD_COUNT, '\t');
    Some([
        fields.next()?,
        fields.next()?,
        fields.next()?,
        fields.next()?,
        fields.next()?,
        fields.next()?,
        fields.next()?,
        fields.next()?,
    ])
}

fn severity_name(tag: &str) -> Option<&'static str> {
    match tag {
        "E" => Some("error"),
        "W" => Some("warning"),
        "I" => Some("info"),
        _ => None,
    }
}
