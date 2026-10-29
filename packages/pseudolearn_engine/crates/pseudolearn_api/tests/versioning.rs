use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

#[test]
fn declared_editions_and_capabilities_negotiate_without_changing_resources() -> Result<(), String> {
    let mut session = ApiSession::default();
    let declared = session.call("version", &json!({}));
    assert_eq!(declared.pointer("/value/editions"), Some(&json!(["2026"])));
    for name in ["editions", "capabilities"] {
        let values = declared
            .pointer(&format!("/value/{name}"))
            .and_then(Value::as_array)
            .ok_or("missing declaration")?;
        for value in values {
            assert_eq!(
                session.call("negotiate", &json!({name:value})),
                json!({"value":null})
            );
        }
        let rejected = session.call("negotiate", &json!({name:"unknown"}));
        assert_eq!(rejected.pointer("/failure/family"), Some(&json!("version")));
        let malformed = session.call("negotiate", &json!({name:17}));
        assert_eq!(malformed.pointer("/failure/family"), Some(&json!("usage")));
    }
    assert_eq!(session.call("version", &json!({})), declared);
    Ok(())
}

#[test]
fn reports_native_and_fetch_network_capabilities() {
    let mut session = ApiSession::default();
    for capabilities in [
        json!({
            "tls_validation":true,
            "wire_limit":"available",
            "certificate_errors_distinguished":true,
            "redirect_location_visible":true,
            "ssrf_policy":"adapter",
            "compression":"gzip"
        }),
        json!({
            "tls_validation":true,
            "wire_limit":"unavailable",
            "certificate_errors_distinguished":false,
            "redirect_location_visible":false,
            "ssrf_policy":"browser",
            "compression":"browser"
        }),
    ] {
        assert_eq!(
            session.call("negotiate", &json!({"network_capabilities":capabilities})),
            json!({"value":{"network_capabilities":capabilities}})
        );
    }
}

#[test]
fn rejects_incomplete_or_unsupported_network_capabilities() {
    let mut session = ApiSession::default();
    for capabilities in [
        json!({"tls_validation":true}),
        json!({
            "tls_validation":false,
            "wire_limit":"available",
            "certificate_errors_distinguished":true,
            "redirect_location_visible":true,
            "ssrf_policy":"adapter",
            "compression":"gzip"
        }),
        json!({
            "tls_validation":true,
            "wire_limit":"unknown",
            "certificate_errors_distinguished":true,
            "redirect_location_visible":true,
            "ssrf_policy":"adapter",
            "compression":"gzip"
        }),
        json!({
            "tls_validation":true,
            "wire_limit":"available",
            "certificate_errors_distinguished":true,
            "redirect_location_visible":true,
            "ssrf_policy":"adapter",
            "compression":"gzip",
            "proxy":true
        }),
    ] {
        let response = session.call("negotiate", &json!({"network_capabilities":capabilities}));
        assert_eq!(response.pointer("/failure/family"), Some(&json!("usage")));
    }
}
