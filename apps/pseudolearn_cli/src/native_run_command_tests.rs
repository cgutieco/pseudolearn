use crate::options::parse_cli_options;
use pseudolearn_api::ExecuteRequest;

#[test]
fn rejects_network_grants_before_native_execution() -> Result<(), String> {
    let arguments = ["run", "--native", "--grant", "red"].map(str::to_owned);
    let options = parse_cli_options(&arguments).map_err(|error| format!("{error:?}"))?;
    let error = super::execute_native(&options, "program.psl", ExecuteRequest::default())
        .err()
        .ok_or("network grant was accepted by native execution")?;
    assert_eq!(error.exit_code(), 2);
    Ok(())
}

#[test]
fn accepts_native_execution_without_network_grants() -> Result<(), String> {
    let arguments = ["run", "--native"].map(str::to_owned);
    let options = parse_cli_options(&arguments).map_err(|error| format!("{error:?}"))?;
    super::reject_network_grant(&options).map_err(|error| format!("{error:?}"))
}
