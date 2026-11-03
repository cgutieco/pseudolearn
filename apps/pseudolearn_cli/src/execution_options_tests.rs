use super::ExecutionArguments;

#[test]
fn supplies_cli_limits_from_the_language_contract() {
    let limits = ExecutionArguments::default().limits();

    assert_eq!(limits.max_json_depth, Some(64));
    assert_eq!(limits.max_http_body_bytes, Some(8_388_608));
    assert_eq!(limits.max_http_wire_bytes, Some(8_388_608));
    assert_eq!(limits.max_http_header_bytes, Some(16_384));
    assert_eq!(limits.max_http_headers, Some(64));
    assert_eq!(limits.max_pending_network, Some(8));
    assert_eq!(limits.max_http_timeout_nanos, Some(30_000_000_000));
}

#[test]
fn preserves_program_arguments_after_the_separator() -> Result<(), String> {
    let arguments = [
        "run",
        "--test-root",
        "root.pem",
        "--",
        "",
        "λ",
        "--seed",
        "17",
    ]
    .map(str::to_owned);
    let options =
        crate::options::parse_cli_options(&arguments).map_err(|error| format!("{error:?}"))?;
    assert_eq!(
        options.execution.program_arguments,
        ["", "λ", "--seed", "17"]
    );
    assert_eq!(options.execution.test_roots, ["root.pem"]);
    assert_eq!(options.execution.seed, None);
    Ok(())
}

#[test]
fn rejects_retired_authority_options() {
    for flag in [
        "--grant",
        "--origin",
        "--origen",
        "--files-root",
        "--origen-local",
    ] {
        assert!(crate::options::parse_cli_options(&["run".to_owned(), flag.to_owned()]).is_err());
    }
}
