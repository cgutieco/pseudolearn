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
