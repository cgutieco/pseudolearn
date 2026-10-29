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
fn parses_network_grant_and_repeated_origins() -> Result<(), String> {
    let arguments = [
        "run",
        "--grant",
        "red",
        "--origen",
        "https://api.example.test",
        "--origin",
        "https://files.example.test:8443",
        "--origen-local",
        "http://127.0.0.1:8080",
        "--test-root",
        "root.pem",
    ]
    .map(str::to_owned);
    let options =
        crate::options::parse_cli_options(&arguments).map_err(|error| format!("{error:?}"))?;
    assert_eq!(options.execution.grants, ["red"]);
    assert_eq!(
        options.execution.origins,
        [
            "https://api.example.test",
            "https://files.example.test:8443"
        ]
    );
    assert_eq!(options.execution.local_origins, ["http://127.0.0.1:8080"]);
    assert_eq!(options.execution.test_roots, ["root.pem"]);
    assert_eq!(
        crate::physical_session::host_document(&options.execution)
            .and_then(|host| host.get("network_origins").cloned()),
        Some(serde_json::json!([
            "https://api.example.test",
            "https://files.example.test:8443",
            "http://127.0.0.1:8080"
        ]))
    );
    Ok(())
}
