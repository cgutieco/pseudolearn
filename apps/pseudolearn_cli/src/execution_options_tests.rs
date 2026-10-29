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
