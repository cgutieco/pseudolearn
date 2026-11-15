use crate::options::parse_cli_options;
use pseudolearn_api::ExecuteRequest;

#[test]
fn rejects_tracing_before_native_execution() -> Result<(), String> {
    let arguments = ["run", "--native", "--trace"].map(str::to_owned);
    let options = parse_cli_options(&arguments).map_err(|error| format!("{error:?}"))?;
    let error = super::execute_native(&options, "program.psl", ExecuteRequest::default())
        .err()
        .ok_or("native tracing was accepted")?;
    assert_eq!(error.exit_code(), 2);
    Ok(())
}

#[test]
fn a_completed_run_returns_the_code_the_program_requested() {
    let completed = serde_json::json!({"termination": {"kind": "completed"}});
    assert_eq!(super::process_exit_code(&completed, 7), 7);
    assert_eq!(super::process_exit_code(&completed, 0), 0);
    assert_eq!(super::process_exit_code(&completed, 255), 255);
}

#[test]
fn a_run_that_did_not_complete_returns_one_whatever_was_requested() {
    let failed = serde_json::json!({"termination": {"kind": "failed", "code": "divisionByZero"}});
    assert_eq!(super::process_exit_code(&failed, 7), 1);
    assert_eq!(super::process_exit_code(&serde_json::json!({}), 0), 1);
}
