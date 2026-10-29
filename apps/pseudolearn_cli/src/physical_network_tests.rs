use crate::physical_network::{NetworkCapabilities, NetworkOrigin, network_origin};
use serde_json::json;

#[test]
fn declares_native_network_guarantees() {
    assert_eq!(
        NetworkCapabilities::value(),
        json!({
            "tls_validation":true,
            "wire_limit":"available",
            "certificate_errors_distinguished":true,
            "redirect_location_visible":true,
            "ssrf_policy":"adapter",
            "compression":"gzip"
        })
    );
}

#[test]
fn accepts_exact_secure_origins_and_local_loopback_origins() -> Result<(), String> {
    assert_eq!(
        network_origin("https://api.example.test", false)?,
        NetworkOrigin::new("https", "api.example.test", 443, false)
    );
    assert_eq!(
        network_origin("http://127.0.0.1:8080", true)?,
        NetworkOrigin::new("http", "127.0.0.1", 8080, true)
    );
    Ok(())
}

#[test]
fn enforces_granted_origins_for_complete_request_urls() -> Result<(), String> {
    let execution = crate::execution_options::ExecutionArguments {
        origins: vec!["https://api.example.test".to_owned()],
        local_origins: vec!["http://127.0.0.1:8080".to_owned()],
        ..crate::execution_options::ExecutionArguments::default()
    };
    let policy = crate::physical_network::NetworkPolicy::from_execution(&execution)
        .map_err(|error| error.code.to_owned())?;
    assert_eq!(
        policy.local_test_origin("https://api.example.test/path?query=1"),
        Ok(false)
    );
    assert_eq!(
        policy.local_test_origin("http://127.0.0.1:8080/path"),
        Ok(true)
    );
    assert!(
        policy
            .local_test_origin("https://other.example.test/path")
            .is_err()
    );
    Ok(())
}

#[test]
fn rejects_insecure_or_non_origin_network_values() {
    for (value, local) in [
        ("http://api.example.test", false),
        ("http://api.example.test", true),
        ("https://api.example.test/path", false),
        ("https://user@api.example.test", false),
        ("https://api.example.test/#fragment", false),
    ] {
        assert!(network_origin(value, local).is_err(), "{value}");
    }
}
