mod adapter;
use see_conformance::protocol::Session;
use serde_json::json;
use std::time::Duration;

#[test]
fn negotiates_requests_and_retains_stderr() -> Result<(), String> {
    let adapter = adapter::Adapter::create()?;
    let mut session = Session::start(&mut adapter.command("normal"), Duration::from_secs(2))?;
    assert_eq!(
        session
            .hello
            .get("subject")
            .and_then(|value| value.as_str()),
        Some("fixture")
    );
    let response = session.request(&json!({"kind":"analyze","program":""}))?;
    assert_eq!(response.get("tree"), Some(&json!(true)));
    assert!(session.finish()?.contains("fixture stderr"));
    Ok(())
}

#[test]
fn rejects_malformed_incompatible_eof_and_hanging_adapters() -> Result<(), String> {
    let adapter = adapter::Adapter::create()?;
    for mode in ["malformed", "version", "eof", "timeout"] {
        let result = Session::start(&mut adapter.command(mode), Duration::from_millis(100));
        assert!(result.is_err(), "{mode} must fail negotiation");
    }
    Ok(())
}

#[test]
fn rejects_response_kind_mismatch() -> Result<(), String> {
    let adapter = adapter::Adapter::create()?;
    let mut session = Session::start(&mut adapter.command("wrong-kind"), Duration::from_secs(2))?;
    assert!(session.request(&json!({"kind":"analyze"})).is_err());
    Ok(())
}
