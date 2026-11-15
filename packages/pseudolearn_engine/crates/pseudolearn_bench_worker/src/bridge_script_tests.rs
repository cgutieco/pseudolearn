use crate::bridge_script::Script;
use serde_json::json;

#[test]
fn measures_real_requests_and_rejects_wrong_or_missing_expectations() -> Result<(), String> {
    let mut scenario = json!({"timed":[{"operation":"version","arguments":{}}],
        "expected":{"last.version":pseudolearn_api::ENGINE_VERSION}});
    let rows = Script::default().run(&scenario)?;
    assert_eq!(rows.len(), 1);
    assert!(
        rows.first()
            .and_then(|row| row.get("nanoseconds"))
            .and_then(serde_json::Value::as_u64)
            .is_some()
    );
    *scenario.get_mut("expected").ok_or("missing expectations")? =
        json!({"last.version":"wrong-version"});
    assert!(Script::default().run(&scenario).is_err());
    *scenario.get_mut("expected").ok_or("missing expectations")? = json!({});
    assert!(Script::default().run(&scenario).is_err());
    Ok(())
}

#[test]
fn bounded_repetitions_reject_missing_bindings_and_nonterminating_conditions() {
    let scenario = json!({"timed":[{"operation":"document","arguments":{"resource":"$missing"}}],
        "expected":{"last.version":"0.1.0"}});
    assert!(Script::default().run(&scenario).is_err());
    let scenario = json!({"timed":[{"operation":"version","arguments":{},"limit":2,
        "until":{"last.version":"never"}}],"expected":{"last.version":"never"}});
    assert!(Script::default().run(&scenario).is_err());
}
