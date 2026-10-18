use pseudolearn_api::{
    ExecuteRequest, NativeRunReport, conformance_build_request, native_execute_response,
    rejected_native_response,
};
use serde_json::json;

fn run(exit_code: Option<i32>, output: &str, errors: &str) -> NativeRunReport {
    NativeRunReport {
        exit_code,
        output: output.to_owned(),
        errors: errors.to_owned(),
    }
}

fn respond(report: &NativeRunReport) -> pseudolearn_api::ExecuteResponse {
    native_execute_response(&ExecuteRequest::default(), Vec::new(), report)
}

#[test]
fn a_completed_run_keeps_its_output_and_has_no_diagnostics() {
    let response = respond(&run(Some(0), "42\n", ""));
    assert_eq!(response.output, "42\n");
    assert_eq!(response.termination, json!({"kind":"completed"}));
    assert!(response.diagnostics.is_empty());
}

#[test]
fn a_failed_run_reports_the_fatal_code_position_and_arguments() {
    let errors = "E\tdivisionByZero\t5\t9\t5\t12\t{}\n";
    let response = respond(&run(Some(3), "1\n", errors));
    assert_eq!(
        response.termination,
        json!({"kind":"failed","code":"divisionByZero"})
    );
    let diagnostic = response.diagnostics.first();
    assert_eq!(
        diagnostic.map(|found| found.severity.as_str()),
        Some("error")
    );
    assert_eq!(diagnostic.map(|found| found.span.end.column), Some(12));
}

#[test]
fn warnings_precede_the_fatal_diagnostic_and_keep_typed_arguments() {
    let errors = "W\treadValueTypeMismatch\t2\t1\t2\t5\t{\"expected\":\"Entero\",\"found\":\"x\"}\nE\trecursionDepthExceeded\t3\t1\t3\t4\t{\"limit\":3}\n";
    let response = respond(&run(Some(3), "", errors));
    let codes: Vec<&str> = response
        .diagnostics
        .iter()
        .map(|found| found.code.as_str())
        .collect();
    assert_eq!(codes, ["readValueTypeMismatch", "recursionDepthExceeded"]);
    assert_eq!(
        response
            .diagnostics
            .get(1)
            .and_then(|found| found.arguments.get("limit")),
        Some(&json!(3))
    );
}

#[test]
fn exit_four_distinguishes_exhausted_input_from_the_statement_limit() {
    let awaiting = respond(&run(Some(4), "", "X\n"));
    assert_eq!(awaiting.termination, json!({"kind":"awaiting_input"}));
    let limited = respond(&run(
        Some(4),
        "",
        "I\tstatementBudgetExhausted\t1\t1\t1\t4\t{\"limit\":9}\n",
    ));
    assert_eq!(
        limited.termination,
        json!({"kind":"limit_reached","limit":"statements"})
    );
    assert_eq!(
        limited
            .diagnostics
            .first()
            .map(|found| found.severity.as_str()),
        Some("info")
    );
}

#[test]
fn internal_exits_signals_and_unreadable_reports_become_an_internal_fault() {
    for report in [
        run(Some(5), "", ""),
        run(None, "", ""),
        run(Some(3), "", "garbage\n"),
    ] {
        let response = respond(&report);
        assert_eq!(
            response.termination,
            json!({"kind":"failed","code":"internalFault"})
        );
    }
}

#[test]
fn malformed_report_lines_are_ignored() {
    let errors = "E\tnoSuchCode\t1\t1\t1\t1\t{}\nE\tdivisionByZero\tx\t1\t1\t1\t{}\nE\tdivisionByZero\t1\t1\t1\t1\tnot json\n";
    assert!(respond(&run(Some(0), "", errors)).diagnostics.is_empty());
}

#[test]
fn a_rejected_program_is_reported_as_an_analysis_failure() {
    let response = rejected_native_response(Vec::new());
    assert_eq!(
        response.termination,
        json!({"kind":"failed","code":"analysisFailed"})
    );
}

#[test]
fn the_conformance_build_request_carries_the_machine_readable_templates() {
    let request = ExecuteRequest {
        seed: 7,
        ..ExecuteRequest::default()
    };
    let build = conformance_build_request(&request);
    assert_eq!(build.seed, 7);
    assert!(build.error_template.starts_with("E\t{code}"));
    assert_eq!(build.exhausted_template, "X\n");
}
